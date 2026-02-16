import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:near_social_mobile/core/config/constants.dart';
import 'package:near_social_mobile/core/providers/service_providers.dart';
import 'package:near_social_mobile/core/router/routes.dart';
import 'package:near_social_mobile/core/services/crypto_service.dart';
import 'package:near_social_mobile/core/services/secure_storage_service.dart';
import 'package:near_social_mobile/core/shared_widgets/custom_button.dart';
import 'package:near_social_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:near_social_mobile/core/services/near_connect_service_stub.dart'
    if (dart.library.js_interop) 'package:near_social_mobile/core/services/near_connect_service.dart';

class LoginBody extends ConsumerWidget {
  const LoginBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        children: [
          CustomButton(
            primary: true,
            onPressed: () {
              context.push(AppRoutes.qrReader);
            },
            child: Text(
              'auth.login_with_qr'.tr(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          if (kIsWeb) ...[
            SizedBox(height: 10.h),
            CustomButton(
              primary: true,
              onPressed: () => _connectWallet(context, ref),
              child: Text(
                'auth.connect_wallet'.tr(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _connectWallet(BuildContext context, WidgetRef ref) async {
    try {
      final result = await NearConnectService.connect();
      final accountId = result.accountId;
      final publicKey = result.publicKey;

      // Encrypt and store wallet auth data
      final secureStorage = ref.read(secureStorageProvider);
      final cryptoStorageService =
          CryptoStorageService(secureStorage: secureStorage);
      final cryptographicKey = CryptoUtils.generateCryptographicKey();
      await cryptoStorageService.saveCryptographicKeyToStorage(
          cryptographicKey: cryptographicKey);
      await cryptoStorageService.write(
        storageKey: StorageKeys.authInfo,
        data: jsonEncode({
          'walletLogin': true,
          'accountId': accountId,
          'accountPublicKey': publicKey,
        }),
      );
      await secureStorage.write(
          key: StorageKeys.networkType, value: 'mainnet');

      // Login via wallet path
      final authController = ref.read(authControllerProvider.notifier);
      await authController.walletLogin(
        accountId: accountId,
        accountPublicKey: publicKey,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }
}
