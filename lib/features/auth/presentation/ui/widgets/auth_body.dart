import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:near_social_mobile/features/auth/services/decrypt_data_and_login.dart';
import 'package:near_social_mobile/features/notifications/presentation/providers/notifications_controller.dart';
import 'package:near_social_mobile/features/feed/presentation/providers/posts_controller.dart';
import 'package:near_social_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:near_social_mobile/core/providers/filter_controller.dart';
import 'package:near_social_mobile/core/router/routes.dart';
import 'package:near_social_mobile/core/services/local_auth_service.dart';
import 'package:near_social_mobile/core/shared_widgets/custom_button.dart';

class AuthenticatedBody extends ConsumerStatefulWidget {
  const AuthenticatedBody(
      {super.key, required this.authenticatedStatusChanged});

  final void Function(bool authenticated) authenticatedStatusChanged;

  @override
  ConsumerState<AuthenticatedBody> createState() => _AuthenticatedBodyState();
}

class _AuthenticatedBodyState extends ConsumerState<AuthenticatedBody> {
  bool _webLoginStarted = false;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb && !_webLoginStarted) {
      _webLoginStarted = true;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        await decryptDataAndLogin(ref);
        if (mounted) {
          context.go(AppRoutes.home);
        }
      });
    }

    return Center(
      child: kIsWeb
          ? const SizedBox.shrink()
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomButton(
                  primary: true,
                  onPressed: () async {
                    late bool authenticated;
                    if (kIsWeb) {
                      authenticated = true;
                    } else {
                      authenticated = await LocalAuthService().authenticate(
                        requestAuthMessage:
                            "auth.authenticate_to_decrypt".tr(),
                      );
                    }
                    if (!authenticated) return;
                    await decryptDataAndLogin(ref);
                    if (mounted) {
                      context.go(AppRoutes.home);
                    }
                  },
                  child: Text(
                    "auth.decrypt".tr(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                CustomButton(
                  onPressed: () async {
                    ref.read(authControllerProvider.notifier).logout().then(
                      (_) {
                        widget.authenticatedStatusChanged(false);
                        ref.read(notificationsControllerProvider.notifier).clear();
                        ref.read(filterControllerProvider.notifier).clear();
                        ref.read(postsControllerProvider.notifier).clear();
                      },
                    );
                  },
                  child: Text(
                    "common.logout".tr(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
