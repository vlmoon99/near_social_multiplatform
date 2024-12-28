import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:near_social_mobile/modules/home/pages/home_menu/widgets/home_menu_list_tile.dart';
import 'package:near_social_mobile/modules/home/vms/notifications/notifications_controller.dart';
import 'package:near_social_mobile/modules/home/vms/posts/posts_controller.dart';
import 'package:near_social_mobile/modules/vms/core/auth_controller.dart';
import 'package:near_social_mobile/modules/vms/core/filter_controller.dart';
import 'package:near_social_mobile/routes/routes.dart';
import 'package:near_social_mobile/shared_widgets/custom_button.dart';
import 'package:near_social_mobile/shared_widgets/home_menu_card.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> onKeyManagerTap() async {
    HapticFeedback.lightImpact();
    Modular.to.pushNamed(
      ".${Routes.home.keyManagerPage}",
    );
  }

  Future<void> onBlockedUsersTap() async {
    HapticFeedback.lightImpact();
    Modular.to.pushNamed(".${Routes.home.blockedUsersPage}");
  }

  Future<void> onHiddenContentTap() async {
    HapticFeedback.lightImpact();
    Modular.to.pushNamed(".${Routes.home.hiddenPostsPage}");
  }

  Future<void> onLogoutTap(BuildContext context) async {
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
          authController.logout();
          Modular.get<NotificationsController>().clear();
          Modular.get<FilterController>().clear();
          Modular.get<PostsController>().clear();
          Modular.to.navigate("/");
        }
      },
    );
  }

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
        child: MediaQuery.sizeOf(context).width > 600
            ? SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 20,
                        children: [
                          HomeMenuCard(
                            title: "Key Manager",
                            icon: SvgPicture.asset(
                              "assets/media/icons/key-icon.svg",
                              color: IconTheme.of(context).color,
                              height: IconTheme.of(context).size,
                            ),
                            onTap: onKeyManagerTap,
                          ),
                          HomeMenuCard(
                            icon: const Icon(Icons.person_off),
                            title: "Blocked Users",
                            onTap: onBlockedUsersTap,
                          ),
                          HomeMenuCard(
                            icon: const Icon(Icons.disabled_visible),
                            title: "Hidden Content",
                            onTap: onHiddenContentTap,
                          ),
                        ],
                      ),
                    ),
                    HomeMenuCard(
                      title: "Logout",
                      icon: const Icon(Icons.logout),
                      onTap: () => onLogoutTap(context),
                    )
                  ],
                ),
              )
            : Column(
                children: [
                  HomeMenuListTile(
                    title: "Key Manager",
                    tile: SvgPicture.asset(
                      "assets/media/icons/key-icon.svg",
                      color: IconTheme.of(context).color,
                      height: IconTheme.of(context).size,
                    ),
                    onTap: onKeyManagerTap,
                  ),
                  HomeMenuListTile(
                    tile: const Icon(Icons.person_off),
                    title: "Blocked Users",
                    onTap: onBlockedUsersTap,
                  ),
                  HomeMenuListTile(
                    tile: const Icon(Icons.disabled_visible),
                    title: "Hidden Content",
                    onTap: onHiddenContentTap,
                  ),
                  const Spacer(),
                  HomeMenuListTile(
                    title: "Logout",
                    tile: const Icon(Icons.logout),
                    onTap: () => onLogoutTap(context),
                  ),
                ],
              ),
      ),
    );
  }
}
