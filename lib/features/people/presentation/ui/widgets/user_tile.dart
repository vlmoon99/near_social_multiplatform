import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_social_mobile/core/config/animation_constants.dart';
import 'package:near_social_mobile/core/config/constants.dart';
import 'package:near_social_mobile/core/config/theme.dart';
import 'package:near_social_mobile/features/people/data/models/user_list_state.dart';
import 'package:near_social_mobile/core/router/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:near_social_mobile/core/shared_widgets/near_network_image.dart';
import 'package:near_social_mobile/core/shared_widgets/tappable_scale_widget.dart';

class UserTile extends StatelessWidget {
  const UserTile({super.key, required this.user});

  final FullUserInfo user;

  @override
  Widget build(BuildContext context) {
    return TappableScaleWidget(
      scaleDown: AppAnimations.profileTapScaleDown,
      onTap: () {
        HapticFeedback.lightImpact();
        context.push(
          "${AppRoutes.userProfile}?accountId=${user.generalAccountInfo.accountId}",
        );
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0).r,
        ),
        child: Padding(
          padding: const EdgeInsets.all(15).r,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                child: Row(
                  children: [
                    Container(
                      width: 40.h,
                      height: 40.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10).r,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: NearNetworkImage(
                        imageUrl: user.generalAccountInfo.profileImageLink,
                        errorPlaceholder: Image.asset(
                          NearAssets.standartAvatar,
                          fit: BoxFit.cover,
                        ),
                        placeholder: Image.asset(
                          NearAssets.standartAvatar,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.h),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (user.generalAccountInfo.name != "")
                            Text(
                              user.generalAccountInfo.name,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          Text(
                            "@${user.generalAccountInfo.accountId}",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: user.generalAccountInfo.name != ""
                                ? const TextStyle(
                                    color: NEARColors.grey,
                                    fontSize: 13,
                                  )
                                : const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
