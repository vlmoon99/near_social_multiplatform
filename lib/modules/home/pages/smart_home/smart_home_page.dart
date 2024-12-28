import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:near_social_mobile/config/constants.dart';
import 'package:near_social_mobile/config/theme.dart';
import 'package:near_social_mobile/routes/routes.dart';

class SmartHomePage extends StatelessWidget {
  const SmartHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount = screenWidth < 600
        ? 1
        : // mobile
        screenWidth < 900
            ? 2
            : // tablet
            3; // desktop

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              NearAssets.logoIcon,
              color: NEARColors.white,
              width: 35,
              height: 35,
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: NEARColors.blue,
      ),
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
            childAspectRatio: 1,
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 16.w,
          ),
          itemCount: 3,
          itemBuilder: (context, index) {
            final items = [
              {
                'title': 'SmartFeed',
                'color': NEARColors.blue,
                'icon': Icons.rss_feed,
                'callback': () {
                  HapticFeedback.lightImpact();
                  Modular.to.pushNamed(".${Routes.home.smartFeedPage}");
                }
              },
              {
                'title': 'Chats',
                'color': NEARColors.purple,
                'icon': Icons.chat_bubble,
                'callback': () {
                  HapticFeedback.lightImpact();
                  Modular.to.pushNamed(
                    ".${Routes.home.chatsPage}",
                  );
                }
              },
              {
                'title': 'Settings',
                'color': NEARColors.lilac,
                'icon': Icons.settings,
                'callback': () {
                  HapticFeedback.lightImpact();
                  Modular.to.pushNamed(
                    ".${Routes.home.settingsPage}",
                  );
                }
              },
            ];

            return _buildNavigationCard(
              context: context,
              title: items[index]['title'] as String,
              color: items[index]['color'] as Color,
              icon: items[index]['icon'] as IconData,
              callback: items[index]['callback'] as VoidCallback,
            );
          },
        ),
      ),
    );
  }

  Widget _buildNavigationCard({
    required BuildContext context,
    required String title,
    required Color color,
    required IconData icon,
    required VoidCallback callback,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    double titleFontSize = screenWidth < 600
        ? 40.sp
        : // mobile
        screenWidth < 900
            ? 16.sp
            : // tablet
            12.sp; // desktop

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: InkWell(
        onTap: () {
          callback();
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                color.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48.sp,
                color: AppColors.onPrimary,
              ),
              SizedBox(height: 16.h),
              Text(
                title,
                style: TextStyle(
                  color: AppColors.onPrimary,
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
