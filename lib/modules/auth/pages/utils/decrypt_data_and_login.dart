import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:near_social_mobile/config/constants.dart';
import 'package:near_social_mobile/modules/vms/core/auth_controller.dart';
import 'package:near_social_mobile/services/crypto_storage_service.dart';

Future<void> decryptDataAndLogin() async {
  final secureStorage = Modular.get<FlutterSecureStorage>();
  final cryptoStorageService =
      CryptoStorageService(secureStorage: secureStorage);
  final encodedData = await cryptoStorageService.read(
    storageKey: StorageKeys.authInfo,
  );
  final authController = Modular.get<AuthController>();
  final Map<String, dynamic> decodedData = jsonDecode(encodedData);
  await authController.login(
    accountId: decodedData["accountId"],
    secretKey: decodedData["secretKey"],
  );
}
