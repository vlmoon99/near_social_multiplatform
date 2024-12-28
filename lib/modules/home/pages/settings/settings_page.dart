import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_social_mobile/config/theme.dart';
import 'package:near_social_mobile/modules/home/vms/notifications/notifications_controller.dart';
import 'package:near_social_mobile/modules/home/vms/posts/posts_controller.dart';
import 'package:near_social_mobile/modules/vms/core/auth_controller.dart';
import 'package:near_social_mobile/modules/vms/core/filter_controller.dart';
import 'package:near_social_mobile/shared_widgets/home_menu_card.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> onLogoutTap(BuildContext context) async {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => CustomAlertDialog(),
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

  Size defineDialogDimensions(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (screenWidth >= 1200) {
      return Size(screenWidth * 0.6, screenHeight * 0.7);
    } else if (screenWidth >= 600) {
      return Size(screenWidth * 0.6, screenHeight * 0.5);
    } else {
      return Size(screenWidth * 0.8, screenHeight * 0.6);
    }
  }

  void showChatKeysDialog(BuildContext context) {
    final String chatKey = "chat-key-123456789-demonstration-key-xyz";
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final dialogSize = Size(screenWidth * 0.7, screenHeight * 0.5);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: dialogSize.width,
                height: dialogSize.height,
                decoration: BoxDecoration(
                  color: NEARColors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: Colors.black, width: 2.0),
                ),
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: NEARColors.blue),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          'Chat Keys',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: NEARColors.blue,
                          ),
                        ),
                        SizedBox(width: 48.0),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.black, width: 1.0),
                      ),
                      child: Text(
                        chatKey,
                        style: TextStyle(fontSize: 16.0, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: chatKey));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Key copied to clipboard!'),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        backgroundColor: NEARColors.blue,
                        textStyle: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Text('Copy Key'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void showNearSocialKeysDialog(BuildContext context) {
    const String publicKey = "near-social-public-key-123456789-xyz";
    final screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final dialogSize = defineDialogDimensions(context);
        double qrSize = screenWidth < 600
            ? dialogSize.width * 0.8
            : screenWidth < 900
                ? dialogSize.width * 0.6
                : dialogSize.width * 0.4;

        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: dialogSize.width,
                height: dialogSize.height,
                decoration: BoxDecoration(
                  color: NEARColors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: Colors.black, width: 2.0),
                ),
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: NEARColors.blue),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          'Near Social Keys',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: NEARColors.blue,
                          ),
                        ),
                        SizedBox(width: 48.0),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    QrImageView(
                      data: publicKey,
                      version: QrVersions.auto,
                      size: qrSize,
                      backgroundColor: Colors.white,
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Tap anywhere to go back.',
                      style: TextStyle(fontSize: 20.0, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
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
                  showChatKeysDialog(context);
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
                  showNearSocialKeysDialog(context);
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
