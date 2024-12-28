// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_modular/flutter_modular.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:near_social_mobile/config/theme.dart';
// import 'package:near_social_mobile/modules/home/pages/home_menu/widgets/home_menu_list_tile.dart';
// import 'package:near_social_mobile/modules/home/vms/notifications/notifications_controller.dart';
// import 'package:near_social_mobile/modules/home/vms/posts/posts_controller.dart';
// import 'package:near_social_mobile/modules/vms/core/auth_controller.dart';
// import 'package:near_social_mobile/modules/vms/core/filter_controller.dart';
// import 'package:near_social_mobile/routes/routes.dart';
// import 'package:near_social_mobile/shared_widgets/custom_button.dart';
// import 'package:near_social_mobile/shared_widgets/home_menu_card.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class SettingsPage extends StatelessWidget {
//   const SettingsPage({super.key});

//   Future<void> onKeyManagerTap() async {
//     HapticFeedback.lightImpact();
//     Modular.to.pushNamed(
//       ".${Routes.home.keyManagerPage}",
//     );
//   }

//   Future<void> onBlockedUsersTap() async {
//     HapticFeedback.lightImpact();
//     Modular.to.pushNamed(".${Routes.home.blockedUsersPage}");
//   }

//   Future<void> onHiddenContentTap() async {
//     HapticFeedback.lightImpact();
//     Modular.to.pushNamed(".${Routes.home.hiddenPostsPage}");
//   }

// Future<void> onLogoutTap(BuildContext context) async {
//   HapticFeedback.lightImpact();
//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       title: const Text(
//         "Are you sure you want to logout?",
//         textAlign: TextAlign.center,
//       ),
//       actionsAlignment: MainAxisAlignment.spaceEvenly,
//       actions: [
//         CustomButton(
//           primary: true,
//           onPressed: () {
//             Modular.to.pop(true);
//           },
//           child: const Text(
//             "Yes",
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         CustomButton(
//           onPressed: () {
//             Modular.to.pop(false);
//           },
//           child: const Text(
//             "No",
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ],
//     ),
//   ).then(
//     (value) async {
//       if (value != null && value) {
//         final authController = Modular.get<AuthController>();
//         authController.logout();
//         await Supabase.instance.client.auth.signOut();
//         Modular.get<NotificationsController>().clear();
//         Modular.get<FilterController>().clear();
//         Modular.get<PostsController>().clear();
//         Modular.to.navigate("/");
//       }
//     },
//   );
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: NEARColors.blue,
//         title: const Text(
//           "Settings",
//           style: TextStyle(
//             fontSize: 20,
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20).r,
//         child: MediaQuery.sizeOf(context).width > 600
//             ? SizedBox(
//                 width: double.infinity,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Expanded(
//                       child: Wrap(
//                         alignment: WrapAlignment.center,
//                         spacing: 20,
//                         children: [
//                           // HomeMenuCard(
//                           //   title: "Key Manager",
//                           //   icon: SvgPicture.asset(
//                           //     "assets/media/icons/key-icon.svg",
//                           //     color: IconTheme.of(context).color,
//                           //     height: IconTheme.of(context).size,
//                           //   ),
//                           //   onTap: onKeyManagerTap,
//                           // ),
//                           // HomeMenuCard(
//                           //   icon: const Icon(Icons.person_off),
//                           //   title: "Blocked Users",
//                           //   onTap: onBlockedUsersTap,
//                           // ),
//                           // HomeMenuCard(
//                           //   icon: const Icon(Icons.disabled_visible),
//                           //   title: "Hidden Content",
//                           //   onTap: onHiddenContentTap,
//                           // ),
//                         ],
//                       ),
//                     ),
//                     HomeMenuCard(
//                       title: "Logout",
//                       icon: const Icon(Icons.logout),
//                       onTap: () => onLogoutTap(context),
//                     )
//                   ],
//                 ),
//               )
//             : Column(
//                 children: [
//                   HomeMenuListTile(
//                     title: "Key Manager",
//                     tile: SvgPicture.asset(
//                       "assets/media/icons/key-icon.svg",
//                       color: IconTheme.of(context).color,
//                       height: IconTheme.of(context).size,
//                     ),
//                     onTap: onKeyManagerTap,
//                   ),
//                   HomeMenuListTile(
//                     tile: const Icon(Icons.person_off),
//                     title: "Blocked Users",
//                     onTap: onBlockedUsersTap,
//                   ),
//                   HomeMenuListTile(
//                     tile: const Icon(Icons.disabled_visible),
//                     title: "Hidden Content",
//                     onTap: onHiddenContentTap,
//                   ),
//                   const Spacer(),
//                   HomeMenuListTile(
//                     title: "Logout",
//                     tile: const Icon(Icons.logout),
//                     onTap: () => onLogoutTap(context),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:near_social_mobile/config/theme.dart';
import 'package:near_social_mobile/modules/home/vms/notifications/notifications_controller.dart';
import 'package:near_social_mobile/modules/home/vms/posts/posts_controller.dart';
import 'package:near_social_mobile/modules/vms/core/auth_controller.dart';
import 'package:near_social_mobile/modules/vms/core/filter_controller.dart';
import 'package:near_social_mobile/routes/routes.dart';
import 'package:near_social_mobile/shared_widgets/custom_button.dart';
import 'package:near_social_mobile/shared_widgets/home_menu_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> onLogoutTap(BuildContext context) async {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => CustomAlertDialog(),
      // builder: (context) => AlertDialog(
      //   backgroundColor: NEARColors.white,
      //   title: const Text(
      //     "Are you sure you want to logout?",
      //     textAlign: TextAlign.center,
      //   ),
      //   actionsAlignment: MainAxisAlignment.spaceEvenly,
      //   actions: [
      //     CustomButton(
      //       primary: true,
      //       onPressed: () {
      //         Modular.to.pop(true);
      //       },
      //       child: const Text(
      //         "Yes",
      //         style: TextStyle(
      //           fontWeight: FontWeight.bold,
      //         ),
      //       ),
      //     ),
      //     CustomButton(
      //       onPressed: () {
      //         Modular.to.pop(false);
      //       },
      //       child: const Text(
      //         "No",
      //         style: TextStyle(
      //           fontWeight: FontWeight.bold,
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
    ).then(
      (value) async {
        if (value != null && value) {
          final authController = Modular.get<AuthController>();
          authController.logout();
          await Supabase.instance.client.auth.signOut();
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
    final screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount = screenWidth < 600
        ? 1
        : screenWidth < 900
            ? 2
            : 3;

    double iconSize = screenWidth < 600
        ? 70.sp
        : screenWidth < 900
            ? 45.sp
            : 35.sp;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Settings',
              style: TextStyle(
                color: NEARColors.white,
              ),
            ),
          ],
        ),
        backgroundColor: NEARColors.blue,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: NEARColors.red,
        onPressed: () {
          HapticFeedback.lightImpact();
          // Add logout logic here
          // Modular.to.pushNamed(Routes.auth.loginPage);
          onLogoutTap(context);
        },
        icon: const Icon(
          Icons.logout,
          color: NEARColors.white,
        ),
        label: Text(
          'Logout',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: NEARColors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Container(
        color: AppColors.background,
        padding: EdgeInsets.only(
          top: 5.w,
          right: 20.w,
          left: 20.w,
          bottom: 5.w,
        ),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: screenWidth < 600 ? 1.5 : 1.2,
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 16.w,
          ),
          itemCount: 3,
          itemBuilder: (context, index) {
            final settingsOptions = [
              {
                'title': 'Get Chat Keys',
                'icon': Icon(
                  Icons.key,
                  size: iconSize,
                  color: NEARColors.blue,
                ),
                'callback': () {
                  HapticFeedback.lightImpact();
                  // Modular.to.pushNamed(Routes.settings.chatKeysPage);
                },
              },
              {
                'title': 'Get NEAR Social Key',
                'icon': Icon(
                  Icons.vpn_key,
                  size: iconSize,
                  color: NEARColors.purple,
                ),
                'callback': () {
                  HapticFeedback.lightImpact();
                  // Modular.to.pushNamed(Routes.settings.nearSocialKeyPage);
                },
              },
              {
                'title': 'System Management',
                'icon': Icon(
                  Icons.settings_system_daydream,
                  size: iconSize,
                  color: NEARColors.lilac,
                ),
                'callback': () {
                  HapticFeedback.lightImpact();
                  // Modular.to.pushNamed(Routes.settings.systemManagementPage);
                },
              },
            ];

            return HomeMenuCard(
              icon: settingsOptions[index]['icon'] as Widget,
              title: settingsOptions[index]['title'] as String,
              onTap: settingsOptions[index]['callback'] as VoidCallback,
            );
          },
        ),
      ),
    );
  }
}

class CustomAlertDialog extends StatelessWidget {
  const CustomAlertDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    double titleFontSize = screenWidth < 600
        ? 30.sp
        : screenWidth < 900
            ? 13.sp
            : 10.sp;

    return AlertDialog(
      backgroundColor: NEARColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: const BorderSide(
          color: Colors.black,
          width: 2.0,
        ),
      ),
      elevation: 4,
      title: Text(
        "Are you sure you want to logout?",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: titleFontSize,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: const BorderSide(
              color: Colors.black,
              width: 2.0,
            ),
          ),
          child: InkWell(
            onTap: () {
              Modular.to.pop(true);
            },
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 32.w,
                vertical: 16.h,
              ),
              decoration: BoxDecoration(
                color: NEARColors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Text(
                "Yes",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: titleFontSize * 0.8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: const BorderSide(
              color: Colors.black,
              width: 2.0,
            ),
          ),
          child: InkWell(
            onTap: () {
              Modular.to.pop(false);
            },
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 32.w,
                vertical: 16.h,
              ),
              decoration: BoxDecoration(
                color: NEARColors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Text(
                "No",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: titleFontSize * 0.8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
