import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:near_social_mobile/core/config/constants.dart';
import 'package:near_social_mobile/core/config/theme.dart';
import 'package:near_social_mobile/core/exceptions/exceptions.dart';
import 'package:near_social_mobile/core/providers/service_providers.dart';
import 'package:near_social_mobile/features/people/presentation/ui/widgets/donation_dialog.dart';
import 'package:near_social_mobile/features/people/presentation/ui/widgets/more_actions_for_user_button.dart';
import 'package:near_social_mobile/features/feed/presentation/ui/widgets/raw_text_to_content_formatter.dart';
import 'package:near_social_mobile/features/feed/presentation/providers/posts_controller.dart';
import 'package:near_social_mobile/features/people/presentation/providers/user_list_controller.dart';
import 'package:near_social_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:near_social_mobile/core/providers/filter_controller.dart';
import 'package:near_social_mobile/features/auth/data/models/auth_info.dart';
import 'package:near_social_mobile/core/shared_widgets/custom_button.dart';
import 'package:near_social_mobile/core/shared_widgets/custom_refresh_indicator.dart';
import 'package:near_social_mobile/core/shared_widgets/expandable_wiget.dart';
import 'package:near_social_mobile/core/shared_widgets/image_full_screen_page.dart';
import 'package:near_social_mobile/core/shared_widgets/near_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class UserPageMainInfo extends ConsumerWidget {
  const UserPageMainInfo({
    super.key,
    required this.accountIdOfUser,
    required this.userIsBlocked,
  });

  final String accountIdOfUser;
  final bool userIsBlocked;

  List<Widget> linkTreeList({required Map<String, dynamic> linkTree}) {
    final List<Widget> linkTreeList = linkTree.entries.map((pair) {
      if (pair.key == "twitter") {
        return TextButton.icon(
          onPressed: () {
            HapticFeedback.lightImpact();
            final url = Uri.parse("https://twitter.com/${pair.value}");
            launchUrl(url);
          },
          icon: SvgPicture.asset(
            "assets/media/icons/twitter_icon.svg",
            height: 28,
          ),
          label: Text(pair.key),
        );
      } else if (pair.key == "github") {
        return TextButton.icon(
          onPressed: () {
            HapticFeedback.lightImpact();
            final url = Uri.parse("https://github.com/${pair.value}");
            launchUrl(url);
          },
          icon: SvgPicture.asset(
            "assets/media/icons/github_icon.svg",
            height: 28,
          ),
          label: Text(pair.key),
        );
      } else if (pair.key == "telegram") {
        return TextButton.icon(
          onPressed: () {
            HapticFeedback.lightImpact();
            final url = Uri.parse("https://t.me/${pair.value}");
            launchUrl(url);
          },
          icon: SvgPicture.asset(
            "assets/media/icons/telegram_icon.svg",
            height: 28,
          ),
          label: Text(pair.key),
        );
      } else if (pair.key == "website") {
        return TextButton.icon(
          onPressed: () {
            HapticFeedback.lightImpact();
            final url = Uri.parse("https://${pair.value}");
            launchUrl(url);
          },
          icon: SvgPicture.asset(
            "assets/media/icons/website_icon.svg",
            height: 28,
          ),
          label: Text(pair.key),
        );
      }
      return const SizedBox();
    }).toList();
    return linkTreeList;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final userListState = ref.watch(userListControllerProvider);
    final filterState = ref.watch(filterControllerProvider);

    final user = userListState.getUserByAccountId(accountId: accountIdOfUser);
    return Column(
      children: [
        CustomRefreshIndicator(
          onRefresh: () async {
            await ref
                .read(userListControllerProvider.notifier)
                .reloadUserInfo(accountId: accountIdOfUser);
            await ref.read(postsControllerProvider.notifier).updatePostsOfAccount(
              postsOfAccountId: accountIdOfUser,
              filters: filterState,
            );
            if (user.nfts != null) {
              await ref
                  .read(userListControllerProvider.notifier)
                  .loadNftsOfAccount(accountId: accountIdOfUser);
            }
            // Widget list loading removed (feature disabled)
          },
          child: SizedBox(
            height: .30.sh,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                GestureDetector(
                  onTap: () {
                    if (user
                        .generalAccountInfo.backgroundImageLink.isEmpty) {
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageFullScreen(
                          imageUrl:
                              user.generalAccountInfo.backgroundImageLink,
                        ),
                      ),
                    );
                  },
                  child: SizedBox(
                    height: .25.sh,
                    width: double.infinity,
                    child: NearNetworkImage(
                      imageUrl:
                          user.generalAccountInfo.backgroundImageLink,
                      errorPlaceholder:
                          Container(color: AppColors.lightSurface),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 20.h,
                  width: .2.sh,
                  height: .2.sh,
                  child: GestureDetector(
                    onTap: () {
                      if (user
                          .generalAccountInfo.profileImageLink.isEmpty) {
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageFullScreen(
                            imageUrl:
                                user.generalAccountInfo.profileImageLink,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: REdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: ClipOval(
                        child: NearNetworkImage(
                          imageUrl:
                              user.generalAccountInfo.profileImageLink,
                          errorPlaceholder: Image.asset(
                            NearAssets.standartAvatar,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (accountIdOfUser != authState.accountId &&
                    !userIsBlocked)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10)
                          .r,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: NEARColors.black,
                          foregroundColor: NEARColors.white,
                          disabledForegroundColor: NEARColors.white,
                          disabledBackgroundColor: NEARColors.black,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8).r,
                            side: const BorderSide(
                              color: NEARColors.white,
                              width: 2,
                            ),
                          ),
                        ),
                        onPressed: () async {
                          HapticFeedback.lightImpact();
                          showDialog(
                            context: context,
                            builder: (context) {
                              return DonationDialog(
                                receiverId: accountIdOfUser,
                              );
                            },
                          );
                        },
                        child: const Text(
                          "Donate",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Padding(
          padding: REdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      user.generalAccountInfo.name != ""
                          ? user.generalAccountInfo.name
                          : "No Name",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (user.generalAccountInfo.accountId !=
                      authState.accountId)
                    MoreActionsForUserButton(
                      userAccountId: user.generalAccountInfo.accountId,
                    ),
                ],
              ),
              SizedBox(height: 5.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.person_fill,
                    size: 16.h,
                  ),
                  SizedBox(width: 5.h),
                  Flexible(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Clipboard.setData(
                          ClipboardData(
                            text: user.generalAccountInfo.accountId,
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                "AccountId ${user.generalAccountInfo.accountId} copied to clipboard"),
                          ),
                        );
                      },
                      child: Text(
                        "@${user.generalAccountInfo.accountId}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.h),
                  if (user.followings != null &&
                      user.followings!.any(
                        (element) =>
                            element.accountId ==
                            authState.accountId,
                      ))
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ).r,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5).r,
                        color: NEARColors.slate,
                      ),
                      child: const Text(
                        "Follows you",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          color: NEARColors.white,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 5.h),
              if (authState.accountId != accountIdOfUser &&
                  !userIsBlocked) ...[
                Row(
                  children: [
                    if (user.followers != null)
                      RPadding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Builder(
                          builder: (_) {
                            final inFollowerList = user.followers!.any(
                              (follower) =>
                                  follower.accountId ==
                                  authState.accountId,
                            );
                            return CustomButton(
                              primary: !inFollowerList,
                              onPressed: () {
                                if (inFollowerList) {
                                  requestToUnfollowAccount(context, ref);
                                } else {
                                  requestToFollowAccount(context, ref);
                                }
                              },
                              child: Text(
                                inFollowerList ? "Following" : "Follow",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    CustomButton(
                      primary: true,
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text("people.poking_user".tr())));
                        try {
                          if (await ref
                                  .read(authControllerProvider.notifier)
                                  .getActivationStatus() !=
                              AccountActivationStatus.activated) {
                            throw AccountNotActivatedException();
                          }
                          await ref.read(nearSocialApiProvider)
                              .pokeAccount(
                            accountIdToPoke: accountIdOfUser,
                            accountId: authState.accountId,
                            publicKey: authState.publicKey,
                            privateKey: authState.privateKey,
                          )
                              .then((_) {
                            ScaffoldMessenger.of(context)
                                .hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("people.poked_user".tr(namedArgs: {"accountId": accountIdOfUser})),
                              ),
                            );
                          });
                        } catch (err) {
                          if (err is Exception) {
                            throw Exception(
                                "Failed to poke $accountIdOfUser");
                          } else {
                            rethrow;
                          }
                        }
                      },
                      child: const Text(
                        "👈 Poke",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.h),
              ],
              Row(
                children: [
                  Text.rich(
                    TextSpan(
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                      children: [
                        TextSpan(
                          text: user.followings != null
                              ? user.followings?.length.toString()
                              : "?",
                          style: const TextStyle(
                              fontWeight: FontWeight.w700),
                        ),
                        const TextSpan(text: " Following"),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.h),
                  Text.rich(
                    TextSpan(
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                      children: [
                        TextSpan(
                          text: user.followers != null
                              ? user.followers?.length.toString()
                              : "?",
                          style: const TextStyle(
                              fontWeight: FontWeight.w700),
                        ),
                        const TextSpan(text: " Followers"),
                      ],
                    ),
                  ),
                ],
              ),
              if (user.generalAccountInfo.linktree.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...linkTreeList(
                        linkTree: user.generalAccountInfo.linktree),
                    SizedBox(height: 10.h),
                  ],
                ),
              if (user.generalAccountInfo.tags.isNotEmpty) ...[
                SizedBox(height: 5.h),
                Wrap(
                  spacing: 5.h,
                  runSpacing: 5.h,
                  children: [
                    ...user.generalAccountInfo.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: AppColors.lightSurface.withOpacity(.5),
                        ),
                        child: Text(
                          "#$tag",
                          style: const TextStyle(
                            color: AppColors.onlightSurface,
                          ),
                        ),
                      );
                    })
                  ],
                )
              ],
              if (user.userTags != null && user.userTags!.isNotEmpty) ...[
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 5.h,
                  runSpacing: 5.h,
                  children: [
                    ...user.userTags!.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        child: Text(
                          "#$tag",
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      );
                    })
                  ],
                ),
              ],
              if (user.generalAccountInfo.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10).r,
                  child: CollapseWidget(
                    children: RawTextToContentFormatter(
                      rawText: user.generalAccountInfo.description,
                      imageHeight: 0.2.sh,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<dynamic> requestToUnfollowAccount(
    BuildContext context,
    WidgetRef ref,
  ) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text("people.unfollow_confirm".tr(namedArgs: {"accountId": accountIdOfUser}),
              style: const TextStyle(fontSize: 16)),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            CustomButton(
              primary: true,
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await ref.read(userListControllerProvider.notifier).unfollowAccount(
                    accountIdToUnfollow: accountIdOfUser,
                  );
                } catch (err) {
                  if (err is Exception) {
                    throw Exception("Failed to unfollow $accountIdOfUser");
                  } else {
                    rethrow;
                  }
                }
              },
              child: Text(
                "common.yes".tr(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            CustomButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "common.no".tr(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> requestToFollowAccount(
    BuildContext context,
    WidgetRef ref,
  ) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text("people.follow_confirm".tr(namedArgs: {"accountId": accountIdOfUser}),
              style: const TextStyle(fontSize: 16)),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            CustomButton(
              primary: true,
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await ref.read(userListControllerProvider.notifier).followAccount(
                    accountIdToFollow: accountIdOfUser,
                  );
                } catch (err) {
                  if (err is Exception) {
                    throw Exception("Failed to follow $accountIdOfUser");
                  } else {
                    rethrow;
                  }
                }
              },
              child: Text(
                "common.yes".tr(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            CustomButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "common.no".tr(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
