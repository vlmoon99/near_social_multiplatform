import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:near_social_mobile/core/config/constants.dart';
import 'package:near_social_mobile/features/auth/data/models/authorization_credentials.dart';
import 'package:near_social_mobile/core/services/crypto_service.dart';
import 'package:near_social_mobile/core/services/secure_storage_service.dart';

Future<void> encryptDataAndLogin(
    AuthorizationCredentials authorizationCredentials) async {
  final secureStorage = const FlutterSecureStorage();

  final cryptoStorageService =
      CryptoStorageService(secureStorage: secureStorage);

  final cryptographicKey = CryptoUtils.generateCryptographicKey();
  await cryptoStorageService.saveCryptographicKeyToStorage(
      cryptographicKey: cryptographicKey);

  await cryptoStorageService.write(
    storageKey: StorageKeys.authInfo,
    data: jsonEncode(authorizationCredentials),
  );

  await const FlutterSecureStorage()
      .write(key: StorageKeys.networkType, value: "mainnet");

  // Note: authController.login() is called after navigation via Riverpod providers.
  // The login flow is handled by the auth state initialization in the home page.
}
