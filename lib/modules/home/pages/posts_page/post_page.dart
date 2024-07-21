import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_social_mobile/config/constants.dart';
import 'package:near_social_mobile/config/theme.dart';
import 'package:near_social_mobile/exceptions/exceptions.dart';
import 'package:near_social_mobile/modules/home/pages/posts_page/widgets/comment_card.dart';
import 'package:near_social_mobile/modules/home/pages/posts_page/widgets/create_comment_dialog_body.dart';
import 'package:near_social_mobile/modules/home/pages/posts_page/widgets/more_actions_for_post_button.dart';
import 'package:near_social_mobile/modules/home/pages/posts_page/widgets/raw_text_to_content_formatter.dart';
import 'package:near_social_mobile/modules/home/vms/posts/posts_controller.dart';
import 'package:near_social_mobile/modules/home/vms/users/user_list_controller.dart';
import 'package:near_social_mobile/modules/vms/core/auth_controller.dart';
import 'package:near_social_mobile/modules/vms/core/filter_controller.dart';
import 'package:near_social_mobile/routes/routes.dart';
import 'package:near_social_mobile/shared_widgets/custom_button.dart';
import 'package:near_social_mobile/shared_widgets/image_full_screen_page.dart';
import 'package:near_social_mobile/shared_widgets/scale_animated_iconbutton.dart';
import 'package:near_social_mobile/shared_widgets/spinner_loading_indicator.dart';
import 'package:near_social_mobile/shared_widgets/two_states_iconbutton.dart';
import 'package:near_social_mobile/shared_widgets/near_network_image.dart';
import 'package:rxdart/rxdart.dart';

class PostPage extends StatelessWidget {
  const PostPage({
    super.key,
    required this.accountId,
    required this.blockHeight,
    required this.postsViewMode,
    String? postsOfAccountId,
    this.allowToNavigateToPostAuthorPage = true,
  }) : postsOfAccountId = postsOfAccountId == '' ? null : postsOfAccountId;

  final String accountId;
  final int blockHeight;
  final PostsViewMode postsViewMode;
  final String? postsOfAccountId;
  final bool allowToNavigateToPostAuthorPage;

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Modular.get<AuthController>();
    final PostsController postsController = Modular.get<PostsController>();
    final FilterController filterController = Modular.get<FilterController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final posts = postsController.getPostsDueToPostsViewMode(
          postsViewMode, postsOfAccountId);
      if (posts.firstWhere((element) {
            return element.blockHeight == blockHeight &&
                element.authorInfo.accountId == accountId;
          }).commentList ==
          null) {
        postsController.loadCommentsOfPost(
          accountId: accountId,
          blockHeight: blockHeight,
          postsViewMode: postsViewMode,
          postsOfAccountId: postsOfAccountId,
        );
      } else {
        postsController.updateCommentsOfPost(
          accountId: accountId,
          blockHeight: blockHeight,
          postsViewMode: postsViewMode,
          postsOfAccountId: postsOfAccountId,
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder(
            stream: Rx.merge([postsController.stream, filterController.stream]),
            builder: (context, snapshot) {
              final posts = postsController.getPostsDueToPostsViewMode(
                  postsViewMode, postsOfAccountId);
              final post = posts.firstWhere((element) =>
                  element.blockHeight == blockHeight &&
                  element.authorInfo.accountId == accountId);
              return ListView(
                padding: REdgeInsets.all(15),
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(10).r,
                    onTap: allowToNavigateToPostAuthorPage
                        ? () async {
                            HapticFeedback.lightImpact();
                            await Modular.get<UserListController>()
                                .addGeneralAccountInfoIfNotExists(
                              generalAccountInfo: post.authorInfo,
                            );
                            Modular.to.pushNamed(
                              ".${Routes.home.userPage}?accountId=${post.authorInfo.accountId}",
                            );
                          }
                        : null,
                    child: SizedBox(
                      height: 36.h,
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
                              imageUrl: post.authorInfo.profileImageLink,
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
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (post.authorInfo.name != "")
                                  Text(
                                    post.authorInfo.name,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                Text(
                                  "@${post.authorInfo.accountId}",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: post.authorInfo.name != ""
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
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  RawTextToContentFormatter(
                    rawText: post.postBody.text.trim(),
                  ),
                  SizedBox(height: 10.h),
                  if (post.postBody.mediaLink != null) ...[
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                          Modular.routerDelegate.navigatorKey.currentContext!,
                          MaterialPageRoute(
                            builder: (context) => ImageFullScreen(
                              imageUrl: post.postBody.mediaLink!,
                            ),
                          ),
                        );
                      },
                      child: Hero(
                        tag: post.postBody.mediaLink!,
                        child: NearNetworkImage(
                          imageUrl: post.postBody.mediaLink!,
                        ),
                      ),
                    ),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TwoStatesIconButton(
                        iconPath: NearAssets.commentIcon,
                        onPressed: () async {
                          HapticFeedback.lightImpact();
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                child: CreateCommentDialog(
                                  postsViewMode: postsViewMode,
                                  postsOfAccountId: postsOfAccountId,
                                  descriptionTitle: Text.rich(
                                    style: TextStyle(fontSize: 14.sp),
                                    TextSpan(
                                      children: [
                                        const TextSpan(text: "Answer to "),
                                        TextSpan(
                                          text: "@${post.authorInfo.accountId}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  post: post,
                                ),
                              );
                            },
                          );
                        },
                      ),
                      ScaleAnimatedIconButtonWithCounter(
                        iconPath: NearAssets.likeIcon,
                        iconActivatedPath: NearAssets.activatedLikeIcon,
                        count: post.likeList.length,
                        activated: post.likeList.any(
                          (element) =>
                              element.accountId ==
                              authController.state.accountId,
                        ),
                        onPressed: () async {
                          HapticFeedback.lightImpact();
                          final String accountId =
                              authController.state.accountId;
                          final String publicKey =
                              authController.state.publicKey;
                          final String privateKey =
                              authController.state.privateKey;
                          try {
                            await postsController.likePost(
                              post: post,
                              accountId: accountId,
                              publicKey: publicKey,
                              privateKey: privateKey,
                              postsViewMode: postsViewMode,
                              postsOfAccountId: postsOfAccountId,
                            );
                          } catch (err) {
                            final exc = AppExceptions(
                              messageForUser: "Failed to like post",
                              messageForDev: err.toString(),
                              statusCode: AppErrorCodes.flutterchainError,
                            );
                            throw exc;
                          }
                        },
                      ),
                      ScaleAnimatedIconButtonWithCounter(
                        iconPath: NearAssets.repostIcon,
                        count: post.repostList.length,
                        activated: post.repostList.any(
                          (element) =>
                              element.accountId ==
                              authController.state.accountId,
                        ),
                        activatedColor: Colors.green,
                        onPressed: () async {
                          HapticFeedback.lightImpact();
                          final String accountId =
                              authController.state.accountId;
                          final String publicKey =
                              authController.state.publicKey;
                          final String privateKey =
                              authController.state.privateKey;
                          if (post.repostList.any(
                              (element) => element.accountId == accountId)) {
                            return;
                          }
                          await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Repost"),
                                content: const Text(
                                  "Are you sure you want to repost this post?",
                                ),
                                actionsAlignment: MainAxisAlignment.spaceEvenly,
                                actions: [
                                  CustomButton(
                                    primary: true,
                                    child: const Text(
                                      "Yes",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      Modular.to.pop(true);
                                    },
                                  ),
                                  CustomButton(
                                    child: const Text(
                                      "No",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      Modular.to.pop(false);
                                    },
                                  ),
                                ],
                              );
                            },
                          ).then(
                            (answer) async {
                              if (answer == null || !answer) {
                                return;
                              }
                              try {
                                await postsController.repostPost(
                                  post: post,
                                  accountId: accountId,
                                  publicKey: publicKey,
                                  privateKey: privateKey,
                                  postsViewMode: postsViewMode,
                                  postsOfAccountId: postsOfAccountId,
                                );
                              } catch (err) {
                                final exc = AppExceptions(
                                  messageForUser: "Failed to like post",
                                  messageForDev: err.toString(),
                                  statusCode: AppErrorCodes.flutterchainError,
                                );
                                throw exc;
                              }
                            },
                          );
                        },
                      ),
                      MoreActionsForPostButton(
                        post: post,
                        postsViewMode: postsViewMode,
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  if (post.commentList != null)
                    Builder(
                      builder: (context) {
                        final FiltersUtil filterUtil = FiltersUtil(
                          filters: filterController.state,
                        );
                        final comments = post.commentList!
                            .where((comment) => !filterUtil.commentIsHided(
                                comment.authorInfo.accountId,
                                comment.blockHeight))
                            .toList();
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: comments
                              .map(
                                (comment) => CommentCard(
                                  comment: comment,
                                  post: post,
                                  postsViewMode: postsViewMode,
                                  postsOfAccountId: postsOfAccountId,
                                ),
                              )
                              .toList(),
                        );
                      },
                    )
                  else ...[
                    const Center(
                      child: SpinnerLoadingIndicator(),
                    )
                  ],
                  // if (post.commentList != null) ...[
                  //   ...post.commentList!
                  //       .map(
                  //         (comment) => CommentCard(
                  //           comment: comment,
                  //           post: post,
                  //           postsViewMode: postsViewMode,
                  //           postsOfAccountId: postsOfAccountId,
                  //         ),
                  //       )
                  //       .toList()
                  // ] else ...[
                  //   const Center(
                  //     child: SpinnerLoadingIndicator(),
                  //   )
                  // ],
                ],
              );
            }),
      ),
    );
  }
}
