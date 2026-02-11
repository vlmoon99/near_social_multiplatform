import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_social_mobile/features/settings/presentation/ui/widgets/bloked_user_tile.dart';
import 'package:near_social_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:near_social_mobile/core/providers/filter_controller.dart';
import 'package:near_social_mobile/core/shared_widgets/custom_button.dart';

class HiddenPostsUsersPage extends ConsumerWidget {
  const HiddenPostsUsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(filterControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Hidden posts users",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leadingWidth: 0,
        leading: const SizedBox.shrink(),
      ),
      body: Builder(
        builder: (context) {
          if (filterState.allHiddenPostsUsers.isEmpty) {
            return Center(
              child: Text("settings.no_hidden_posts".tr(),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(15).r,
            itemCount: filterState.allHiddenPostsUsers.length,
            itemBuilder: (context, index) {
              return BlockedUserTile(
                key: ValueKey(filterState.allHiddenPostsUsers
                    .elementAt(index)),
                accountIdOfBlockedUser:
                    filterState.allHiddenPostsUsers.elementAt(index),
                actionToDoTile: "Restore",
                actionToDoOnPressed: () {
                  showDialog(
                    context:
                        context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(
                            "Are you sure you want to restore all post of @${filterState.allHiddenPostsUsers.elementAt(index)} ?",
                            style: const TextStyle(fontSize: 22)),
                        actionsAlignment: MainAxisAlignment.spaceEvenly,
                        actions: [
                          CustomButton(
                            primary: true,
                            onPressed: () async {
                              final authInfo = ref.read(authControllerProvider);
                              ref.read(filterControllerProvider.notifier)
                                  .restorePostsOfUser(
                                accountId: authInfo.accountId,
                                accountIdToRestore: filterState
                                    .allHiddenPostsUsers
                                    .elementAt(index),
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
