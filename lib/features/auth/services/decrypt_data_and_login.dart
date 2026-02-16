import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:near_social_mobile/core/config/constants.dart';
import 'package:near_social_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:near_social_mobile/core/providers/service_providers.dart';
import 'package:near_social_mobile/core/services/secure_storage_service.dart';

Future<void> decryptDataAndLogin(WidgetRef ref) async {
  final secureStorage = ref.read(secureStorageProvider);
  final cryptoStorageService =
      CryptoStorageService(secureStorage: secureStorage);
  final encodedData = await cryptoStorageService.read(
    storageKey: StorageKeys.authInfo,
  );
  final authController = ref.read(authControllerProvider.notifier);
  final Map<String, dynamic> decodedData = jsonDecode(encodedData);

  if (decodedData['walletLogin'] == true) {
    await authController.walletLogin(
      accountId: decodedData['accountId'] as String,
      accountPublicKey: decodedData['accountPublicKey'] as String?,
    );
  } else {
    // Support both old format (accountPublicKey) and new format (accountKey)
    final key = (decodedData['accountKey'] as String?) ??
        (decodedData['accountPublicKey'] as String);
    await authController.login(accountKey: key);
  }
}
