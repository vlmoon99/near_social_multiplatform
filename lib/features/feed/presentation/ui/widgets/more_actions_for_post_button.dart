import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:near_social_mobile/core/config/theme.dart';
import 'package:near_social_mobile/features/feed/data/models/post.dart';
import 'package:near_social_mobile/features/feed/presentation/providers/posts_controller.dart';
import 'package:near_social_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:near_social_mobile/core/providers/filter_controller.dart';
import 'package:near_social_mobile/core/providers/service_providers.dart';
import 'package:near_social_mobile/core/shared_widgets/app_toast.dart';
import 'package:near_social_mobile/core/shared_widgets/glassmorphism_components.dart';

class MoreActionsForPostButton extends ConsumerWidget {
  const MoreActionsForPostButton({
    super.key,
    required this.post,
    required this.postsViewMode,
  });

  final Post post;
  final PostsViewMode postsViewMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        showGlassActionSheet(
          context: context,
          actions: [
            _actionTile(
              icon: CupertinoIcons.share,
              label: "feed.share".tr(),
              isDark: isDark,
              onTap: () {
                HapticFeedback.lightImpact();
                final nearSocialApi = ref.read(nearSocialApiProvider);
                final urlOfPost = nearSocialApi.getUrlOfPost(
                  accountId: post.authorInfo.accountId,
                  blockHeight: post.blockHeight,
                );
                Clipboard.setData(ClipboardData(text: urlOfPost));
                Navigator.of(context).pop();
                showAppToast(context, "feed.post_url_copied".tr());
              },
            ),
            if (postsViewMode == PostsViewMode.main &&
                authState.accountId != post.authorInfo.accountId) ...[
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
              ),
              _actionTile(
                icon: CupertinoIcons.eye_slash,
                label: "feed.hide_post".tr(),
                isDark: isDark,
                isDestructive: true,
                onTap: () async {
                  Navigator.of(context).pop();
                  final confirmed = await showGlassConfirmDialog(
                    context: context,
                    title: "feed.hide_post_confirm".tr(),
                    content: "feed.hide_post_hint".tr(),
                  );
                  if (confirmed) {
                    ref.read(filterControllerProvider.notifier).hidePost(
                      accountId: authState.accountId,
                      accountIdToHide: post.authorInfo.accountId,
                      blockHeightToHide: post.blockHeight,
                    );
                  }
                },
              ),
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
              ),
              _actionTile(
                icon: CupertinoIcons.person_crop_circle_badge_minus,
                label: "feed.hide_user_posts".tr(),
                isDark: isDark,
                isDestructive: true,
                onTap: () async {
                  Navigator.of(context).pop();
                  final confirmed = await showGlassConfirmDialog(
                    context: context,
                    title: "feed.hide_user_posts_confirm".tr(),
                    content: "feed.hide_post_hint".tr(),
                  );
                  if (confirmed) {
                    ref.read(filterControllerProvider.notifier).hidePostsOfUser(
                      accountId: authState.accountId,
                      accountIdToHide: post.authorInfo.accountId,
                    );
                  }
                },
              ),
            ],
          ],
        );
      },
      child: const Padding(
        padding: EdgeInsets.all(8),
        child: Icon(Icons.more_horiz, color: NEARColors.grey),
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String label,
    required bool isDark,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    final color = isDestructive
        ? Colors.red
        : (isDark ? Colors.white : Colors.black);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
