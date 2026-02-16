import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:near_social_mobile/core/config/constants.dart';
import 'package:near_social_mobile/core/services/crypto_service.dart';
import 'package:near_social_mobile/core/services/secure_storage_service.dart';

Future<void> encryptDataAndLogin(String accountKey) async {
  final secureStorage = const FlutterSecureStorage();

  final cryptoStorageService =
      CryptoStorageService(secureStorage: secureStorage);

  final cryptographicKey = CryptoUtils.generateCryptographicKey();
  await cryptoStorageService.saveCryptographicKeyToStorage(
      cryptographicKey: cryptographicKey);

  await cryptoStorageService.write(
    storageKey: StorageKeys.authInfo,
    data: jsonEncode({'accountKey': accountKey}),
  );

  await const FlutterSecureStorage()
      .write(key: StorageKeys.networkType, value: "mainnet");
}
