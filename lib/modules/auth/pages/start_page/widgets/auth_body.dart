import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_social_mobile/modules/auth/pages/utils/decrypt_data_and_login.dart';
import 'package:near_social_mobile/modules/home/vms/notifications/notifications_controller.dart';
import 'package:near_social_mobile/modules/home/vms/posts/posts_controller.dart';
import 'package:near_social_mobile/modules/vms/core/auth_controller.dart';
import 'package:near_social_mobile/modules/vms/core/filter_controller.dart';
import 'package:near_social_mobile/routes/routes.dart';
import 'package:near_social_mobile/services/local_auth_service.dart';
import 'package:near_social_mobile/shared_widgets/custom_button.dart';

class AuthenticatedBody extends StatelessWidget {
  const AuthenticatedBody(
      {super.key, required this.authenticatedStatusChanged});

  final void Function(bool authenticated) authenticatedStatusChanged;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        await decryptDataAndLogin();
        Modular.to.navigate(Routes.home.getModule());
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
                            'Please authenticate to decrypt data',
                      );
                    }
                    if (!authenticated) return;
                    await decryptDataAndLogin();
                    Modular.to.navigate(Routes.home.getModule());
                  },
                  child: const Text(
                    "Decrypt",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                CustomButton(
                  onPressed: () async {
                    Modular.get<AuthController>().logout().then(
                      (_) {
                        authenticatedStatusChanged(false);
                        Modular.tryGet<NotificationsController>()?.clear();
                        Modular.tryGet<FilterController>()?.clear();
                        Modular.tryGet<PostsController>()?.clear();
                      },
                    );
                  },
                  child: const Text(
                    "Logout",
                    style: TextStyle(
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
