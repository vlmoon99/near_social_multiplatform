import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:near_social_mobile/core/config/constants.dart';
import 'package:near_social_mobile/core/config/theme.dart';
import 'package:near_social_mobile/features/people/presentation/providers/user_list_controller.dart';
import 'package:near_social_mobile/core/router/routes.dart';
import 'package:near_social_mobile/core/shared_widgets/custom_button.dart';
import 'package:near_social_mobile/core/shared_widgets/near_network_image.dart';
import 'package:near_social_mobile/core/shared_widgets/spinner_loading_indicator.dart';

class BlockedUserTile extends ConsumerStatefulWidget {
  const BlockedUserTile({
    super.key,
    required this.accountIdOfBlockedUser,
    required this.actionToDoTile,
    required this.actionToDoOnPressed,
  });

  final String accountIdOfBlockedUser;
  final String actionToDoTile;
  final Function() actionToDoOnPressed;

  @override
  ConsumerState<BlockedUserTile> createState() => _BlockedUserTileState();
}

class _BlockedUserTileState extends ConsumerState<BlockedUserTile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      ref.read(userListControllerProvider.notifier).loadAndAddGeneralAccountInfoIfNotExists(
          accountId: widget.accountIdOfBlockedUser);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userListState = ref.watch(userListControllerProvider);
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0).r,
      ),
      child: GestureDetector(
        onTap: () {
          if (userListState.activeUsers
              .containsKey(widget.accountIdOfBlockedUser) ||
              userListState.cachedUsers
              .containsKey(widget.accountIdOfBlockedUser)) {
            HapticFeedback.lightImpact();
            context.push(
              "${AppRoutes.userProfile}?accountId=${widget.accountIdOfBlockedUser}",
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(15).r,
          child: SizedBox(
            height: 40.h,
            width: double.infinity,
            child: AnimatedSwitcher(
              duration: Durations.short4,
              child: (userListState.activeUsers
                          .containsKey(widget.accountIdOfBlockedUser) ||
                      userListState.cachedUsers
                          .containsKey(widget.accountIdOfBlockedUser))
                  ? Builder(builder: (context) {
                      final user = userListState
                          .getUserByAccountId(
                              accountId: widget.accountIdOfBlockedUser)!;
                      return Row(
                        children: [
                          Container(
                            width: 40.h,
                            height: 40.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10).r,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: NearNetworkImage(
                              imageUrl:
                                  user.generalAccountInfo.profileImageLink,
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
                                    maxLines: 1,
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
                                      : const TextStyle(
                                          fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10.h),
                          FittedBox(
                            child: CustomButton(
                              primary: true,
                              onPressed: widget.actionToDoOnPressed,
                              child: Text(
                                widget.actionToDoTile,
                              ),
                            ),
                          ),
                        ],
                      );
                    })
                  : const Center(
                      child: SpinnerLoadingIndicator(),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
