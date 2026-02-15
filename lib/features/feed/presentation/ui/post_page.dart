import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:near_social_mobile/core/config/constants.dart';
import 'package:near_social_mobile/features/feed/data/models/post.dart';
import 'package:near_social_mobile/features/feed/presentation/ui/widgets/comment_card.dart';
import 'package:near_social_mobile/features/feed/presentation/ui/widgets/create_comment_dialog_body.dart';
import 'package:near_social_mobile/features/feed/presentation/ui/widgets/more_actions_for_post_button.dart';
import 'package:near_social_mobile/features/feed/presentation/ui/widgets/raw_text_to_content_formatter.dart';
import 'package:near_social_mobile/core/shared_widgets/glassmorphism_components.dart';
import 'package:near_social_mobile/features/feed/presentation/providers/posts_controller.dart';
import 'package:near_social_mobile/features/people/presentation/providers/user_list_controller.dart';
import 'package:near_social_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:near_social_mobile/core/providers/filter_controller.dart';
import 'package:near_social_mobile/core/router/routes.dart';
import 'package:near_social_mobile/core/utils/pausable_timer.dart';
import 'package:near_social_mobile/core/shared_widgets/image_full_screen_page.dart';
import 'package:near_social_mobile/core/shared_widgets/scale_animated_iconbutton.dart';
import 'package:near_social_mobile/core/shared_widgets/spinner_loading_indicator.dart';
import 'package:near_social_mobile/core/shared_widgets/two_states_iconbutton.dart';
import 'package:near_social_mobile/core/shared_widgets/near_network_image.dart';

class PostPage extends ConsumerStatefulWidget {
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
  ConsumerState<PostPage> createState() => _PostPageState();
}

class _PostPageState extends ConsumerState<PostPage> with TickerProviderStateMixin {
  late final PausableTimer updateCommentsTimer;
  late final AnimationController _bgController =
      AnimationController(vsync: this, duration: const Duration(seconds: 1))
        ..repeat();
  List<BackgroundParticle> _particles = [];
  Size _lastSize = Size.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final postsController = ref.read(postsControllerProvider.notifier);
      final posts = postsController.getPostsDueToPostsViewMode(
          widget.postsViewMode, widget.postsOfAccountId);
      final post = posts.cast<Post?>().firstWhere(
            (element) =>
                element!.blockHeight == widget.blockHeight &&
                element.authorInfo.accountId == widget.accountId,
            orElse: () => null,
          );
      if (post == null) return;
      if (post.commentList == null) {
        postsController.loadCommentsOfPost(
          accountId: widget.accountId,
          blockHeight: widget.blockHeight,
          postsViewMode: widget.postsViewMode,
          postsOfAccountId: widget.postsOfAccountId,
        );
      } else {
        postsController.updateCommentsOfPost(
          accountId: widget.accountId,
          blockHeight: widget.blockHeight,
          postsViewMode: widget.postsViewMode,
          postsOfAccountId: widget.postsOfAccountId,
        );
      }
    });
    updateCommentsTimer = PausableTimer.periodic(
      const Duration(minutes: 2),
      () async {
        updateCommentsTimer.pause();

        final postsController = ref.read(postsControllerProvider.notifier);
        final posts = postsController.getPostsDueToPostsViewMode(
            widget.postsViewMode, widget.postsOfAccountId);
        final post = posts.cast<Post?>().firstWhere(
            (element) =>
                element!.blockHeight == widget.blockHeight &&
                element.authorInfo.accountId == widget.accountId,
            orElse: () => null,
          );

        if (post?.commentList != null) {
          await postsController.updateCommentsOfPost(
            accountId: widget.accountId,
            blockHeight: widget.blockHeight,
            postsViewMode: widget.postsViewMode,
            postsOfAccountId: widget.postsOfAccountId,
          );
        }

        updateCommentsTimer.start();
      },
    )..start();
  }

  @override
  void dispose() {
    updateCommentsTimer.cancel();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authControllerProvider);
    ref.watch(postsControllerProvider.select((s) => s.getPost(
      authorId: widget.accountId,
      blockHeight: widget.blockHeight,
      postsViewMode: widget.postsViewMode,
      postsOfAccountId: widget.postsOfAccountId,
    )));
    final filterState = ref.watch(filterControllerProvider);
    final postsController = ref.read(postsControllerProvider.notifier);

    if (_particles.isEmpty || _lastSize != screenSize) {
      _particles = List.generate(10, (i) => BackgroundParticle(screenSize));
      _lastSize = screenSize;
    }

    return Scaffold(
      body: Stack(
        children: [
          buildLivingBackground(
            controller: _bgController,
            particles: _particles,
            screenSize: screenSize,
            isDark: isDark,
          ),
          SafeArea(
            child: Builder(
              builder: (context) {
                final posts = postsController.getPostsDueToPostsViewMode(
                    widget.postsViewMode, widget.postsOfAccountId);
                final post = posts.cast<Post?>().firstWhere(
                    (element) =>
                        element!.blockHeight == widget.blockHeight &&
                        element.authorInfo.accountId == widget.accountId,
                    orElse: () => null,
                  );
                if (post == null) {
                  return Center(
                    child: Text(
                      'Post not found',
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  );
                }
                return Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.black.withValues(alpha: 0.06),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                CupertinoIcons.back,
                                size: 20,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            "feed.post".tr(),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          const Spacer(),
                          MoreActionsForPostButton(
                            post: post,
                            postsViewMode: widget.postsViewMode,
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          // Post card
                          GlassContainer(
                            isDark: isDark,
                            margin: EdgeInsets.zero,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Author info
                                GestureDetector(
                                  onTap: widget.allowToNavigateToPostAuthorPage
                                      ? () async {
                                          HapticFeedback.lightImpact();
                                          await ref.read(userListControllerProvider.notifier)
                                              .addGeneralAccountInfoIfNotExists(
                                            generalAccountInfo:
                                                post.authorInfo,
                                          );
                                          if (context.mounted) {
                                            context.push(
                                              "${AppRoutes.userProfile}?accountId=${post.authorInfo.accountId}",
                                            );
                                          }
                                        }
                                      : null,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: NearNetworkImage(
                                          imageUrl:
                                              post.authorInfo.profileImageLink,
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
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (post.authorInfo.name != "")
                                              Text(
                                                post.authorInfo.name,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16,
                                                  color: isDark
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                              ),
                                            Text(
                                              "@${post.authorInfo.accountId}",
                                              overflow:
                                                  TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: isDark
                                                    ? Colors.white54
                                                    : Colors.black45,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // Post body
                                RawTextToContentFormatter(
                                  rawText: post.postBody.text.trim(),
                                  imageHeight: .5.sh,
                                ),

                                // Media
                                if (post.postBody.mediaLink != null) ...[
                                  const SizedBox(height: 12),
                                  GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ImageFullScreen(
                                            imageUrl:
                                                post.postBody.mediaLink!,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Hero(
                                      tag: post.postBody.mediaLink!,
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                              maxHeight: .5.sh),
                                          child: NearNetworkImage(
                                            imageUrl:
                                                post.postBody.mediaLink!,
                                            boxFit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 14),

                                // Action buttons
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    TwoStatesIconButton(
                                      iconPath: NearAssets.commentIcon,
                                      onPressed: () async {
                                        HapticFeedback.lightImpact();
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return Dialog.fullscreen(
                                              child: CreateCommentDialog(
                                                postsViewMode:
                                                    widget.postsViewMode,
                                                postsOfAccountId:
                                                    widget.postsOfAccountId,
                                                descriptionTitle: Text.rich(
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                  TextSpan(
                                                    children: [
                                                      TextSpan(
                                                          text:
                                                              "feed.answer_to".tr()),
                                                      TextSpan(
                                                        text:
                                                            "@${post.authorInfo.accountId}",
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
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
                                      iconActivatedPath:
                                          NearAssets.activatedLikeIcon,
                                      count: post.likeList.length,
                                      activated: post.likeList.any(
                                        (element) =>
                                            element.accountId ==
                                            authState.accountId,
                                      ),
                                      onPressed: () async {
                                        HapticFeedback.lightImpact();
                                        try {
                                          await postsController.likePost(
                                            post: post,
                                            postsViewMode:
                                                widget.postsViewMode,
                                            postsOfAccountId:
                                                widget.postsOfAccountId,
                                          );
                                        } catch (err) {
                                          if (err is Exception) {
                                            throw Exception(
                                                "Failed to like post");
                                          } else {
                                            rethrow;
                                          }
                                        }
                                      },
                                    ),
                                    ScaleAnimatedIconButtonWithCounter(
                                      iconPath: NearAssets.repostIcon,
                                      count: post.repostList.length,
                                      activated: post.repostList.any(
                                        (element) =>
                                            element.accountId ==
                                            authState.accountId,
                                      ),
                                      activatedColor: Colors.green,
                                      onPressed: () async {
                                        HapticFeedback.lightImpact();
                                        final String accountId =
                                            authState.accountId;
                                        if (post.repostList.any((element) =>
                                            element.accountId ==
                                            accountId)) {
                                          return;
                                        }
                                        await _showRepostDialog(
                                            context,
                                            isDark,
                                            postsController,
                                            post);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Comments section
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              "feed.comments".tr(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          if (post.commentList != null)
                            Builder(
                              builder: (context) {
                                final FiltersUtil filterUtil = FiltersUtil(
                                  filters: filterState,
                                );
                                final comments = post.commentList!
                                    .where((comment) =>
                                        !filterUtil.commentIsHided(
                                            comment.authorInfo.accountId,
                                            comment.blockHeight))
                                    .toList();
                                if (comments.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 32),
                                    child: Center(
                                      child: Text(
                                        "feed.no_comments".tr(),
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: isDark
                                              ? Colors.white38
                                              : Colors.black26,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: comments
                                      .map(
                                        (comment) => CommentCard(
                                          comment: comment,
                                          post: post,
                                          postsViewMode:
                                              widget.postsViewMode,
                                          postsOfAccountId:
                                              widget.postsOfAccountId,
                                        ),
                                      )
                                      .toList(),
                                );
                              },
                            )
                          else ...[
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: Center(
                                child: SpinnerLoadingIndicator(),
                              ),
                            )
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showRepostDialog(BuildContext context, bool isDark,
      PostsController postsController, dynamic post) async {
    await showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) {
        return Center(
          child: Container(
            margin: const EdgeInsets.all(40),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.white.withValues(alpha: 0.80),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: isDark ? Colors.white24 : Colors.black12,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.green
                              .withValues(alpha: isDark ? 0.2 : 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(CupertinoIcons.arrow_2_squarepath,
                            color: Colors.green, size: 26),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Repost?',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Share this post with your followers?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.of(context).pop(false);
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.black.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color:
                                          isDark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.of(context).pop(true);
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.green
                                      .withValues(alpha: isDark ? 0.3 : 0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: Colors.green
                                          .withValues(alpha: 0.3)),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Repost',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
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
            postsViewMode: widget.postsViewMode,
            postsOfAccountId: widget.postsOfAccountId,
          );
        } catch (err) {
          if (err is Exception) {
            throw Exception("Failed to repost post");
          } else {
            rethrow;
          }
        }
      },
    );
  }
}
