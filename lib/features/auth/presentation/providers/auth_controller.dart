import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:near_social_mobile/core/config/constants.dart';
import 'package:near_social_mobile/core/network/near_rpc_service.dart';
import 'package:near_social_mobile/core/network/near_social_api.dart';
import 'package:near_social_mobile/core/providers/service_providers.dart';
import 'package:near_social_mobile/core/services/crypto_service.dart';
import 'package:near_social_mobile/features/auth/data/repositories/user_data_repository.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:near_social_mobile/features/auth/data/models/auth_info.dart';
import 'package:near_social_mobile/features/auth/presentation/logic/auth_events.dart';

part 'auth_controller.g.dart';

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  late NearSocialApi _nearSocialApi;
  late NearRpcService _nearRpcService;
  late UserDataRepository _userDataRepository;

  @override
  AuthInfo build() {
    _nearSocialApi = ref.watch(nearSocialApiProvider);
    _nearRpcService = ref.watch(nearRpcServiceProvider);
    _userDataRepository = ref.watch(userDataRepositoryProvider);
    return const AuthInfo();
  }

  Future<void> onEvent(AuthEvent event) async {
    switch (event) {
      case LoginEvent(:final accountKey):
        await login(accountKey: accountKey);
      case WalletLoginEvent(:final accountId, :final accountPublicKey):
        await walletLogin(
            accountId: accountId, accountPublicKey: accountPublicKey);
      case LogoutEvent():
        await logout();
      case GetActivationStatusEvent():
        await getActivationStatus();
    }
  }

  Future<void> login({required String accountKey}) async {
    try {
      // 1. Detect if input is a private key (64 bytes) or public key (32 bytes)
      final rawKey = accountKey.startsWith('ed25519:')
          ? accountKey.substring(8)
          : accountKey;
      final keyData = Base58.decode(rawKey);

      String accountPublicKey;
      String accountPrivKeyStr = '';

      if (keyData.length == 64) {
        // Private key (seed+pub) — derive public key from it
        final privKeyBytes = CryptoService.privateKeyFromBase58(accountKey);
        final pubKeyBytes = Uint8List.sublistView(privKeyBytes, 32, 64);
        accountPublicKey = CryptoService.publicKeyToBase58(pubKeyBytes);
        accountPrivKeyStr = base64.encode(privKeyBytes);
      } else if (keyData.length == 32) {
        // Could be a public key or a seed-only private key.
        // Try as public key first.
        accountPublicKey = accountKey.startsWith('ed25519:')
            ? accountKey
            : 'ed25519:$rawKey';
      } else {
        throw FormatException('Invalid key length: ${keyData.length} bytes');
      }

      final pubKeyBytes = CryptoService.publicKeyFromBase58(accountPublicKey);

      // 2. Derive implicit accountId (hex of public key bytes)
      final accountId = CryptoService.publicKeyToImplicitAccountId(pubKeyBytes);

      // 3. Generate device Ed25519 keypair
      final deviceKeyPair = CryptoService.generateEd25519KeyPair();
      final devicePubKeyStr = base64.encode(deviceKeyPair.publicKey);
      final devicePrivKeyStr = base64.encode(deviceKeyPair.privateKey);

      // 4. Sign a verification message with device key
      final messageBytes =
          Uint8List.fromList(utf8.encode("NEAR Social verification"));
      final signatureBytes =
          CryptoService.signMessage(deviceKeyPair.privateKey, messageBytes);
      final signedMessage = base64.encode(signatureBytes);

      // 5. Create session via repository
      final verificationResult =
          await _userDataRepository.verifyAndCreateSession(
        accountId: accountId,
        signature: signedMessage,
        publicKeyStr: accountPublicKey,
        encryptionPublicKey: devicePubKeyStr,
        encryptionPrivateKey: devicePrivKeyStr,
      );

      if (!verificationResult.success) {
        await logout();
        throw Exception(
            verificationResult.errorMessage ?? "Verification failed");
      }

      if (kIsWeb) {
        Permission.notification.request();
      }

      // 6. Update state
      state = state.copyWith(
        accountId: accountId,
        accountPublicKey: accountPublicKey,
        accountPrivateKey: accountPrivKeyStr,
        devicePublicKey: devicePubKeyStr,
        devicePrivateKey: devicePrivKeyStr,
        status: AuthInfoStatus.authenticated,
      );
    } catch (err) {
      rethrow;
    }
  }

  /// Logs in using a named account ID from a wallet connection.
  ///
  /// If [accountPublicKey] is not provided, queries the NEAR RPC for a
  /// full-access key belonging to [accountId].
  Future<void> walletLogin({
    required String accountId,
    String? accountPublicKey,
  }) async {
    try {
      // 1. Resolve public key
      String publicKey = accountPublicKey ?? '';
      if (publicKey.isEmpty) {
        final rpcKey = await _nearRpcService.getFullAccessPublicKey(accountId);
        if (rpcKey == null) {
          throw Exception('No full-access key found for $accountId');
        }
        publicKey = rpcKey;
      }

      // 2. Generate device Ed25519 keypair
      final deviceKeyPair = CryptoService.generateEd25519KeyPair();
      final devicePubKeyStr = base64.encode(deviceKeyPair.publicKey);
      final devicePrivKeyStr = base64.encode(deviceKeyPair.privateKey);

      // 3. Sign a verification message with device key
      final messageBytes =
          Uint8List.fromList(utf8.encode("NEAR Social verification"));
      final signatureBytes =
          CryptoService.signMessage(deviceKeyPair.privateKey, messageBytes);
      final signedMessage = base64.encode(signatureBytes);

      // 4. Create session via repository
      final verificationResult =
          await _userDataRepository.verifyAndCreateSession(
        accountId: accountId,
        signature: signedMessage,
        publicKeyStr: publicKey,
        encryptionPublicKey: devicePubKeyStr,
        encryptionPrivateKey: devicePrivKeyStr,
      );

      if (!verificationResult.success) {
        await logout();
        throw Exception(
            verificationResult.errorMessage ?? "Verification failed");
      }

      if (kIsWeb) {
        Permission.notification.request();
      }

      // 5. Update state — use accountId directly (named account, not derived)
      state = state.copyWith(
        accountId: accountId,
        accountPublicKey: publicKey,
        devicePublicKey: devicePubKeyStr,
        devicePrivateKey: devicePrivKeyStr,
        status: AuthInfoStatus.authenticated,
      );
    } catch (err) {
      rethrow;
    }
  }

  Uint8List signForServer(Uint8List message) {
    final devicePrivKeyBytes = base64.decode(state.devicePrivateKey);
    return CryptoService.signMessage(devicePrivKeyBytes, message);
  }

  Future<AccountActivationStatus> getActivationStatus({int retries = 3}) async {
    try {
      if (state.accountActivationStatus !=
          AccountActivationStatus.activated) {
        final activationStatus =
            await _nearSocialApi.getUserStorageInfo(state.accountId);
        final status = (activationStatus.usedBytes != null &&
                activationStatus.usedBytes != null)
            ? AccountActivationStatus.activated
            : AccountActivationStatus.notActivated;
        state = state.copyWith(accountActivationStatus: status);
        return status;
      } else {
        return state.accountActivationStatus;
      }
    } catch (err) {
      if (retries > 0) {
        await Future.delayed(const Duration(seconds: 2));
        return getActivationStatus(retries: retries - 1);
      }
      return AccountActivationStatus.notActivated;
    }
  }

  Future<void> logout() async {
    try {
      await _userDataRepository.endSession();

      final secureStorage = ref.read(secureStorageProvider);
      await secureStorage.delete(key: StorageKeys.authInfo);
      state = const AuthInfo();
    } catch (err) {
      throw Exception("Failed to logout");
    }
  }
}
