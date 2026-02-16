import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:near_social_mobile/core/config/constants.dart';
import 'package:near_social_mobile/features/notifications/presentation/providers/notifications_controller.dart';
import 'package:near_social_mobile/features/feed/presentation/providers/posts_controller.dart';
import 'package:near_social_mobile/features/people/data/models/user_list_state.dart';
import 'package:near_social_mobile/features/people/presentation/providers/user_list_controller.dart';
import 'package:near_social_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:near_social_mobile/core/providers/filter_controller.dart';
import 'package:near_social_mobile/core/router/routes.dart';
import 'package:near_social_mobile/core/shared_widgets/app_toast.dart';
import 'package:near_social_mobile/core/shared_widgets/near_network_image.dart';
import 'package:near_social_mobile/core/shared_widgets/spinner_loading_indicator.dart';

class HomeMenuPage extends ConsumerStatefulWidget {
  const HomeMenuPage({super.key, this.onScroll});

  final VoidCallback? onScroll;

  @override
  ConsumerState<HomeMenuPage> createState() => _HomeMenuPageState();
}

class _HomeMenuPageState extends ConsumerState<HomeMenuPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final ScrollController _scrollController = ScrollController();
  FullUserInfo? user;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      widget.onScroll?.call();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (loading) {
      _loadProfileData();
    }
  }

  void _loadProfileData() {
    final authInfo = ref.read(authControllerProvider);
    final userListController = ref.read(userListControllerProvider.notifier);
    // Load user info asynchronously -- don't block the UI
    userListController
        .loadAndAddGeneralAccountInfoIfNotExists(
            accountId: authInfo.accountId)
        .then((_) {
      if (mounted) {
        final userListState = ref.read(userListControllerProvider);
        setState(() {
          user = userListState
              .getUserByAccountId(accountId: authInfo.accountId);
          loading = false;
        });
      }
    });

    // Load followers/following metadata
    userListController
        .loadAdditionalMetadata(accountId: authInfo.accountId)
        .then((_) {
      if (mounted) {
        final userListState = ref.read(userListControllerProvider);
        setState(() {
          user = userListState
              .getUserByAccountId(accountId: authInfo.accountId);
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onLogoutTap() async {
    HapticFeedback.lightImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => Material(
        type: MaterialType.transparency,
        child: _buildLogoutDialog(isDark),
      ),
    ).then((value) async {
      if (value != null && value) {
        await ref.read(authControllerProvider.notifier).logout();
        ref.read(notificationsControllerProvider.notifier).clear();
        ref.read(filterControllerProvider.notifier).clear();
        ref.read(postsControllerProvider.notifier).clear();
        if (context.mounted) {
          context.go(AppRoutes.auth);
        }
      }
    });
  }

  Widget _buildLogoutDialog(bool isDark) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
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
                      color: Colors.red.withValues(alpha: isDark ? 0.2 : 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(CupertinoIcons.square_arrow_left,
                        color: Colors.red.shade300, size: 26),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Logout?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Are you sure you want to sign out?',
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
                            padding: const EdgeInsets.symmetric(vertical: 14),
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
                                  color: isDark ? Colors.white : Colors.black,
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
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: isDark ? 0.3 : 0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.red.withValues(alpha: 0.3)),
                            ),
                            child: Center(
                              child: Text(
                                'Logout',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Colors.red.shade300,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authInfo = ref.watch(authControllerProvider);

    if (loading) {
      return const Center(child: SpinnerLoadingIndicator());
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 90)),

            // Profile header card
            SliverToBoxAdapter(
              child: _buildProfileHeader(isDark, authInfo),
            ),

            // Stats row
            SliverToBoxAdapter(
              child: _buildStatsRow(isDark),
            ),

            // Menu items
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildMenuTile(
                    icon: Icon(CupertinoIcons.settings_solid,
                        size: 20,
                        color: isDark ? Colors.white70 : Colors.black87),
                    title: "settings.title".tr(),
                    isDark: isDark,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push(AppRoutes.settings);
                    },
                  ),
                  const SizedBox(height: 16),
                  // Logout button
                  _buildLogoutTile(isDark),
                ]),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 90)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark, authInfo) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
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
                // Avatar
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.push(
                      "${AppRoutes.userProfile}?accountId=${authInfo.accountId}",
                    );
                  },
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? Colors.white24 : Colors.black12,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: NearNetworkImage(
                        imageUrl:
                            user?.generalAccountInfo.profileImageLink ?? '',
                        errorPlaceholder: Image.asset(
                          NearAssets.standartAvatar,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.generalAccountInfo.name != ""
                      ? (user?.generalAccountInfo.name ?? "people.no_name".tr())
                      : "people.no_name".tr(),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Clipboard.setData(ClipboardData(
                        text: authInfo.accountId));
                    showAppToast(context, "people.account_id_copied".tr(namedArgs: {"accountId": authInfo.accountId}));
                  },
                  child: Text(
                    "@${authInfo.accountId}",
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CupertinoButton(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                  color:
                      isDark ? CupertinoColors.white : CupertinoColors.black,
                  borderRadius: BorderRadius.circular(20),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.push(
                      "${AppRoutes.userProfile}?accountId=${authInfo.accountId}",
                    );
                  },
                  child: Text("people.view_profile".tr(),
                      style: TextStyle(
                          color: isDark ? Colors.black : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
    );
  }

  Widget _buildStatsRow(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          _statBox(
            user?.followers != null
                ? user!.followers!.length.toString()
                : "...",
            "people.followers".tr(),
            isDark,
          ),
          const SizedBox(width: 8),
          _statBox(
            user?.followings != null
                ? user!.followings!.length.toString()
                : "...",
            "people.following".tr(),
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
                overflow: TextOverflow.ellipsis),
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

  Widget _buildMenuTile({
    required Widget icon,
    required String title,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(20),
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
        child: Row(
          children: [
            icon,
            const SizedBox(width: 16),
            Text(title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: isDark ? Colors.white : Colors.black,
                )),
            const Spacer(),
            Icon(CupertinoIcons.chevron_right,
                size: 14,
                color: isDark ? Colors.white38 : Colors.black38),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutTile(bool isDark) {
    return GestureDetector(
      onTap: _onLogoutTap,
      child: Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.red.withValues(alpha: 0.15)
              : Colors.red.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: isDark
                  ? Colors.red.withValues(alpha: 0.3)
                  : Colors.red.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(CupertinoIcons.square_arrow_left,
                size: 20, color: Colors.redAccent),
            const SizedBox(width: 16),
            Text("common.logout".tr(),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.redAccent,
                )),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
