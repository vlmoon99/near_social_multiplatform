import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_social_mobile/core/config/theme.dart';
import 'package:near_social_mobile/features/feed/data/models/comment.dart';
import 'package:near_social_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:near_social_mobile/core/providers/filter_controller.dart';
import 'package:near_social_mobile/core/shared_widgets/custom_button.dart';

class MoreActionsForCommentButton extends ConsumerWidget {
  const MoreActionsForCommentButton({
    super.key,
    required this.comment,
  });

  final Comment comment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ).r,
          ),
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(10.0).r,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (authState.accountId !=
                      comment.authorInfo.accountId) ...[
                    ListTile(
                      title: const Text(
                        "Block user",
                        style: TextStyle(
                            color: NEARColors.red, fontWeight: FontWeight.bold),
                      ),
                      leading:
                          const Icon(Icons.person_off, color: NEARColors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10).r,
                      ),
                      onTap: () async {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text(
                                  "Are you sure you want to block this user?",
                                  style: TextStyle(fontSize: 22)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 10),
                              content: const Text(
                                'You can always unblock user later through "Blocked Users" tab in the "Settings"',
                              ),
                              actionsAlignment: MainAxisAlignment.spaceEvenly,
                              actions: [
                                CustomButton(
                                  primary: true,
                                  onPressed: () async {
                                    ref.read(filterControllerProvider.notifier).blockUser(
                                      accountId: authState.accountId,
                                      blockedAccountId:
                                          comment.authorInfo.accountId,
                                    );
                                    Navigator.of(context).pop(true);
                                  },
                                  child: const Text(
                                    "Yes",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                CustomButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ).then(
                          (value) {
                            if (value != null && value) {
                              Navigator.of(context).pop();
                            }
                          },
                        );
                      },
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
      child: const Padding(
        padding: EdgeInsets.all(8),
        child: Icon(Icons.more_horiz, color: NEARColors.grey),
      ),
    );
  }
}
