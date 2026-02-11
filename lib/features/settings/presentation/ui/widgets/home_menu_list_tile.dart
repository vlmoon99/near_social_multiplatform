import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_social_mobile/core/config/theme.dart';

class HomeMenuListTile extends StatelessWidget {
  const HomeMenuListTile({
    super.key,
    this.onTap,
    required this.tile,
    required this.title,
  });

  final Function()? onTap;
  final Widget tile;
  final String title;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10).r,
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              tile,
              SizedBox(width: 5.h),
              Text(
                title,
                style: const TextStyle(fontSize: 16),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right),
            ]),
          ),
          Container(
            height: 1,
            width: double.infinity,
            color: NEARColors.grey,
          )
        ],
      ),
    );
  }
}
