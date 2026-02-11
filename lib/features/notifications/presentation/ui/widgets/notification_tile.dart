import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:near_social_mobile/core/config/animation_constants.dart';
import 'package:near_social_mobile/core/config/constants.dart';
import 'package:near_social_mobile/core/config/theme.dart';
import 'package:near_social_mobile/features/notifications/data/models/notification.dart';
import 'package:near_social_mobile/features/feed/presentation/providers/posts_controller.dart';
import 'package:near_social_mobile/features/people/presentation/providers/user_list_controller.dart';
import 'package:near_social_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:near_social_mobile/core/router/routes.dart';
import 'package:near_social_mobile/core/shared_widgets/loading_page_with_after_navigation.dart';
import 'package:near_social_mobile/core/shared_widgets/near_network_image.dart';
import 'package:near_social_mobile/core/shared_widgets/tappable_scale_widget.dart';
import 'package:near_social_mobile/core/utils/date_to_string.dart';

class NotificationTile extends ConsumerWidget {
  const NotificationTile({
    super.key,
    required this.notification,
  });

  final Notification notification;

  bool get postOpeningNotification {
    return notification.notificationType.type == NotificationTypes.like ||
        notification.notificationType.type == NotificationTypes.repost ||
        notification.notificationType.type == NotificationTypes.comment;
  }

  String getFullActionDescription(Notification notification) {
    switch (notification.notificationType.type) {
      case NotificationTypes.mention:
        return "notifications.mentioned_you".tr(namedArgs: {"path": notification.notificationType.data["path"].toString()});
      case NotificationTypes.star:
        return "notifications.starred_your".tr(namedArgs: {"path": notification.notificationType.data["path"].toString()});
      case NotificationTypes.poke:
        return "notifications.poked_you".tr();
      case NotificationTypes.like:
        return "notifications.liked_your_post".tr(namedArgs: {"blockHeight": notification.notificationType.data["blockHeight"].toString()});
      case NotificationTypes.comment:
        return "notifications.commented_your_post".tr(namedArgs: {"blockHeight": notification.notificationType.data["blockHeight"].toString()});
      case NotificationTypes.follow:
        return "notifications.followed_you".tr();
      case NotificationTypes.unfollow:
        return "notifications.unfollowed_you".tr();
      case NotificationTypes.repost:
        return "notifications.reposted_your_post".tr(namedArgs: {"blockHeight": notification.notificationType.data["blockHeight"].toString()});
      case NotificationTypes.unknown:
        return "notifications.unknown".tr();
    }
  }

  Future<void> loadPostToTempPostsList(WidgetRef ref) async {
    final userListController = ref.read(userListControllerProvider.notifier);
    final authInfo = ref.read(authControllerProvider);
    final postsController = ref.read(postsControllerProvider.notifier);

    await userListController.loadAndAddGeneralAccountInfoIfNotExists(
        accountId: authInfo.accountId);

    final fullAccountInfo = ref.read(userListControllerProvider)
        .getUserByAccountId(accountId: authInfo.accountId);

    await postsController.loadAndAddSinglePostIfNotExistToTempList(
      accountInfo: fullAccountInfo.generalAccountInfo,
      blockHeight: notification.notificationType.data["blockHeight"],
    );
  }

  Future<void> navigateToAuthorPage(BuildContext context, WidgetRef ref) async {
    await ref.read(userListControllerProvider.notifier).addGeneralAccountInfoIfNotExists(
      generalAccountInfo: notification.authorInfo,
    );
    context.push(
        "${AppRoutes.userProfile}?accountId=${notification.authorInfo.accountId}");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TappableScaleWidget(
      scaleDown: AppAnimations.cardTapScaleDown,
      onTap: () async {
        HapticFeedback.lightImpact();
        if (!postOpeningNotification) {
          await navigateToAuthorPage(context, ref);
          return;
        }
        final authInfo = ref.read(authControllerProvider);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoadingPageWithNavigation(
              function: () async {
                await loadPostToTempPostsList(ref);
              },
              route:
                  "${AppRoutes.post}?accountId=${authInfo.accountId}&blockHeight=${notification.notificationType.data["blockHeight"]}&postsViewMode=${PostsViewMode.temporary.index}",
            ),
          ),
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
              Row(
                children: [
                  TappableScaleWidget(
                    scaleDown: AppAnimations.profileTapScaleDown,
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      await navigateToAuthorPage(context, ref);
                    },
                    child: Container(
                      width: 40.h,
                      height: 40.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10).r,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: NearNetworkImage(
                        imageUrl: notification.authorInfo.profileImageLink,
                        errorPlaceholder:
                            Image.asset(NearAssets.widgetPlaceholder),
                        placeholder: Image.asset(NearAssets.widgetPlaceholder),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.h),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TappableScaleWidget(
                          scaleDown: AppAnimations.profileTapScaleDown,
                          onTap: () async {
                            HapticFeedback.lightImpact();
                            await navigateToAuthorPage(context, ref);
                          },
                          child: Text(
                            notification.authorInfo.name != ""
                                ? notification.authorInfo.name
                                : "@${notification.authorInfo.accountId}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Text(getFullActionDescription(notification)),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time_filled,
                              size: 12.h,
                              color: NEARColors.grey,
                            ),
                            SizedBox(width: 5.h),
                            Text(
                              formatDateDependingOnCurrentTime(
                                  notification.date),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
