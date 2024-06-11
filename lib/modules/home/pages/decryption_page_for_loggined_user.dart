import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:near_social_mobile/config/constants.dart';
import 'package:near_social_mobile/modules/vms/core/auth_controller.dart';
import 'package:near_social_mobile/routes/routes.dart';
import 'package:near_social_mobile/services/crypto_storage_service.dart';
import 'package:near_social_mobile/services/local_auth_service.dart';

class DecryptionPageForLoginnedUser extends StatelessWidget {
  const DecryptionPageForLoginnedUser({super.key});

  Future<void> decryptDataAndLogin() async {
    final secureStorage = Modular.get<FlutterSecureStorage>();
    final cryptoStorageService =
        CryptoStorageService(secureStorage: secureStorage);
    final encodedData = await cryptoStorageService.read(
      storageKey: SecureStorageKeys.authInfo,
    );
    final authController = Modular.get<AuthController>();
    final Map<String, dynamic> decodedData = jsonDecode(encodedData);
    authController.login(
      accountId: decodedData["accountId"],
      secretKey: decodedData["secretKey"],
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Modular.get<AuthController>();
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Image.asset(
                  "assets/media/images/near_social_backgorund.png",
                  fit: BoxFit.cover,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      final bool authenticated =
                          await LocalAuthService().authenticate(
                        requestAuthMessage:
                            'Please authenticate to decrypt data',
                      );
                      if (!authenticated) return;
                      await decryptDataAndLogin();
                    },
                    child: const Text("Decrypt"),
                  ),
                  SizedBox(height: 20.h),
                  ElevatedButton(
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      await authController.logout();
                      Modular.to.navigate(Routes.auth.getModule());
                    },
                    child: const Text("Logout"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
