import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_social_mobile/modules/home/pages/home_menu/widgets/home_menu_list_tile.dart';
import 'package:near_social_mobile/modules/home/vms/notifications/notifications_controller.dart';
import 'package:near_social_mobile/modules/home/vms/posts/posts_controller.dart';
import 'package:near_social_mobile/modules/vms/core/auth_controller.dart';
import 'package:near_social_mobile/modules/vms/core/filter_controller.dart';
import 'package:near_social_mobile/routes/routes.dart';
import 'package:near_social_mobile/services/notification_subscription_service.dart';
import 'package:near_social_mobile/shared_widgets/custom_button.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leadingWidth: 0,
        leading: const SizedBox.shrink(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20).r,
        child: Column(
          children: [
            HomeMenuListTile(
              tile: const Icon(Icons.person_off),
              title: "Blocked Users",
              onTap: () {
                HapticFeedback.lightImpact();
                Modular.to.pushNamed(".${Routes.home.blockedUsersPage}");
              },
            ),
            SizedBox(height: 15.h),
            HomeMenuListTile(
              tile: const Icon(Icons.disabled_visible),
              title: "Hidden Content",
              onTap: () {
                HapticFeedback.lightImpact();
                Modular.to.pushNamed(".${Routes.home.hiddenPostsPage}");
              },
            ),
            const Spacer(),
            HomeMenuListTile(
              title: "Logout",
              tile: const Icon(Icons.logout),
              onTap: () async {
                HapticFeedback.lightImpact();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text(
                      "Are you sure you want to logout?",
                      textAlign: TextAlign.center,
                    ),
                    actionsAlignment: MainAxisAlignment.spaceEvenly,
                    actions: [
                      CustomButton(
                        primary: true,
                        onPressed: () {
                          Modular.to.pop(true);
                        },
                        child: const Text(
                          "Yes",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      CustomButton(
                        onPressed: () {
                          Modular.to.pop(false);
                        },
                        child: const Text(
                          "No",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).then(
                  (value) async {
                    if (value != null && value) {
                      final authController = Modular.get<AuthController>();
                      if (!kIsWeb) {
                        Modular.get<NotificationSubscriptionService>()
                            .unsubscribeFromNotifications(
                                authController.state.accountId);
                      }
                      authController.logout();
                      await FirebaseAuth.instance.signOut();
                      Modular.get<NotificationsController>().clear();
                      Modular.get<FilterController>().clear();
                      Modular.get<PostsController>().clear();
                      Modular.to.navigate("/");
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
