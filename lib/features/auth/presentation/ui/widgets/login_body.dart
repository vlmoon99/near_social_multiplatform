import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:near_social_mobile/core/config/constants.dart';
import 'package:near_social_mobile/core/config/theme.dart';
import 'package:near_social_mobile/core/providers/service_providers.dart';
import 'package:near_social_mobile/core/router/routes.dart';
import 'package:near_social_mobile/core/services/crypto_service.dart';
import 'package:near_social_mobile/core/services/secure_storage_service.dart';
import 'package:near_social_mobile/core/shared_widgets/custom_button.dart';
import 'package:near_social_mobile/core/utils/qr_formatter.dart';
import 'package:near_social_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:near_social_mobile/features/auth/services/decrypt_data_and_login.dart';
import 'package:near_social_mobile/features/auth/services/encrypt_data_and_login.dart';
import 'package:near_social_mobile/core/services/near_connect_service_stub.dart'
    if (dart.library.js_interop) 'package:near_social_mobile/core/services/near_connect_service.dart';

class LoginBody extends ConsumerWidget {
  const LoginBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        children: [
          Row(
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
              SizedBox(width: 5.w),
              IconButton(
                onPressed: () {
                  context.push(AppRoutes.qrReader);
                },
                icon: const Icon(Icons.qr_code),
                style: IconButton.styleFrom(
                  backgroundColor: NEARColors.black,
                  foregroundColor: NEARColors.white,
                  disabledForegroundColor: NEARColors.white,
                  disabledBackgroundColor: NEARColors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8).r,
                    side: const BorderSide(
                      color: NEARColors.black,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          CustomButton(
            onPressed: () => _showKeyLoginDialog(context, ref),
            child: Text(
              'auth.login_with_key'.tr(),
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

  void _showKeyLoginDialog(BuildContext context, WidgetRef ref) {
    final keyController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return _KeyLoginDialog(
          controller: keyController,
          onLogin: () async {
            final input = keyController.text.trim();
            if (input.isEmpty) return;

            try {
              final publicKey = QRFormatter.parsePublicKey(input);
              await encryptDataAndLogin(publicKey);
              await decryptDataAndLogin(ref);
              if (dialogContext.mounted) Navigator.of(dialogContext).pop();
            } on FormatException {
              throw FormatException('auth.invalid_key_format'.tr());
            }
          },
        );
      },
    ).then((_) => keyController.dispose());
  }
}

class _KeyLoginDialog extends StatefulWidget {
  const _KeyLoginDialog({required this.controller, required this.onLogin});

  final TextEditingController controller;
  final Future<void> Function() onLogin;

  @override
  State<_KeyLoginDialog> createState() => _KeyLoginDialogState();
}

class _KeyLoginDialogState extends State<_KeyLoginDialog> {
  String? _error;
  bool _loading = false;

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      await widget.onLogin();
    } on FormatException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'auth.login_with_key'.tr(),
        style: const TextStyle(color: NEARColors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: widget.controller,
            autofocus: true,
            style: const TextStyle(color: NEARColors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'ed25519:...',
              hintStyle: TextStyle(
                color: NEARColors.white.withValues(alpha: 0.4),
              ),
              filled: true,
              fillColor: NEARColors.white.withValues(alpha: 0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              errorText: _error,
              errorStyle: const TextStyle(color: Colors.redAccent),
            ),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'common.cancel'.tr(),
            style: const TextStyle(color: NEARColors.white),
          ),
        ),
        FilledButton(
          onPressed: _loading ? null : _submit,
          style: FilledButton.styleFrom(
            backgroundColor: NEARColors.white,
            foregroundColor: NEARColors.black,
          ),
          child: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('auth.login'.tr()),
        ),
      ],
    );
  }
}
