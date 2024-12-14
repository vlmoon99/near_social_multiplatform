import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:near_social_mobile/config/constants.dart';
import 'package:near_social_mobile/modules/vms/core/auth_controller.dart';
import 'package:near_social_mobile/modules/vms/core/models/authorization_credentials.dart';
import 'package:near_social_mobile/services/crypto_service.dart';
import 'package:near_social_mobile/services/crypto_storage_service.dart';
import 'package:near_social_mobile/services/notification_subscription_service.dart';
import 'package:near_wallet_selector/near_wallet_selector.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> encryptDataAndLogin(
    AuthorizationCredentials authorizationCredentials) async {
  final secureStorage = Modular.get<FlutterSecureStorage>();

  final cryptoStorageService =
      CryptoStorageService(secureStorage: secureStorage);

  final cryptographicKey = CryptoUtils.generateCryptographicKey();
  await cryptoStorageService.saveCryptographicKeyToStorage(
      cryptographicKey: cryptographicKey);

  await cryptoStorageService.write(
    storageKey: StorageKeys.authInfo,
    data: jsonEncode(authorizationCredentials),
  );

  await Modular.get<FlutterSecureStorage>()
      .write(key: StorageKeys.networkType, value: "mainnet");

  final authController = Modular.get<AuthController>();
  await authController
      .login(
    accountId: authorizationCredentials.accountId,
    secretKey: authorizationCredentials.secretKey,
  )
      .then(
    (_) {
      if (!kIsWeb) {
        Modular.get<NotificationSubscriptionService>().subscribeToNotifications(
          authorizationCredentials.accountId,
        );
      }
    },
  );

  await Supabase.instance.client.auth.signInAnonymously();

  UserResponse user = await Supabase.instance.client.auth.getUser();
  print(user.user?.toJson().toString() ?? "no data");

  if (kIsWeb) {
    NearWalletSelector().clearCredentials();
  }
}
