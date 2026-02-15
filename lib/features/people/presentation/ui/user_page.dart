import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:near_social_mobile/core/config/animation_constants.dart';
import 'package:near_social_mobile/core/config/constants.dart';
import 'package:near_social_mobile/core/config/theme.dart';
import 'package:near_social_mobile/core/shared_widgets/glassmorphism_components.dart';
import 'package:near_social_mobile/features/people/presentation/ui/widgets/more_actions_for_user_button.dart';
import 'package:near_social_mobile/features/people/presentation/ui/widgets/user_page_tabs/user_posts.dart';
// import 'package:near_social_mobile/features/people/presentation/ui/widgets/user_page_tabs/user_widgets.dart';
import 'package:near_social_mobile/features/feed/presentation/ui/widgets/raw_text_to_content_formatter.dart';
import 'package:near_social_mobile/features/feed/presentation/providers/posts_controller.dart';
import 'package:near_social_mobile/features/people/presentation/providers/user_list_controller.dart';
import 'package:near_social_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:near_social_mobile/core/providers/filter_controller.dart';
import 'package:near_social_mobile/core/shared_widgets/expandable_wiget.dart';
import 'package:near_social_mobile/core/shared_widgets/image_full_screen_page.dart';
import 'package:near_social_mobile/core/shared_widgets/near_network_image.dart';
import 'package:near_social_mobile/core/shared_widgets/app_toast.dart';
import 'package:near_social_mobile/core/shared_widgets/tappable_scale_widget.dart';
import 'package:near_social_mobile/core/router/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class UserPage extends ConsumerStatefulWidget {
  const UserPage({super.key, required this.accountId});

  final String accountId;

  @override
  ConsumerState<UserPage> createState() => _UserPageState();
}

class _UserPageState extends ConsumerState<UserPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _showTopBar = ValueNotifier(true);
  final ValueNotifier<bool> _canScrollToTop = ValueNotifier(false);
  Timer? _hideTimer;
  late List<BackgroundParticle> _particles;
  late AnimationController _bgController;
  Size _lastSize = Size.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_handleScroll);
    _bgController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat();
    _particles = [];

    final userListController = ref.read(userListControllerProvider.notifier);
    final user = ref.read(userListControllerProvider)
        .getUserByAccountId(accountId: widget.accountId);

    final postsController = ref.read(postsControllerProvider.notifier);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!user.allMetadataLoaded) {
        await userListController.loadAdditionalMetadata(
            accountId: widget.accountId);
        if (ref.read(postsControllerProvider).postsOfAccounts[widget.accountId] == null) {
          await postsController.loadPosts(
            postsViewMode: PostsViewMode.account,
            postsOfAccountId: widget.accountId,
          );
        }
      }
    });
  }

  void _handleScroll() {
    if (_showTopBar.value) _showTopBar.value = false;
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) _showTopBar.value = true;
    });
    final canScroll = _scrollController.hasClients && _scrollController.offset > 100;
    if (_canScrollToTop.value != canScroll) _canScrollToTop.value = canScroll;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _bgController.stop();
    } else if (state == AppLifecycleState.resumed) {
      _bgController.repeat();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bgController.dispose();
    _scrollController.dispose();
    _hideTimer?.cancel();
    _showTopBar.dispose();
    _canScrollToTop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filters = ref.watch(filterControllerProvider);

    if (_particles.isEmpty || _lastSize != screenSize) {
      _particles = List.generate(
        18,
        (i) => BackgroundParticle(screenSize, icons: [
          'assets/media/icons/near_social_logo.svg',
          CupertinoIcons.bell_fill,
          'assets/media/icons/near_social_logo.svg',
        ]),
      );
      _lastSize = screenSize;
    }

    final filtersUtil = FiltersUtil(filters: filters);
    final userIsBlocked = filtersUtil.userIsBlocked(widget.accountId);

    return Scaffold(
      body: Stack(
        children: [
          _buildLivingBackground(screenSize, isDark),
          _buildContent(isDark, userIsBlocked, screenSize),
          _buildTopBar(isDark),
        ],
      ),
    );
  }

  Widget _buildLivingBackground(Size screenSize, bool isDark) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        for (var p in _particles) {
          p.update(screenSize);
        }
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [const Color(0xFF000000), const Color(0xFF0A0A1F)]
                      : [const Color(0xFFE5E5EA), const Color(0xFFD1D1D6)],
                ),
              ),
            ),
            ...(_particles.map((p) => Positioned(
                  left: p.position.dx,
                  top: p.position.dy,
                  child: Opacity(
                    opacity:
                        (math.sin(p.opacityPhase) * 0.04 + 0.05).clamp(0.01, 0.1),
                    child: Icon(p.icon,
                        size: p.size,
                        color: isDark ? Colors.white : Colors.black45),
                  ),
                ))),
          ],
        );
      },
    );
  }

  Widget _buildTopBar(bool isDark) {
    return ValueListenableBuilder<bool>(
      valueListenable: _showTopBar,
      builder: (context, showTopBar, child) => AnimatedPositioned(
        duration: AppAnimations.barTransition,
        curve: AppAnimations.barCurve,
        top: showTopBar ? 20 : -100,
        left: 0,
        right: 0,
        child: child!,
      ),
      child: Center(
        child: _glassBar(
          360,
          Row(
            children: [
              TappableScaleWidget(
                scaleDown: AppAnimations.navButtonScaleDown,
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white : Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(CupertinoIcons.back,
                      color: isDark ? Colors.black : Colors.white, size: 18),
                ),
              ),
              const Spacer(),
              Text("people.profile".tr(),
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      letterSpacing: -0.5)),
              const Spacer(),
              ValueListenableBuilder<bool>(
                valueListenable: _canScrollToTop,
                builder: (context, canScroll, _) => AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: canScroll ? 1.0 : 0.0,
                  child: IgnorePointer(
                    ignoring: !canScroll,
                    child: TappableScaleWidget(
                      scaleDown: AppAnimations.navButtonScaleDown,
                      onTap: () {
                        _scrollController.animateTo(
                          0,
                          duration: AppAnimations.slow,
                          curve: AppAnimations.easeOut,
                        );
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white : Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(CupertinoIcons.arrow_up,
                            color: isDark ? Colors.black : Colors.white, size: 18),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          isDark,
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark, bool userIsBlocked, Size screenSize) {
    final usersList = ref.watch(userListControllerProvider);
    final user = usersList.getUserByAccountId(accountId: widget.accountId);
    final authInfo = ref.read(authControllerProvider);
    final isOwnProfile = widget.accountId == authInfo.accountId;

    if (userIsBlocked) {
      return _buildBlockedUserView(isDark, user);
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: NestedScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(child: SizedBox(height: 80 + MediaQuery.of(context).padding.top)),

              // Header card with background image, avatar, name, actions
              SliverToBoxAdapter(
                child: _buildHeaderCard(isDark, user, isOwnProfile),
              ),

              // Social stats
              SliverToBoxAdapter(
                child: _buildSocialStats(isDark, user),
              ),

              // Social links
              if (user.generalAccountInfo.linktree.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildSocialLinks(isDark, user),
                ),

              // Tags
              if (user.generalAccountInfo.tags.isNotEmpty ||
                  (user.userTags != null && user.userTags!.isNotEmpty))
                SliverToBoxAdapter(
                  child: _buildTags(isDark, user),
                ),

              // Description
              if (user.generalAccountInfo.description.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildDescription(isDark, user),
                ),

              // Tab selector removed (Widgets tab disabled)
              // SliverToBoxAdapter(
              //   child: _buildTabSelector(isDark),
              // ),
            ];
          },
          body: UserPostsView(accountIdOfUser: widget.accountId),
        ),
      ),
    );
  }

  Widget _buildBlockedUserView(bool isDark, dynamic user) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: 80 + MediaQuery.of(context).padding.top)),
            SliverToBoxAdapter(
              child: _buildHeaderCard(isDark, user, false),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.white.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_off,
                        size: 60,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "User is blocked",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.redAccent : NEARColors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 90)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(
      bool isDark, dynamic user, bool isOwnProfile) {
    final authInfo = ref.read(authControllerProvider);
    final bool showFollowsYou = user.followings != null &&
        user.followings!.any(
          (element) => element.accountId == authInfo.accountId,
        );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                  color: isDark
                      ? Colors.white10
                      : Colors.white.withValues(alpha: 0.5)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                // Background image
                GestureDetector(
                  onTap: () {
                    if (user.generalAccountInfo.backgroundImageLink.isEmpty) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageFullScreen(
                          imageUrl: user.generalAccountInfo.backgroundImageLink,
                        ),
                      ),
                    );
                  },
                  child: SizedBox(
                    height: 140,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(32)),
                      child: NearNetworkImage(
                        imageUrl: user.generalAccountInfo.backgroundImageLink,
                        errorPlaceholder: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [const Color(0xFF1a1a2e), const Color(0xFF16213e)]
                                  : [const Color(0xFFa8d8ea), const Color(0xFFaa96da)],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Avatar overlapping the background
                Transform.translate(
                  offset: const Offset(0, -36),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (user.generalAccountInfo.profileImageLink.isEmpty) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageFullScreen(
                                imageUrl: user.generalAccountInfo.profileImageLink,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? Colors.black
                                  : Colors.white,
                              width: 3,
                            ),
                          ),
                          child: ClipOval(
                            child: NearNetworkImage(
                              imageUrl: user.generalAccountInfo.profileImageLink,
                              errorPlaceholder: Image.asset(
                                NearAssets.standartAvatar,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Name + more actions
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                user.generalAccountInfo.name.isNotEmpty
                                    ? user.generalAccountInfo.name
                                    : "No Name",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            if (!isOwnProfile)
                              MoreActionsForUserButton(
                                userAccountId: user.generalAccountInfo.accountId,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Account ID (tappable to copy)
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Clipboard.setData(
                            ClipboardData(text: user.generalAccountInfo.accountId),
                          );
                          showAppToast(context, "AccountId ${user.generalAccountInfo.accountId} copied to clipboard");
                        },
                        child: Text(
                          "@${user.generalAccountInfo.accountId}",
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ),

                      // "Follows you" badge
                      if (showFollowsYou && !isOwnProfile) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.08),
                          ),
                          child: Text(
                            "Follows you",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Chat & call buttons
                      if (!isOwnProfile)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _actionChip(
                                icon: CupertinoIcons.chat_bubble_fill,
                                label: "Chat",
                                color: CupertinoColors.activeBlue,
                                isDark: isDark,
                                onTap: () {
                                  context.push(
                                    '${AppRoutes.chatRoom}?targetAccountId=${user.generalAccountInfo.accountId}',
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              _actionChip(
                                icon: CupertinoIcons.phone_fill,
                                label: "Call",
                                color: CupertinoColors.activeGreen,
                                isDark: isDark,
                                onTap: () {
                                  context.push(
                                    '${AppRoutes.chatRoom}?targetAccountId=${user.generalAccountInfo.accountId}',
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              _actionChip(
                                icon: CupertinoIcons.video_camera_solid,
                                label: "Video",
                                color: CupertinoColors.systemPurple,
                                isDark: isDark,
                                onTap: () {
                                  context.push(
                                    '${AppRoutes.chatRoom}?targetAccountId=${user.generalAccountInfo.accountId}',
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildSocialStats(bool isDark, dynamic user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          _statBox(
            user.followings != null
                ? user.followings!.length.toString()
                : "?",
            "Following",
            isDark,
          ),
          const SizedBox(width: 8),
          _statBox(
            user.followers != null
                ? user.followers!.length.toString()
                : "?",
            "Followers",
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _statBox(String val, String lab, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: isDark
                  ? Colors.white12
                  : Colors.white.withValues(alpha: 0.6)),
        ),
        child: Column(
          children: [
            Text(val,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                )),
            Text(lab,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white54 : Colors.black54,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLinks(bool isDark, dynamic user) {
    final linktree = user.generalAccountInfo.linktree as Map<String, dynamic>;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: isDark
                ? Colors.white10
                : Colors.white.withValues(alpha: 0.4)),
      ),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: linktree.entries.map((pair) {
          return _socialLinkButton(pair.key, pair.value, isDark);
        }).toList(),
      ),
    );
  }

  Widget _socialLinkButton(String key, String value, bool isDark) {
    String? assetPath;
    String? url;

    switch (key) {
      case 'twitter':
        assetPath = "assets/media/icons/twitter_icon.svg";
        url = "https://twitter.com/$value";
        break;
      case 'github':
        assetPath = "assets/media/icons/github_icon.svg";
        url = "https://github.com/$value";
        break;
      case 'telegram':
        assetPath = "assets/media/icons/telegram_icon.svg";
        url = "https://t.me/$value";
        break;
      case 'website':
        assetPath = "assets/media/icons/website_icon.svg";
        url = "https://$value";
        break;
    }

    if (assetPath == null || url == null) return const SizedBox();

    return TextButton.icon(
      onPressed: () {
        HapticFeedback.lightImpact();
        launchUrl(Uri.parse(url!));
      },
      icon: SvgPicture.asset(assetPath, height: 24),
      label: Text(
        key,
        style: TextStyle(
          color: isDark ? Colors.white70 : Colors.black87,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildTags(bool isDark, dynamic user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: isDark
                ? Colors.white10
                : Colors.white.withValues(alpha: 0.4)),
      ),
      child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ...user.generalAccountInfo.tags.map<Widget>((tag) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.06),
                    ),
                    child: Text(
                      "#$tag",
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  );
                }),
                if (user.userTags != null)
                  ...user.userTags!.map<Widget>((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: CupertinoColors.activeBlue
                            .withValues(alpha: 0.2),
                      ),
                      child: Text(
                        "#$tag",
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white : CupertinoColors.activeBlue,
                        ),
                      ),
                    );
                  }),
            ],
          ),
    );
  }

  Widget _buildDescription(bool isDark, dynamic user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: isDark
                ? Colors.white10
                : Colors.white.withValues(alpha: 0.4)),
      ),
      child: CollapseWidget(
        children: RawTextToContentFormatter(
          rawText: user.generalAccountInfo.description,
          imageHeight: 0.2.sh,
        ),
      ),
    );
  }

  Widget _actionChip({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return TappableScaleWidget(
      scaleDown: AppAnimations.navButtonScaleDown,
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: color.withValues(alpha: isDark ? 0.2 : 0.12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glassBar(double width, Widget child, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.15),
            blurRadius: 35,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
          child: Container(
            width: width,
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.white.withValues(alpha: 0.14),
                        Colors.white.withValues(alpha: 0.06)
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.95),
                        Colors.white.withValues(alpha: 0.85)
                      ],
              ),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: isDark
                    ? Colors.white24
                    : Colors.black.withValues(alpha: 0.12),
                width: 1.2,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

}
