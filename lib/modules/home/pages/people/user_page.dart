import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:near_social_mobile/config/constants.dart';
import 'package:near_social_mobile/config/theme.dart';
import 'package:near_social_mobile/exceptions/exceptions.dart';
import 'package:near_social_mobile/modules/home/apis/near_social.dart';
import 'package:near_social_mobile/modules/home/pages/modern_design_test/modern_design_test_page.dart';
import 'package:near_social_mobile/modules/home/pages/people/widgets/donation_dialog.dart';
import 'package:near_social_mobile/modules/home/pages/people/widgets/more_actions_for_user_button.dart';
import 'package:near_social_mobile/modules/home/pages/people/widgets/user_page_tabs/user_nfts.dart';
import 'package:near_social_mobile/modules/home/pages/people/widgets/user_page_tabs/user_posts.dart';
import 'package:near_social_mobile/modules/home/pages/people/widgets/user_page_tabs/user_widgets.dart';
import 'package:near_social_mobile/modules/home/pages/posts_page/widgets/raw_text_to_content_formatter.dart';
import 'package:near_social_mobile/modules/home/vms/posts/posts_controller.dart';
import 'package:near_social_mobile/modules/home/vms/users/user_list_controller.dart';
import 'package:near_social_mobile/modules/vms/core/auth_controller.dart';
import 'package:near_social_mobile/modules/vms/core/filter_controller.dart';
import 'package:near_social_mobile/modules/vms/core/models/auth_info.dart';
import 'package:near_social_mobile/shared_widgets/custom_button.dart';
import 'package:near_social_mobile/shared_widgets/expandable_wiget.dart';
import 'package:near_social_mobile/shared_widgets/image_full_screen_page.dart';
import 'package:near_social_mobile/shared_widgets/near_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key, required this.accountId});

  final String accountId;

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _showTopBar = true;
  Timer? _hideTimer;
  int _selectedTab = 0;

  late List<BackgroundParticle> _particles;
  late AnimationController _bgController;
  Size _lastSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _bgController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat();
    _particles = [];

    final UserListController userListController =
        Modular.get<UserListController>();
    final user = userListController.state
        .getUserByAccountId(accountId: widget.accountId);

    final PostsController postsController = Modular.get<PostsController>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!user.allMetadataLoaded) {
        await userListController.loadAdditionalMetadata(
            accountId: widget.accountId);
        if (postsController.state.postsOfAccounts[widget.accountId] == null) {
          await postsController.loadPosts(
            postsViewMode: PostsViewMode.account,
            postsOfAccountId: widget.accountId,
          );
        }
      }
    });
  }

  void _handleScroll() {
    if (_showTopBar) setState(() => _showTopBar = false);
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showTopBar = true);
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _scrollController.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final FilterController filterController = Modular.get<FilterController>();

    if (_particles.isEmpty || _lastSize != screenSize) {
      _particles = List.generate(
        18,
        (i) => BackgroundParticle(screenSize, icons: [
          CupertinoIcons.person_fill,
          CupertinoIcons.heart_fill,
          CupertinoIcons.sparkles,
        ]),
      );
      _lastSize = screenSize;
    }

    return StreamBuilder(
      stream: filterController.stream,
      builder: (context, filterSnapshot) {
        final filtersUtil = FiltersUtil(filters: filterController.state);
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
      },
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
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
      top: _showTopBar ? 50 : -120,
      left: 0,
      right: 0,
      child: Center(
        child: _glassBar(
          360,
          Row(
            children: [
              GestureDetector(
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
              const Text('Profile',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      letterSpacing: -0.5)),
              const Spacer(),
              const SizedBox(width: 32),
            ],
          ),
          isDark,
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark, bool userIsBlocked, Size screenSize) {
    final UserListController userListController =
        Modular.get<UserListController>();
    final AuthController authController = Modular.get<AuthController>();

    return StreamBuilder(
      stream: userListController.stream.distinct(
        (previous, next) =>
            previous.getUserByAccountId(accountId: widget.accountId) ==
            next.getUserByAccountId(accountId: widget.accountId),
      ),
      builder: (context, snapshot) {
        final user = userListController.state
            .getUserByAccountId(accountId: widget.accountId);
        final isOwnProfile =
            widget.accountId == authController.state.accountId;

        if (userIsBlocked) {
          return _buildBlockedUserView(isDark, user, authController);
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: NestedScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(child: SizedBox(height: 100 + MediaQuery.of(context).padding.top)),

                  // Header card with background image, avatar, name, actions
                  SliverToBoxAdapter(
                    child: _buildHeaderCard(
                        isDark, user, authController, isOwnProfile),
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

                  // Tab selector
                  SliverToBoxAdapter(
                    child: _buildTabSelector(isDark),
                  ),
                ];
              },
              body: IndexedStack(
                index: _selectedTab,
                children: [
                  UserPostsView(accountIdOfUser: widget.accountId),
                  NftsView(accountIdOfUser: widget.accountId),
                  WidgetsView(accountIdOfUser: widget.accountId),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBlockedUserView(bool isDark, dynamic user, AuthController authController) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: 100 + MediaQuery.of(context).padding.top)),
            SliverToBoxAdapter(
              child: _buildHeaderCard(isDark, user, authController, false),
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
            const SliverToBoxAdapter(child: SizedBox(height: 140)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(
      bool isDark, dynamic user, AuthController authController, bool isOwnProfile) {
    final bool showFollowsYou = user.followings != null &&
        user.followings!.any(
          (element) => element.accountId == authController.state.accountId,
        );
    final bool inFollowerList = user.followers != null &&
        user.followers!.any(
          (follower) => follower.accountId == authController.state.accountId,
        );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
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
            child: Column(
              children: [
                // Background image
                GestureDetector(
                  onTap: () {
                    if (user.generalAccountInfo.backgroundImageLink.isEmpty) return;
                    Navigator.push(
                      Modular.routerDelegate.navigatorKey.currentContext!,
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
                            Modular.routerDelegate.navigatorKey.currentContext!,
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

                      // Action buttons
                      if (isOwnProfile)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: CupertinoButton(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 10),
                            color: isDark
                                ? CupertinoColors.white
                                : CupertinoColors.black,
                            borderRadius: BorderRadius.circular(20),
                            onPressed: () {
                              // Navigate to edit profile
                            },
                            child: Text('Edit Profile',
                                style: TextStyle(
                                    color: isDark ? Colors.black : Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600)),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _buildActionButtons(
                              isDark, user, authController, inFollowerList),
                        ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(
      bool isDark, dynamic user, AuthController authController, bool inFollowerList) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        // Follow/Following button
        if (user.followers != null)
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            color: inFollowerList
                ? (isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.08))
                : (isDark ? CupertinoColors.white : CupertinoColors.black),
            borderRadius: BorderRadius.circular(18),
            onPressed: () {
              if (inFollowerList) {
                _requestToUnfollowAccount(context);
              } else {
                _requestToFollowAccount(context);
              }
            },
            child: Text(
              inFollowerList ? "Following" : "Follow",
              style: TextStyle(
                color: inFollowerList
                    ? (isDark ? Colors.white : Colors.black)
                    : (isDark ? Colors.black : Colors.white),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

        // Poke button
        CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(18),
          onPressed: () async {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Poking user...")));
            try {
              if (await authController.getActivationStatus() !=
                  AccountActivationStatus.activated) {
                throw AccountNotActivatedException();
              }
              await Modular.get<NearSocialApi>()
                  .pokeAccount(
                accountIdToPoke: widget.accountId,
                accountId: authController.state.accountId,
                publicKey: authController.state.publicKey,
                privateKey: authController.state.privateKey,
              )
                  .then((_) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Poked @${widget.accountId}!")),
                );
              });
            } catch (err) {
              if (err is Exception) {
                throw Exception("Failed to poke ${widget.accountId}");
              } else {
                rethrow;
              }
            }
          },
          child: Text(
            "Poke",
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Donate button
        CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(18),
          onPressed: () {
            HapticFeedback.lightImpact();
            showDialog(
              context: context,
              builder: (context) => DonationDialog(receiverId: widget.accountId),
            );
          },
          child: Text(
            "Donate",
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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
        ),
      ),
    );
  }

  Widget _buildSocialLinks(bool isDark, dynamic user) {
    final linktree = user.generalAccountInfo.linktree as Map<String, dynamic>;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
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
          ),
        ),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
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
          ),
        ),
      ),
    );
  }

  Widget _buildDescription(bool isDark, dynamic user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
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
          ),
        ),
      ),
    );
  }

  Widget _buildTabSelector(bool isDark) {
    final tabs = ['Posts', 'NFTs', 'Widgets'];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: isDark
                      ? Colors.white10
                      : Colors.white.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: List.generate(tabs.length, (index) {
                final isActive = _selectedTab == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isActive
                            ? (isDark
                                ? Colors.white.withValues(alpha: 0.15)
                                : Colors.white.withValues(alpha: 0.8))
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        tabs[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isActive ? FontWeight.w700 : FontWeight.w500,
                          color: isActive
                              ? (isDark ? Colors.white : Colors.black)
                              : (isDark ? Colors.white54 : Colors.black54),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
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
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 22),
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

  Future<dynamic> _requestToUnfollowAccount(BuildContext context) {
    final UserListController userListController =
        Modular.get<UserListController>();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(
              "Are you sure you want to unfollow ${widget.accountId}?",
              style: const TextStyle(fontSize: 16)),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            CustomButton(
              primary: true,
              onPressed: () async {
                Modular.to.pop();
                try {
                  await userListController.unfollowAccount(
                    accountIdToUnfollow: widget.accountId,
                  );
                } catch (err) {
                  if (err is Exception) {
                    throw Exception("Failed to unfollow ${widget.accountId}");
                  } else {
                    rethrow;
                  }
                }
              },
              child: const Text("Yes",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            CustomButton(
              onPressed: () => Modular.to.pop(),
              child: const Text("No",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> _requestToFollowAccount(BuildContext context) {
    final UserListController userListController =
        Modular.get<UserListController>();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(
              "Are you sure you want to follow ${widget.accountId}?",
              style: const TextStyle(fontSize: 16)),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            CustomButton(
              primary: true,
              onPressed: () async {
                Modular.to.pop();
                try {
                  await userListController.followAccount(
                    accountIdToFollow: widget.accountId,
                  );
                } catch (err) {
                  if (err is Exception) {
                    throw Exception("Failed to follow ${widget.accountId}");
                  } else {
                    rethrow;
                  }
                }
              },
              child: const Text("Yes",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            CustomButton(
              onPressed: () => Modular.to.pop(),
              child: const Text("No",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
