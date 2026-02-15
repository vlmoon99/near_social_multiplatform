import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_social_mobile/core/config/animation_constants.dart';
import 'package:near_social_mobile/core/config/constants.dart';
import 'package:near_social_mobile/features/feed/data/models/post.dart';
import 'package:near_social_mobile/features/feed/presentation/ui/widgets/comment_card.dart';
import 'package:near_social_mobile/features/feed/presentation/ui/widgets/more_actions_for_post_button.dart';
import 'package:near_social_mobile/features/feed/presentation/ui/widgets/raw_text_to_content_formatter.dart';
import 'package:near_social_mobile/features/feed/presentation/providers/posts_controller.dart';
import 'package:near_social_mobile/features/people/presentation/providers/user_list_controller.dart';
import 'package:near_social_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:near_social_mobile/core/providers/filter_controller.dart';
import 'package:near_social_mobile/core/models/filters.dart';
import 'package:near_social_mobile/features/auth/data/models/auth_info.dart';
import 'package:near_social_mobile/core/providers/service_providers.dart';
import 'package:near_social_mobile/core/router/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:near_social_mobile/core/exceptions/exceptions.dart';
import 'package:near_social_mobile/core/utils/pausable_timer.dart';
import 'package:near_social_mobile/core/shared_widgets/image_full_screen_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:near_social_mobile/core/shared_widgets/near_network_image.dart';
import 'package:near_social_mobile/core/shared_widgets/scale_animated_iconbutton.dart';
import 'package:near_social_mobile/core/shared_widgets/app_toast.dart';
import 'package:near_social_mobile/core/shared_widgets/spinner_loading_indicator.dart';
import 'package:near_social_mobile/core/shared_widgets/tappable_scale_widget.dart';
import 'package:near_social_mobile/core/shared_widgets/two_states_iconbutton.dart';

class PostDetailsModal extends ConsumerStatefulWidget {
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
  ConsumerState<PostDetailsModal> createState() => _PostDetailsModalState();
}

class _PostDetailsModalState extends ConsumerState<PostDetailsModal> {
  late final PausableTimer _updateCommentsTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final postsController = ref.read(postsControllerProvider.notifier);
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
        final postsController = ref.read(postsControllerProvider.notifier);
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

  @override
  void dispose() {
    _updateCommentsTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authInfo = ref.read(authControllerProvider);
    final filters = ref.watch(filterControllerProvider);
    final post = ref.watch(postsControllerProvider.select(
      (postsState) => postsState.getPost(
        authorId: widget.accountId,
        blockHeight: widget.blockHeight,
        postsViewMode: widget.postsViewMode,
        postsOfAccountId: widget.postsOfAccountId,
      ),
    ));

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
                    ? Colors.black.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.6),
                child: Column(
                  children: [
                    _buildModalHeader(context, isDark, post),
                    Expanded(
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: _buildMainPost(
                                context, isDark, post, authInfo),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 24, 20, 10),
                              child: Text(
                                "feed.comments".tr(),
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
                                post, isDark, filters)
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
            "feed.post".tr(),
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
      AuthInfo authInfo) {
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
                    await ref.read(userListControllerProvider.notifier)
                        .addGeneralAccountInfoIfNotExists(
                      generalAccountInfo: post.authorInfo,
                    );
                    Navigator.pop(context);
                    context.push(
                      "${AppRoutes.userProfile}?accountId=${post.authorInfo.accountId}",
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
                  context,
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
                  (e) => e.accountId == authInfo.accountId,
                ),
                onPressed: null,
              ),
              // Repost button disabled
              ScaleAnimatedIconButtonWithCounter(
                iconPath: NearAssets.repostIcon,
                count: post.repostList.length,
                activated: post.repostList.any(
                  (e) => e.accountId == authInfo.accountId,
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
      Post post, bool isDark, Filters filters) {
    final filterUtil = FiltersUtil(filters: filters);
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
              "feed.no_comments".tr(),
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

}

class _CommentModal extends ConsumerStatefulWidget {
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
  ConsumerState<_CommentModal> createState() => _CommentModalState();
}

class _CommentModalState extends ConsumerState<_CommentModal> {
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
      final nearSocialApi = ref.read(nearSocialApiProvider);
      final authInfo = ref.read(authControllerProvider);
      final accountId = authInfo.accountId;
      final publicKey = authInfo.accountPublicKey;
      final privateKey = authInfo.devicePrivateKey;

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

      if (await ref.read(authControllerProvider.notifier).getActivationStatus() !=
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
          ref.read(postsControllerProvider.notifier).updateCommentsOfPost(
            accountId: widget.post.authorInfo.accountId,
            blockHeight: widget.post.blockHeight,
            postsViewMode: widget.postsViewMode,
            postsOfAccountId: widget.postsOfAccountId,
          );
        });
      });

      if (mounted) {
        showAppToast(context, "feed.comment_added_soon".tr());
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
                      ? Colors.black.withValues(alpha: 0.65)
                      : Colors.white.withValues(alpha: 0.75),
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
                                      title: Text("feed.discard_comment".tr()),
                                      content: Text("feed.comment_not_saved".tr()),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: Text("feed.keep_editing".tr()),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(ctx);
                                            Navigator.pop(context);
                                          },
                                          child: Text("feed.discard".tr(),
                                              style: const TextStyle(color: Colors.red)),
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
                              hintText: "feed.write_comment".tr(),
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
