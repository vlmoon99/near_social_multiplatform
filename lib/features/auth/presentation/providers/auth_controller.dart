import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:near_social_mobile/core/config/constants.dart';
import 'package:near_social_mobile/core/network/near_social_api.dart';
import 'package:near_social_mobile/core/network/near_rpc_service.dart';
import 'package:near_social_mobile/core/providers/service_providers.dart';
import 'package:near_social_mobile/core/services/crypto_service.dart';
import 'package:near_social_mobile/core/services/secure_storage_service.dart';
import 'package:near_social_mobile/features/auth/data/models/private_key_info.dart';
import 'package:near_social_mobile/features/auth/data/repositories/user_data_repository.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:near_social_mobile/features/auth/data/models/auth_info.dart';
import 'package:near_social_mobile/features/auth/presentation/logic/auth_events.dart';

part 'auth_controller.g.dart';

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  late NearRpcService _nearRpcService;
  late NearSocialApi _nearSocialApi;
  late UserDataRepository _userDataRepository;
  late CryptoStorageService _cryptoStorageService;

  @override
  AuthInfo build() {
    final secureStorage = ref.watch(secureStorageProvider);
    _nearRpcService = ref.watch(nearRpcServiceProvider);
    _nearSocialApi = ref.watch(nearSocialApiProvider);
    _userDataRepository = ref.watch(userDataRepositoryProvider);
    _cryptoStorageService =
        CryptoStorageService(secureStorage: secureStorage);
    return const AuthInfo();
  }

  Future<void> onEvent(AuthEvent event) async {
    switch (event) {
      case LoginEvent(:final accountId, :final secretKey):
        await login(accountId: accountId, secretKey: secretKey);
      case LogoutEvent():
        await logout();
      case GetActivationStatusEvent():
        await getActivationStatus();
      case AddAccessKeyEvent(:final accessKeyName, :final privateKeyInfo):
        await addAccessKey(accessKeyName: accessKeyName, privateKeyInfo: privateKeyInfo);
      case RemoveAccessKeyEvent(:final accessKeyName):
        await removeAccessKey(accessKeyName: accessKeyName);
    }
  }

  Future<void> login({
    required String accountId,
    required String secretKey,
  }) async {
    try {
      state = state.copyWith(
        accountId: accountId,
        secretKey: secretKey,
      );

      final publicKeyHex =
          _nearRpcService.getPublicKeyFromSecretKey(secretKey);
      final base58PubKey = _nearRpcService.getBase58PubKey(publicKeyHex);

      final additionalStoredKeys = {
        "Near Social QR Functional Key": PrivateKeyInfo(
          publicKey: accountId,
          privateKey: secretKey,
          base58PubKey: base58PubKey,
          privateKeyTypeInfo: const PrivateKeyTypeInfo(
            type: PrivateKeyType.FunctionCall,
            receiverId: "social.near",
            methodNames: [],
          ),
        ),
        ...await _getAdditionalAccessKeys()
      };

      final privateKeyBytes = CryptoService.privateKeyFromBase58(secretKey);
      final messageBytes =
          Uint8List.fromList(utf8.encode("NEAR Social verification"));
      final signatureBytes =
          CryptoService.signMessage(privateKeyBytes, messageBytes);
      String signedMessageForVerification = base64.encode(signatureBytes);

      var keyPair = await _getOrGenerateEncryptionKeys();

      final verificationResult =
          await _userDataRepository.verifyAndCreateSession(
        accountId: accountId,
        signature: signedMessageForVerification,
        publicKeyStr: base58PubKey,
        encryptionPublicKey: keyPair.$1,
        encryptionPrivateKey: keyPair.$2,
      );

      if (!verificationResult.success) {
        await logout();
        throw Exception(
            verificationResult.errorMessage ?? "Verification failed");
      }

      if (kIsWeb) {
        Permission.notification.request();
      }

      state = state.copyWith(
        accountId: accountId,
        publicKey: publicKeyHex,
        secretKey: secretKey,
        privateKey: secretKey,
        additionalStoredKeys: additionalStoredKeys,
        status: AuthInfoStatus.authenticated,
      );
    } catch (err) {
      rethrow;
    }
  }

  Future<(String, String)> _getOrGenerateEncryptionKeys() async {
    final secureStorage = ref.read(secureStorageProvider);
    final keys = await secureStorage.read(key: "session_keys");

    if (keys == null) {
      final random = Random.secure();
      final seed = Uint8List(32);
      for (var i = 0; i < 32; i++) {
        seed[i] = random.nextInt(256);
      }
      final pair = CryptoService.deriveKeyPairFromSeed(seed);

      final publicKeyStr = base64.encode(pair.publicKey);
      final privateKeyStr = base64.encode(pair.privateKey);

      await secureStorage.write(
        key: "session_keys",
        value: jsonEncode({
          'publicKey': publicKeyStr,
          'privateKey': privateKeyStr,
        }),
      );

      return (publicKeyStr, privateKeyStr);
    } else {
      final decoded = jsonDecode(keys) as Map<String, dynamic>;
      return (
        decoded['publicKey'] as String,
        decoded['privateKey'] as String,
      );
    }
  }

  Future<AccountActivationStatus> getActivationStatus() async {
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
      return getActivationStatus();
    }
  }

  Future<void> logout() async {
    try {
      await _userDataRepository.endSession();

      final secureStorage = ref.read(secureStorageProvider);
      await secureStorage.delete(key: StorageKeys.authInfo);
      await secureStorage.delete(
          key: StorageKeys.additionalCryptographicKeys);
      state = const AuthInfo();
    } catch (err) {
      throw Exception("Failed to logout");
    }
  }

  Future<void> addAccessKey({
    required String accessKeyName,
    required PrivateKeyInfo privateKeyInfo,
  }) async {
    try {
      final newState = state.copyWith(
        additionalStoredKeys: Map.of(state.additionalStoredKeys)
          ..putIfAbsent(accessKeyName, () => privateKeyInfo),
      );
      await _cryptoStorageService.write(
        storageKey: StorageKeys.additionalCryptographicKeys,
        data: jsonEncode(newState.additionalStoredKeys),
      );
      state = newState;
    } catch (err) {
      throw Exception("Failed to add key");
    }
  }

  Future<void> removeAccessKey({required String accessKeyName}) async {
    try {
      final newState = state.copyWith(
        additionalStoredKeys: Map.of(state.additionalStoredKeys)
          ..remove(accessKeyName),
      );
      await _cryptoStorageService.write(
        storageKey: StorageKeys.additionalCryptographicKeys,
        data: jsonEncode(newState.additionalStoredKeys),
      );
      state = newState;
    } catch (err) {
      throw Exception("Failed to remove key");
    }
  }

  Future<Map<String, PrivateKeyInfo>> _getAdditionalAccessKeys() async {
    try {
      final encodedData = await _cryptoStorageService.read(
        storageKey: StorageKeys.additionalCryptographicKeys,
      );
      final decodedData =
          jsonDecode(encodedData) as Map<String, dynamic>?;
      if (decodedData == null) {
        return {};
      }
      final additionalKeys = decodedData.map((key, value) {
        return MapEntry(key, PrivateKeyInfo.fromJson(value));
      });
      return additionalKeys;
    } catch (err) {
      return {};
    }
  }
}
