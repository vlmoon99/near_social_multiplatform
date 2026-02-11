import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:near_social_mobile/core/config/constants.dart';
import 'package:near_social_mobile/core/config/theme.dart';
import 'package:near_social_mobile/features/feed/data/models/post.dart';
import 'package:near_social_mobile/features/feed/presentation/providers/posts_controller.dart';
import 'package:near_social_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:near_social_mobile/core/providers/filter_controller.dart';
import 'package:near_social_mobile/core/providers/service_providers.dart';
import 'package:near_social_mobile/core/shared_widgets/custom_button.dart';

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
                  ListTile(
                    title: Text("feed.share".tr(),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    leading: SvgPicture.asset(
                      NearAssets.shareIcon,
                      theme: const SvgTheme(
                        currentColor: NEARColors.slate,
                      ),
                      width: 20.h,
                      height: 20.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10).r,
                    ),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      final nearSocialApi = ref.read(nearSocialApiProvider);
                      final urlOfPost = nearSocialApi.getUrlOfPost(
                        accountId: post.authorInfo.accountId,
                        blockHeight: post.blockHeight,
                      );
                      Clipboard.setData(ClipboardData(text: urlOfPost));
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("feed.post_url_copied".tr()),
                        ),
                      );
                    },
                  ),
                  if (postsViewMode == PostsViewMode.main &&
                      authState.accountId !=
                          post.authorInfo.accountId) ...[
                    ListTile(
                      title: const Text(
                        "Hide this post",
                        style: TextStyle(
                            color: NEARColors.red, fontWeight: FontWeight.bold),
                      ),
                      leading: const Icon(Icons.remove_red_eye,
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
                                  "Are you sure you want to hide this post?",
                                  style: TextStyle(fontSize: 22)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 10),
                              content: const Text(
                                'You can always restore them later through "Hidden content" tab in the "Settings"',
                              ),
                              actionsAlignment: MainAxisAlignment.spaceEvenly,
                              actions: [
                                CustomButton(
                                  primary: true,
                                  onPressed: () async {
                                    ref.read(filterControllerProvider.notifier).hidePost(
                                      accountId: authState.accountId,
                                      accountIdToHide:
                                          post.authorInfo.accountId,
                                      blockHeightToHide:
                                          post.blockHeight,
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
                    ListTile(
                      title: const Text(
                        "Hide posts of this user",
                        style: TextStyle(
                            color: NEARColors.red, fontWeight: FontWeight.bold),
                      ),
                      leading: const Icon(Icons.person_remove,
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
                                  "Are you sure you want to hide posts of this user?",
                                  style: TextStyle(fontSize: 22)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 10),
                              content: const Text(
                                'You can always restore them later through "Hidden content" tab in the "Settings"',
                              ),
                              actionsAlignment: MainAxisAlignment.spaceEvenly,
                              actions: [
                                CustomButton(
                                  primary: true,
                                  onPressed: () async {
                                    ref.read(filterControllerProvider.notifier)
                                        .hidePostsOfUser(
                                      accountId: authState.accountId,
                                      accountIdToHide:
                                          post.authorInfo.accountId,
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
                  ]
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
