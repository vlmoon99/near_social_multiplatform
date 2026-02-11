import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_social_mobile/core/config/animation_constants.dart';
import 'package:near_social_mobile/core/config/constants.dart';
import 'package:near_social_mobile/features/feed/data/models/comment.dart';
import 'package:near_social_mobile/features/feed/data/models/post.dart';
// import 'package:near_social_mobile/features/feed/presentation/ui/widgets/create_comment_dialog_body.dart';
import 'package:near_social_mobile/features/feed/presentation/ui/widgets/more_actions_for_comment_button.dart';
import 'package:near_social_mobile/features/feed/presentation/ui/widgets/raw_text_to_content_formatter.dart';
import 'package:near_social_mobile/features/feed/presentation/providers/posts_controller.dart';
import 'package:near_social_mobile/features/people/presentation/providers/user_list_controller.dart';
import 'package:near_social_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:near_social_mobile/core/router/routes.dart';
import 'package:near_social_mobile/core/shared_widgets/image_full_screen_page.dart';
import 'package:near_social_mobile/core/shared_widgets/scale_animated_iconbutton.dart';
import 'package:near_social_mobile/core/shared_widgets/tappable_scale_widget.dart';
import 'package:near_social_mobile/core/shared_widgets/two_states_iconbutton.dart';
import 'package:near_social_mobile/core/shared_widgets/near_network_image.dart';
import 'package:near_social_mobile/core/utils/date_to_string.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CommentCard extends ConsumerWidget {
  const CommentCard({
    super.key,
    required this.comment,
    required this.post,
    required this.postsViewMode,
    this.postsOfAccountId,
  });

  final Comment comment;
  final Post post;
  final PostsViewMode postsViewMode;
  final String? postsOfAccountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.read(authControllerProvider);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0).r,
      ),
      elevation: 5,
      child: RPadding(
        padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                formatDateDependingOnCurrentTime(comment.date),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ),
            TappableScaleWidget(
              scaleDown: AppAnimations.profileTapScaleDown,
              onTap: () async {
                HapticFeedback.lightImpact();
                await ref.read(userListControllerProvider.notifier)
                    .addGeneralAccountInfoIfNotExists(
                  generalAccountInfo: comment.authorInfo,
                );
                context.push(
                  "${AppRoutes.userProfile}?accountId=${comment.authorInfo.accountId}",
                );
              },
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
                        imageUrl: comment.authorInfo.profileImageLink,
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
                          if (comment.authorInfo.name != "")
                            Text(
                              comment.authorInfo.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          Text(
                            "@${comment.authorInfo.accountId}",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.h),
            RawTextToContentFormatter(
              rawText: comment.commentBody.text.trim(),
              imageHeight: .5.sh,
            ),
            if (comment.commentBody.mediaLink != null) ...[
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImageFullScreen(
                        imageUrl: comment.commentBody.mediaLink!,
                      ),
                    ),
                  );
                },
                child: Align(
                  alignment: Alignment.center,
                  child: Hero(
                    tag: comment.commentBody.mediaLink!,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: .5.sh),
                      child: NearNetworkImage(
                        imageUrl: comment.commentBody.mediaLink!,
                        boxFit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Comment reply button disabled (blockchain write)
                TwoStatesIconButton(
                  iconPath: NearAssets.commentIcon,
                  onPressed: null,
                ),
                // Like button disabled (blockchain write)
                ScaleAnimatedIconButtonWithCounter(
                  iconPath: NearAssets.likeIcon,
                  iconActivatedPath: NearAssets.activatedLikeIcon,
                  count: comment.likeList.length,
                  activated: comment.likeList.any(
                    (element) =>
                        element.accountId == authState.accountId,
                  ),
                  onPressed: null,
                ),
                if (post.authorInfo.accountId != authState.accountId)
                  MoreActionsForCommentButton(comment: comment),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
