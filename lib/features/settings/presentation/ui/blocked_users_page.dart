import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_social_mobile/features/settings/presentation/ui/widgets/bloked_user_tile.dart';
import 'package:near_social_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:near_social_mobile/core/providers/filter_controller.dart';
import 'package:near_social_mobile/core/shared_widgets/custom_button.dart';

class BlockedUsersPage extends ConsumerWidget {
  const BlockedUsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(filterControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Blocked Users",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Builder(
        builder: (context) {
          final blockedUsers = filterState.blockedAccounts;
          if (blockedUsers.isEmpty) {
            return Center(
              child: Text("settings.no_blocked_users".tr(),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(15).r,
            itemCount: blockedUsers.length,
            itemBuilder: (context, index) {
              return BlockedUserTile(
                accountIdOfBlockedUser: blockedUsers[index],
                actionToDoTile: "Unblock",
                actionToDoOnPressed: () {
                  showDialog(
                    context:
                        context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(
                            "Are you sure you want to unblock @${blockedUsers[index]} ?",
                            style: const TextStyle(fontSize: 22)),
                        actionsAlignment: MainAxisAlignment.spaceEvenly,
                        actions: [
                          CustomButton(
                            primary: true,
                            onPressed: () async {
                              final authInfo = ref.read(authControllerProvider);
                              ref.read(filterControllerProvider.notifier).unblockUser(
                                accountId: authInfo.accountId,
                                blockedAccountId: blockedUsers[index],
                              );
                              Navigator.of(context).pop();
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
                              Navigator.of(context).pop();
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
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
