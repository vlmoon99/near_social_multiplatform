import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:near_social_mobile/core/l10n/localizations_strings.dart';
import 'package:near_social_mobile/features/auth/services/encrypt_data_and_login.dart';
import 'package:near_social_mobile/features/auth/data/models/authorization_credentials.dart';
import 'package:near_social_mobile/core/router/routes.dart';
import 'package:near_social_mobile/core/services/local_auth_service.dart';
import 'package:near_social_mobile/core/shared_widgets/custom_button.dart';

class EncryptionScreen extends StatefulWidget {
  const EncryptionScreen({super.key, required this.authorizationCredentials});
  final AuthorizationCredentials authorizationCredentials;

  @override
  State<EncryptionScreen> createState() => _EncryptionScreenState();
}

class _EncryptionScreenState extends State<EncryptionScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset("assets/media/icons/near_social_logo.svg"),
            SizedBox(width: 10.h),
            Text(
              LocalizationsStrings.home.title,
              style: const TextStyle(fontSize: 20),
            ).tr(),
          ],
        ),
        centerTitle: true,
        leadingWidth: 0,
        leading: const SizedBox.shrink(),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: REdgeInsets.symmetric(horizontal: 24),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "auth.attention".tr(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24.0,
                        ),
                      ),
                      TextSpan(
                        text: !kIsWeb
                            ? "auth.encrypt_message".tr()
                            : "auth.encrypt_message_web".tr(),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              SizedBox(height: 20.h),
              CustomButton(
                primary: true,
                onPressed: () async {
                  late bool authenticated;
                  if (kIsWeb) {
                    authenticated = true;
                  } else {
                    authenticated = await LocalAuthService().authenticate(
                      requestAuthMessage: "auth.authenticate_to_encrypt".tr(),
                    );
                  }
                  if (!authenticated) return;
                  await encryptDataAndLogin(
                    widget.authorizationCredentials,
                  );
                  if (mounted) {
                    context.go(AppRoutes.home);
                  }
                },
                child: Text(
                  kIsWeb ? "auth.login".tr() : "auth.encrypt".tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
