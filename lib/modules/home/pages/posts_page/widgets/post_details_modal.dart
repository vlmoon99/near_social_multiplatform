import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_social_mobile/config/animation_constants.dart';
import 'package:near_social_mobile/config/constants.dart';
import 'package:near_social_mobile/modules/home/apis/models/post.dart';
import 'package:near_social_mobile/modules/home/pages/posts_page/widgets/comment_card.dart';
import 'package:near_social_mobile/modules/home/apis/near_social.dart';
import 'package:near_social_mobile/modules/home/pages/posts_page/widgets/more_actions_for_post_button.dart';
import 'package:near_social_mobile/modules/home/pages/posts_page/widgets/raw_text_to_content_formatter.dart';
import 'package:near_social_mobile/modules/home/vms/posts/posts_controller.dart';
import 'package:near_social_mobile/modules/home/vms/users/user_list_controller.dart';
import 'package:near_social_mobile/modules/vms/core/auth_controller.dart';
import 'package:near_social_mobile/modules/vms/core/filter_controller.dart';
import 'package:near_social_mobile/modules/vms/core/models/auth_info.dart';
import 'package:near_social_mobile/routes/routes.dart';
import 'package:near_social_mobile/exceptions/exceptions.dart';
import 'package:near_social_mobile/services/pausable_timer.dart';
import 'package:near_social_mobile/shared_widgets/image_full_screen_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:near_social_mobile/shared_widgets/near_network_image.dart';
import 'package:near_social_mobile/shared_widgets/scale_animated_iconbutton.dart';
import 'package:near_social_mobile/shared_widgets/spinner_loading_indicator.dart';
import 'package:near_social_mobile/shared_widgets/tappable_scale_widget.dart';
import 'package:near_social_mobile/shared_widgets/two_states_iconbutton.dart';
import 'package:rxdart/rxdart.dart';

class PostDetailsModal extends StatefulWidget {
  const PostDetailsModal({
    super.key,
    required this.accountId,
    required this.blockHeight,
    required this.postsViewMode,
    this.postsOfAccountId,
    this.allowToNavigateToPostAuthorPage = true,
  });

  final String accountId;
  final int blockHeight;
  final PostsViewMode postsViewMode;
  final String? postsOfAccountId;
  final bool allowToNavigateToPostAuthorPage;

  @override
  State<PostDetailsModal> createState() => _PostDetailsModalState();
}

class _PostDetailsModalState extends State<PostDetailsModal> {
  late final PausableTimer _updateCommentsTimer;

  @override
  void initState() {
    super.initState();
    final PostsController postsController = Modular.get<PostsController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final posts = postsController.getPostsDueToPostsViewMode(
          widget.postsViewMode, widget.postsOfAccountId);
      final post = posts.firstWhere(
        (e) =>
            e.blockHeight == widget.blockHeight &&
            e.authorInfo.accountId == widget.accountId,
      );
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

    _updateCommentsTimer = PausableTimer.periodic(
      const Duration(minutes: 2),
      () async {
        _updateCommentsTimer.pause();
        final posts = postsController.getPostsDueToPostsViewMode(
            widget.postsViewMode, widget.postsOfAccountId);
        final post = posts.firstWhere(
          (e) =>
              e.blockHeight == widget.blockHeight &&
              e.authorInfo.accountId == widget.accountId,
        );
        if (post.commentList != null) {
          await postsController.updateCommentsOfPost(
            accountId: widget.accountId,
            blockHeight: widget.blockHeight,
            postsViewMode: widget.postsViewMode,
            postsOfAccountId: widget.postsOfAccountId,
          );
        }
        _updateCommentsTimer.start();
      },
    )..start();
  }

  PostsController get postsController => Modular.get<PostsController>();

  @override
  void dispose() {
    _updateCommentsTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final AuthController authController = Modular.get<AuthController>();
    final FilterController filterController = Modular.get<FilterController>();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 850),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Material(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.7)
                    : Colors.white.withValues(alpha: 0.8),
                child: StreamBuilder(
                  stream: Rx.merge(
                      [postsController.stream, filterController.stream]),
                  builder: (context, snapshot) {
                    final posts =
                        postsController.getPostsDueToPostsViewMode(
                            widget.postsViewMode, widget.postsOfAccountId);
                    final post = posts.firstWhere(
                      (e) =>
                          e.blockHeight == widget.blockHeight &&
                          e.authorInfo.accountId == widget.accountId,
                    );

                    return Column(
                      children: [
                        _buildModalHeader(context, isDark, post),
                        Expanded(
                          child: CustomScrollView(
                            physics: const BouncingScrollPhysics(),
                            slivers: [
                              SliverToBoxAdapter(
                                child: _buildMainPost(
                                    context, isDark, post, authController),
                              ),
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 24, 20, 10),
                                  child: Text(
                                    'Comments',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color:
                                          isDark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              if (post.commentList != null)
                                _buildCommentsList(
                                    post, isDark, filterController)
                              else
                                const SliverToBoxAdapter(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 32),
                                    child:
                                        Center(child: SpinnerLoadingIndicator()),
                                  ),
                                ),
                              const SliverToBoxAdapter(
                                  child: SizedBox(height: 20)),
                            ],
                          ),
                        ),
                        // Comment input removed (blockchain write disabled)
                        // _buildCommentInput(context, isDark, post),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModalHeader(BuildContext context, bool isDark, Post post) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : Colors.black12,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(CupertinoIcons.chevron_down,
                  color: CupertinoColors.activeBlue),
            ),
          ),
          Text(
            'Post',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          MoreActionsForPostButton(
            post: post,
            postsViewMode: widget.postsViewMode,
          ),
        ],
      ),
    );
  }

  Widget _buildMainPost(BuildContext context, bool isDark, Post post,
      AuthController authController) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author info
          TappableScaleWidget(
            scaleDown: widget.allowToNavigateToPostAuthorPage
                ? AppAnimations.profileTapScaleDown
                : 1.0,
            onTap: widget.allowToNavigateToPostAuthorPage
                ? () async {
                    HapticFeedback.lightImpact();
                    await Modular.get<UserListController>()
                        .addGeneralAccountInfoIfNotExists(
                      generalAccountInfo: post.authorInfo,
                    );
                    Navigator.pop(context);
                    Modular.to.pushNamed(
                      ".${Routes.home.userPage}?accountId=${post.authorInfo.accountId}",
                    );
                  }
                : null,
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(16)),
                  clipBehavior: Clip.antiAlias,
                  child: NearNetworkImage(
                    imageUrl: post.authorInfo.profileImageLink,
                    errorPlaceholder: Image.asset(
                      NearAssets.standartAvatar,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (post.authorInfo.name.isNotEmpty)
                        Text(
                          post.authorInfo.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      Text(
                        '@${post.authorInfo.accountId}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Post body
          RawTextToContentFormatter(
            rawText: post.postBody.text.trim(),
            imageHeight: .4.sh,
            textColor: isDark ? Colors.white : Colors.black,
          ),

          // Media
          if (post.postBody.mediaLink != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  Modular.routerDelegate.navigatorKey.currentContext!,
                  MaterialPageRoute(
                    builder: (context) =>
                        ImageFullScreen(imageUrl: post.postBody.mediaLink!),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: .4.sh),
                  child: NearNetworkImage(
                    imageUrl: post.postBody.mediaLink!,
                    boxFit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Action buttons (blockchain writes disabled)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Comment button disabled
              TwoStatesIconButton(
                iconPath: NearAssets.commentIcon,
                onPressed: null,
              ),
              // Like button disabled
              ScaleAnimatedIconButtonWithCounter(
                iconPath: NearAssets.likeIcon,
                iconActivatedPath: NearAssets.activatedLikeIcon,
                count: post.likeList.length,
                activated: post.likeList.any(
                  (e) => e.accountId == authController.state.accountId,
                ),
                onPressed: null,
              ),
              // Repost button disabled
              ScaleAnimatedIconButtonWithCounter(
                iconPath: NearAssets.repostIcon,
                count: post.repostList.length,
                activated: post.repostList.any(
                  (e) => e.accountId == authController.state.accountId,
                ),
                activatedColor: Colors.green,
                onPressed: null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList(
      Post post, bool isDark, FilterController filterController) {
    final filterUtil = FiltersUtil(filters: filterController.state);
    final comments = post.commentList!
        .where((c) =>
            !filterUtil.commentIsHided(c.authorInfo.accountId, c.blockHeight))
        .toList();

    if (comments.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Center(
            child: Text(
              'No comments yet',
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white38 : Colors.black26,
              ),
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (ctx, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: CommentCard(
            comment: comments[index],
            post: post,
            postsViewMode: widget.postsViewMode,
            postsOfAccountId: widget.postsOfAccountId,
          ),
        ),
        childCount: comments.length,
      ),
    );
  }

  Widget _buildCommentInput(BuildContext context, bool isDark, Post post) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.8),
            border: Border(
              top: BorderSide(
                color: isDark ? Colors.white10 : Colors.black12,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showCommentModal(context, isDark, post);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white12
                          : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Add a comment...',
                      style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black45,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showCommentModal(context, isDark, post);
                },
                child: const Icon(
                  CupertinoIcons.arrow_up_circle_fill,
                  size: 32,
                  color: CupertinoColors.activeBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCommentModal(BuildContext context, bool isDark, Post post, {String initialText = ''}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 350),
      transitionBuilder: (ctx, anim1, anim2, child) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic));
        return SlideTransition(position: offsetAnimation, child: child);
      },
      pageBuilder: (ctx, anim1, anim2) {
        return _CommentModal(
          post: post,
          isDark: isDark,
          initialText: initialText,
          postsViewMode: widget.postsViewMode,
          postsOfAccountId: widget.postsOfAccountId,
        );
      },
    );
  }

  Future<void> _showRepostDialog(
      BuildContext context, bool isDark, Post post) async {
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
                                Navigator.pop(context, false);
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
                                Navigator.pop(context, true);
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.green
                                      .withValues(alpha: isDark ? 0.3 : 0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color:
                                          Colors.green.withValues(alpha: 0.3)),
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
    ).then((answer) async {
      if (answer == null || !answer) return;
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
    });
  }
}

class _CommentModal extends StatefulWidget {
  const _CommentModal({
    required this.post,
    required this.isDark,
    required this.postsViewMode,
    this.postsOfAccountId,
    this.initialText = '',
  });

  final Post post;
  final bool isDark;
  final PostsViewMode postsViewMode;
  final String? postsOfAccountId;
  final String initialText;

  @override
  State<_CommentModal> createState() => _CommentModalState();
}

class _CommentModalState extends State<_CommentModal> {
  late final TextEditingController _textController;
  Uint8List? _imageData;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  bool get _hasContent => _textController.text.trim().isNotEmpty || _imageData != null;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() => _imageData = bytes);
  }

  Future<void> _send() async {
    if (_isSending) return;
    if (!_hasContent) return;

    setState(() => _isSending = true);
    HapticFeedback.lightImpact();

    try {
      final nearSocialApi = Modular.get<NearSocialApi>();
      final authController = Modular.get<AuthController>();
      final accountId = authController.state.accountId;
      final publicKey = authController.state.publicKey;
      final privateKey = authController.state.privateKey;

      String? cidOfMedia;
      if (_imageData != null) {
        cidOfMedia = await nearSocialApi.uploadFileToNearFileHosting(
          imageData: _imageData!,
        );
      }

      final postBody = PostBody(
        text: _textController.text,
        mediaLink: cidOfMedia,
      );

      if (postBody.text.isEmpty && postBody.mediaLink == null) {
        setState(() => _isSending = false);
        return;
      }

      if (await authController.getActivationStatus() !=
          AccountActivationStatus.activated) {
        throw AccountNotActivatedException();
      }

      nearSocialApi
          .commentThePost(
        accountIdOfPost: widget.post.authorInfo.accountId,
        blockHeight: widget.post.blockHeight,
        accountId: accountId,
        publicKey: publicKey,
        privateKey: privateKey,
        postBody: postBody,
      )
          .then((_) {
        Future.delayed(const Duration(seconds: 10), () {
          Modular.get<PostsController>().updateCommentsOfPost(
            accountId: widget.post.authorInfo.accountId,
            blockHeight: widget.post.blockHeight,
            postsViewMode: widget.postsViewMode,
            postsOfAccountId: widget.postsOfAccountId,
          );
        });
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your comment will be added soon')),
        );
        Navigator.pop(context);
      }
    } catch (err) {
      setState(() => _isSending = false);
      if (err is Exception) {
        throw Exception('Failed to send comment');
      } else {
        rethrow;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 550),
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Material(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.85)
                      : Colors.white.withValues(alpha: 0.95),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text.rich(
                                TextSpan(children: [
                                  TextSpan(
                                    text: 'Reply to ',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: isDark ? Colors.white60 : Colors.black54,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '@${widget.post.authorInfo.accountId}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ]),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                if (_hasContent) {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Discard comment?'),
                                      content: const Text('Your comment will not be saved.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text('Keep editing'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(ctx);
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Discard',
                                              style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  Navigator.pop(context);
                                }
                              },
                              icon: Icon(
                                CupertinoIcons.xmark_circle_fill,
                                color: isDark ? Colors.white30 : Colors.black26,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Text field
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 180),
                          child: TextField(
                            controller: _textController,
                            autofocus: true,
                            maxLines: null,
                            onChanged: (_) => setState(() {}),
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Write a comment...',
                              hintStyle: TextStyle(
                                color: isDark ? Colors.white38 : Colors.black38,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ),
                      // Image preview
                      if (_imageData != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    _imageData!,
                                    height: 80,
                                    width: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: -6,
                                  right: -6,
                                  child: GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      setState(() => _imageData = null);
                                    },
                                    child: Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.white : Colors.black,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        size: 14,
                                        color: isDark ? Colors.black : Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      // Bottom bar
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.black.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  CupertinoIcons.photo,
                                  size: 22,
                                  color: isDark ? Colors.white54 : Colors.black45,
                                ),
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: _isSending ? null : _send,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: _isSending
                                      ? (isDark ? Colors.white12 : Colors.black12)
                                      : CupertinoColors.activeBlue,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: _isSending
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: CupertinoColors.activeBlue,
                                        ),
                                      )
                                    : const Text(
                                        'Send',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
