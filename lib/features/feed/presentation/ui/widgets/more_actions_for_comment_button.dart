import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:near_social_mobile/core/config/theme.dart';
import 'package:near_social_mobile/features/feed/data/models/comment.dart';
import 'package:near_social_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:near_social_mobile/core/providers/filter_controller.dart';
import 'package:near_social_mobile/core/shared_widgets/glassmorphism_components.dart';

class MoreActionsForCommentButton extends ConsumerWidget {
  const MoreActionsForCommentButton({
    super.key,
    required this.comment,
  });

  final Comment comment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        if (authState.accountId == comment.authorInfo.accountId) return;
        HapticFeedback.lightImpact();
        showGlassActionSheet(
          context: context,
          actions: [
            _actionTile(
              icon: CupertinoIcons.person_crop_circle_badge_xmark,
              label: "people.block_user".tr(),
              isDark: isDark,
              isDestructive: true,
              onTap: () async {
                Navigator.of(context).pop();
                final confirmed = await showGlassConfirmDialog(
                  context: context,
                  title: "people.block_confirm".tr(),
                  content: "people.block_hint".tr(),
                );
                if (confirmed) {
                  ref.read(filterControllerProvider.notifier).blockUser(
                    accountId: authState.accountId,
                    blockedAccountId: comment.authorInfo.accountId,
                  );
                }
              },
            ),
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
