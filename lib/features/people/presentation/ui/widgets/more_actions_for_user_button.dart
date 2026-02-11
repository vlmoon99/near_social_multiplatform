import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_social_mobile/core/config/theme.dart';
import 'package:near_social_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:near_social_mobile/core/providers/filter_controller.dart';
import 'package:near_social_mobile/core/shared_widgets/custom_button.dart';

class MoreActionsForUserButton extends ConsumerStatefulWidget {
  const MoreActionsForUserButton({
    super.key,
    required this.userAccountId,
  });

  final String userAccountId;

  @override
  ConsumerState<MoreActionsForUserButton> createState() =>
      _MoreActionsForUserButtonState();
}

class _MoreActionsForUserButtonState extends ConsumerState<MoreActionsForUserButton> {
  final textEditingControllerForReport = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final filterState = ref.watch(filterControllerProvider);
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
                      widget.userAccountId) ...[
                    Builder(
                      builder: (context) {
                        final FiltersUtil filtersUtil = FiltersUtil(
                          filters: filterState,
                        );
                        final bool isBlocked =
                            filtersUtil.userIsBlocked(widget.userAccountId);
                        if (!isBlocked) {
                          return ListTile(
                            title: const Text(
                              "Block user",
                              style: TextStyle(
                                  color: NEARColors.red,
                                  fontWeight: FontWeight.bold),
                            ),
                            leading: const Icon(Icons.person_off,
                                color: NEARColors.red),
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
                                      'You will not be able to see user\'s posts, comments and notifications. You can always unblock user later through "Blocked Users" tab in the "Settings"',
                                    ),
                                    actionsAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    actions: [
                                      CustomButton(
                                        primary: true,
                                        onPressed: () async {
                                          ref.read(filterControllerProvider.notifier).blockUser(
                                            accountId:
                                                authState.accountId,
                                            blockedAccountId:
                                                widget.userAccountId,
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
                          );
                        } else {
                          return ListTile(
                            title: const Text(
                              "Unblock user",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            leading: const Icon(Icons.person_off,
                                color: NEARColors.grey),
                            onTap: () async {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text(
                                        "Are you sure you want to unblock this user?",
                                        style: TextStyle(fontSize: 22)),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 10),
                                    actionsAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    actions: [
                                      CustomButton(
                                        primary: true,
                                        onPressed: () async {
                                          ref.read(filterControllerProvider.notifier).unblockUser(
                                            accountId:
                                                authState.accountId,
                                            blockedAccountId:
                                                widget.userAccountId,
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
                          );
                        }
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
        child: Icon(Icons.more_vert, color: NEARColors.slate),
      ),
    );
  }
}
