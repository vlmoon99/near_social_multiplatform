import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:near_social_mobile/core/config/theme.dart';
import 'package:near_social_mobile/core/router/routes.dart';
import 'package:near_social_mobile/core/shared_widgets/custom_button.dart';
import 'package:near_social_mobile/features/auth/data/models/authorization_credentials.dart';

class LoginWithKeyPage extends ConsumerStatefulWidget {
  const LoginWithKeyPage({super.key});

  @override
  ConsumerState<LoginWithKeyPage> createState() => _LoginWithKeyPageState();
}

class _LoginWithKeyPageState extends ConsumerState<LoginWithKeyPage> {
  final _accountIdController = TextEditingController();
  final _secretKeyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void dispose() {
    _accountIdController.dispose();
    _secretKeyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final creds = AuthorizationCredentials(
        accountId: _accountIdController.text.trim(),
        secretKey: _secretKeyController.text.trim(),
      );
      context.push(AppRoutes.encryptData, extra: creds);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: NEARColors.white,
        title: Text("auth.login_with_key".tr()),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20.h),
              TextFormField(
                controller: _accountIdController,
                style: const TextStyle(color: NEARColors.white),
                decoration: InputDecoration(
                  labelText: "auth.account_id".tr(),
                  labelStyle: const TextStyle(color: NEARColors.grey),
                  hintText: "example.near",
                  hintStyle: TextStyle(color: NEARColors.grey.withValues(alpha: 0.5)),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: NEARColors.grey),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: NEARColors.white),
                  ),
                  errorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: NEARColors.red),
                  ),
                  focusedErrorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: NEARColors.red),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "auth.enter_account_id".tr();
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _secretKeyController,
                style: const TextStyle(color: NEARColors.white),
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "auth.secret_key".tr(),
                  labelStyle: const TextStyle(color: NEARColors.grey),
                  hintText: "ed25519:...",
                  hintStyle: TextStyle(color: NEARColors.grey.withValues(alpha: 0.5)),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: NEARColors.grey),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: NEARColors.white),
                  ),
                  errorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: NEARColors.red),
                  ),
                  focusedErrorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: NEARColors.red),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "auth.enter_secret_key".tr();
                  }
                  if (!value.trim().startsWith('ed25519:')) {
                    return "auth.invalid_key_format".tr();
                  }
                  return null;
                },
              ),
              SizedBox(height: 24.h),
              CustomButton(
                primary: true,
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: NEARColors.white,
                        ),
                      )
                    : Text(
                        "auth.login".tr(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
