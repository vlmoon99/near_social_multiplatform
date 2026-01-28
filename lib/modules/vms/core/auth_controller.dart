import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:near_social_mobile/modules/home/apis/near_social.dart';

import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutterchain/flutterchain_lib/services/chains/near_blockchain_service.dart';
import 'package:near_social_mobile/config/constants.dart';
import 'package:near_social_mobile/data/repositories/repositories.dart';
import 'package:near_social_mobile/modules/home/apis/models/private_key_info.dart';
import 'package:near_social_mobile/services/crypto_storage_service.dart';
import 'package:near_social_mobile/services/cryptography/encryption/encryption_runner_interface.dart';
import 'package:near_social_mobile/services/cryptography/internal_cryptography_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';

import 'models/auth_info.dart';

class AuthController extends Disposable {
  final NearBlockChainService _nearBlockChainService;
  final FlutterSecureStorage _secureStorage;
  final NearSocialApi _nearSocialApi;
  final UserDataRepository _userDataRepository;

  late final CryptoStorageService _cryptoStorageService;

  final BehaviorSubject<AuthInfo> _streamController =
      BehaviorSubject.seeded(const AuthInfo());

  AuthController(
    this._nearBlockChainService,
    this._secureStorage,
    this._nearSocialApi,
    this._userDataRepository,
  ) : _cryptoStorageService =
            CryptoStorageService(secureStorage: _secureStorage);

  Stream<AuthInfo> get stream => _streamController.stream.distinct();
  AuthInfo get state => _streamController.value;

  Future<void> login({
    required String accountId,
    required String secretKey,
  }) async {
    try {
      _streamController.add(state.copyWith(
        accountId: accountId,
        secretKey: secretKey,
      ));

      final privateKey = await _nearBlockChainService
          .getPrivateKeyFromSecretKeyFromNearApiJSFormat(
        secretKey.split(":").last,
      );
      final publicKey = await _nearBlockChainService
          .getPublicKeyFromSecretKeyFromNearApiJSFormat(
        secretKey.split(":").last,
      );

      final base58PubKey = await _nearBlockChainService
          .getBase58PubKeyFromHexValue(hexEncodedPubKey: publicKey);

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

      // Подписываем сообщение для верификации (используется локально)
      String signedMessageForVerification =
          await Modular.get<InternalCryptographyService>()
              .encryptionRunner
              .signMessageForVerification(secretKey);

      // Получаем или генерируем ключи шифрования
      var keyPair = await _getOrGenerateEncryptionKeys();

      // Верификация и создание сессии через репозиторий
      final verificationResult = await _userDataRepository.verifyAndCreateSession(
        accountId: accountId,
        signature: signedMessageForVerification,
        publicKeyStr: base58PubKey,
        encryptionPublicKey: keyPair.publicKey,
        encryptionPrivateKey: keyPair.privateKey,
      );

      if (!verificationResult.success) {
        await logout();
        throw Exception(verificationResult.errorMessage ?? "Verification failed");
      }

      if (kIsWeb) {
        Permission.notification.onDeniedCallback(() {
          print("onDeniedCallback");
        }).onGrantedCallback(() {
          print("onGrantedCallback");
        }).request();
      }

      _streamController.add(state.copyWith(
        accountId: accountId,
        publicKey: publicKey,
        secretKey: secretKey,
        privateKey: privateKey,
        additionalStoredKeys: additionalStoredKeys,
        status: AuthInfoStatus.authenticated,
      ));
    } catch (err) {
      rethrow;
    }
  }

  /// Получает или генерирует ключи шифрования для E2E
  Future<KeyPair> _getOrGenerateEncryptionKeys() async {
    final keys = await _secureStorage.read(key: "session_keys");

    if (keys == null) {
      final keyPair = await Modular.get<InternalCryptographyService>()
          .encryptionRunner
          .generateKeyPair();

      await _secureStorage.write(
        key: "session_keys",
        value: jsonEncode(keyPair.toJson()),
      );

      return keyPair;
    } else {
      return KeyPair.fromJson(jsonDecode(keys));
    }
  }

  Future<AccountActivationStatus> getActivationStatus() async {
    try {
      if (state.accountActivationStatus != AccountActivationStatus.activated) {
        final activationStatus =
            await _nearSocialApi.getUserStorageInfo(state.accountId);
        final status = (activationStatus.usedBytes != null &&
                activationStatus.usedBytes != null)
            ? AccountActivationStatus.activated
            : AccountActivationStatus.notActivated;
        _streamController.add(state.copyWith(accountActivationStatus: status));
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
      // Завершаем сессию через репозиторий
      await _userDataRepository.endSession();

      await _secureStorage.delete(key: StorageKeys.authInfo);
      await _secureStorage.delete(key: StorageKeys.additionalCryptographicKeys);
      _streamController.add(const AuthInfo());
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
      _streamController.add(newState);
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
      _streamController.add(newState);
    } catch (err) {
      throw Exception("Failed to remove key");
    }
  }

  Future<Map<String, PrivateKeyInfo>> _getAdditionalAccessKeys() async {
    try {
      final encodedData = await _cryptoStorageService.read(
        storageKey: StorageKeys.additionalCryptographicKeys,
      );
      final decodedData = jsonDecode(encodedData) as Map<String, dynamic>?;
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

  @override
  void dispose() {
    _streamController.close();
  }
}
