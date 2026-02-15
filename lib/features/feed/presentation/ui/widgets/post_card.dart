import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:near_social_mobile/core/config/animation_constants.dart';
import 'package:near_social_mobile/core/config/constants.dart';
import 'package:near_social_mobile/core/config/theme.dart';
import 'package:near_social_mobile/features/feed/data/models/post.dart';
import 'package:near_social_mobile/features/feed/presentation/ui/widgets/more_actions_for_post_button.dart';
import 'package:near_social_mobile/features/feed/presentation/ui/widgets/post_details_modal.dart';
import 'package:near_social_mobile/features/feed/presentation/ui/widgets/raw_text_to_content_formatter.dart';
import 'package:near_social_mobile/features/feed/presentation/providers/posts_controller.dart';
import 'package:near_social_mobile/features/people/presentation/providers/user_list_controller.dart';
import 'package:near_social_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:near_social_mobile/core/router/routes.dart';
import 'package:near_social_mobile/core/shared_widgets/scale_animated_iconbutton.dart';
import 'package:near_social_mobile/core/shared_widgets/near_network_image.dart';
import 'package:near_social_mobile/core/shared_widgets/tappable_scale_widget.dart';
import 'package:near_social_mobile/core/utils/date_to_string.dart';


class PostCard extends ConsumerWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.postsViewMode,
    this.postsOfAccountId,
    this.allowToNavigateToPostAuthorPage = true,
    this.allowToNavigateToReposterAuthorPage = true,
    this.maxContentHeight = 200,
  });
  final Post post;
  final PostsViewMode postsViewMode;
  final String? postsOfAccountId;
  final bool allowToNavigateToPostAuthorPage;
  final bool allowToNavigateToReposterAuthorPage;
  final double maxContentHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountId = ref.watch(authControllerProvider.select((s) => s.accountId));
    final currentPost = ref.watch(postsControllerProvider.select(
      (postsState) => postsState.getPost(
        authorId: post.authorInfo.accountId,
        blockHeight: post.blockHeight,
        postsViewMode: postsViewMode,
        postsOfAccountId: postsOfAccountId,
        reposterInfo: post.reposterInfo,
      ),
    ));

    return RepaintBoundary(
      child: GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: "Close",
          barrierColor: Colors.black.withValues(alpha: 0.4),
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (ctx, anim1, anim2) => PostDetailsModal(
            accountId: post.authorInfo.accountId,
            blockHeight: post.blockHeight,
            postsViewMode: postsViewMode,
            postsOfAccountId: postsOfAccountId,
            allowToNavigateToPostAuthorPage: allowToNavigateToPostAuthorPage,
          ),
          transitionBuilder: (ctx, anim1, anim2, child) {
            return Transform.scale(
              scale: 0.9 + (0.1 * anim1.value),
              child: Opacity(opacity: anim1.value, child: child),
            );
          },
        );
      },
      child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0).r,
            ),
            elevation: 5,
            child: Padding(
              padding: REdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      formatDateDependingOnCurrentTime(currentPost.date),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (currentPost.reposterInfo != null) ...[
                    TappableScaleWidget(
                      scaleDown: allowToNavigateToReposterAuthorPage
                          ? AppAnimations.profileTapScaleDown
                          : 1.0,
                      onTap: allowToNavigateToReposterAuthorPage
                          ? () async {
                              HapticFeedback.lightImpact();
                              await ref.read(userListControllerProvider.notifier)
                                  .addGeneralAccountInfoIfNotExists(
                                generalAccountInfo:
                                    currentPost.reposterInfo!.accountInfo,
                              );
                              if (context.mounted) {
                                context.push(
                                  "${AppRoutes.userProfile}?accountId=${currentPost.reposterInfo!.accountInfo.accountId}",
                                );
                              }
                            }
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3).r,
                        child: Text(
                          "Reposted by ${currentPost.reposterInfo?.accountInfo.name ?? ""} @${currentPost.reposterInfo!.accountInfo.accountId}",
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ),
                  ],
                  TappableScaleWidget(
                    scaleDown: allowToNavigateToPostAuthorPage
                        ? AppAnimations.profileTapScaleDown
                        : 1.0,
                    onTap: allowToNavigateToPostAuthorPage
                        ? () async {
                            HapticFeedback.lightImpact();
                            await ref.read(userListControllerProvider.notifier)
                                .addGeneralAccountInfoIfNotExists(
                              generalAccountInfo: currentPost.authorInfo,
                            );
                            if (context.mounted) {
                              context.push(
                                "${AppRoutes.userProfile}?accountId=${currentPost.authorInfo.accountId}",
                              );
                            }
                          }
                        : null,
                    child: SizedBox(
                      height: 37.h,
                      child: Row(
                        children: [
                          Container(
                            width: 35.h,
                            height: 35.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10).r,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: NearNetworkImage(
                              imageUrl:
                                  currentPost.authorInfo.profileImageLink,
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (currentPost.authorInfo.name != "")
                                  Text(
                                    currentPost.authorInfo.name,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                Text(
                                  "@${currentPost.authorInfo.accountId}",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: currentPost.authorInfo.name != ""
                                      ? const TextStyle(
                                          color: NEARColors.grey,
                                          fontSize: 13,
                                        )
                                      : const TextStyle(
                                          fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  ClipRect(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: maxContentHeight.h,
                      ),
                      child: Stack(
                        children: [
                          SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                RawTextToContentFormatter(
                                  rawText: currentPost.postBody.text.trim(),
                                  heroAnimForImages: false,
                                  imageHeight: .5.sh,
                                  responsive: false,
                                ),
                                if (currentPost.postBody.mediaLink != null)
                                  Center(
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(maxHeight: .5.sh),
                                      child: NearNetworkImage(
                                        imageUrl: currentPost.postBody.mediaLink!,
                                        boxFit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            height: 40.h,
                            child: IgnorePointer(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Theme.of(context).cardTheme.color?.withValues(alpha: 0) ??
                                          Theme.of(context).cardColor.withValues(alpha: 0),
                                      Theme.of(context).cardTheme.color ??
                                          Theme.of(context).cardColor,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Like button (blockchain write disabled)
                      ScaleAnimatedIconButtonWithCounter(
                        iconPath: NearAssets.likeIcon,
                        iconActivatedPath: NearAssets.activatedLikeIcon,
                        activated: currentPost.likeList.any(
                          (element) =>
                              element.accountId ==
                              accountId,
                        ),
                        onPressed: null,
                        count: currentPost.likeList.length,
                      ),
                      // Repost button (blockchain write disabled)
                      ScaleAnimatedIconButtonWithCounter(
                        iconPath: NearAssets.repostIcon,
                        count: currentPost.repostList.length,
                        activated: currentPost.repostList.any(
                          (element) =>
                              element.accountId ==
                              accountId,
                        ),
                        activatedColor: Colors.green,
                        onPressed: null,
                      ),
                      MoreActionsForPostButton(
                        post: currentPost,
                        postsViewMode: postsViewMode,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    ),
    );
  }
}
