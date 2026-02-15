import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:near_social_mobile/core/shared_widgets/glassmorphism_components.dart';
import 'package:near_social_mobile/features/notifications/presentation/providers/notifications_controller.dart';
import 'package:near_social_mobile/features/feed/presentation/providers/posts_controller.dart';
import 'package:near_social_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:near_social_mobile/core/providers/filter_controller.dart';
import 'package:near_social_mobile/core/router/routes.dart';
import 'package:near_social_mobile/core/providers/theme_controller.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage>
    with TickerProviderStateMixin {
  late final AnimationController _bgController =
      AnimationController(vsync: this, duration: const Duration(seconds: 1))
        ..repeat();
  List<BackgroundParticle> _particles = [];
  Size _lastSize = Size.zero;

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  Future<void> onLogoutTap(BuildContext context) async {
    HapticFeedback.lightImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _showGlassDialog(
      context: context,
      isDark: isDark,
      builder: (ctx) => _GlassAlertDialog(isDark: isDark),
    ).then(
      (value) async {
        if (value != null && value) {
          await ref.read(authControllerProvider.notifier).logout();
          ref.read(notificationsControllerProvider.notifier).clear();
          ref.read(filterControllerProvider.notifier).clear();
          ref.read(postsControllerProvider.notifier).clear();
          if (context.mounted) {
            context.go(AppRoutes.auth);
          }
        }
      },
    );
  }

  /// Common method for showing glass-dialogs with Material wrapper
  Future<T?> _showGlassDialog<T>({
    required BuildContext context,
    required bool isDark,
    required WidgetBuilder builder,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 350),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0)
                .animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
            child: child,
          ),
        );
      },
      pageBuilder: (ctx, anim1, anim2) {
        return Material(
          type: MaterialType.transparency,
          child: builder(ctx),
        );
      },
    );
  }

  Future<void> showNearSocialKeysDialog(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authInfo = ref.read(authControllerProvider);
    final accountPublicKey = authInfo.accountPublicKey;
    final accountId = authInfo.accountId;
    final link = "Account: $accountId\nPublic Key: $accountPublicKey";

    if (!context.mounted) return;
    _showGlassDialog(
      context: context,
      isDark: isDark,
      builder: (ctx) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Container(
              margin: const EdgeInsets.all(32),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: isDark ? Colors.white24 : Colors.black12,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Near Social Key',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: QrImageView(
                            data: link,
                            version: QrVersions.auto,
                            size: 200,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Scan to sign in on another device',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white60 : Colors.black45,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _glassButton(
                          label: "common.close".tr(),
                          icon: CupertinoIcons.xmark,
                          isDark: isDark,
                          onTap: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _glassButton({
    required String label,
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color ?? (isDark ? Colors.white : Colors.black)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: color ?? (isDark ? Colors.white : Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_particles.isEmpty || _lastSize != screenSize) {
      _particles = List.generate(
          10, (i) => BackgroundParticle(screenSize, icons: ['assets/media/icons/near_social_logo.svg', CupertinoIcons.bell_fill, 'assets/media/icons/near_social_logo.svg']));
      _lastSize = screenSize;
    }

    final themeMode = ref.watch(themeControllerProvider);

    final settingsItems = [
      _SettingsItem(
        icon: CupertinoIcons.qrcode,
        title: "settings.near_social_key".tr(),
        subtitle: "settings.near_social_key_subtitle".tr(),
        onTap: () {
          HapticFeedback.lightImpact();
          showNearSocialKeysDialog(context);
        },
      ),
      _SettingsItem(
        icon: CupertinoIcons.person_crop_circle_badge_xmark,
        title: "settings.blocked_users".tr(),
        subtitle: "settings.blocked_users_subtitle".tr(),
        onTap: () {
          HapticFeedback.lightImpact();
          context.push(AppRoutes.blockedUsers);
        },
      ),
      _SettingsItem(
        icon: CupertinoIcons.eye_slash_fill,
        title: "settings.hidden_posts".tr(),
        subtitle: "settings.hidden_posts_subtitle".tr(),
        onTap: () {
          HapticFeedback.lightImpact();
          context.push(AppRoutes.hiddenPosts);
        },
      ),
    ];

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
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 550),
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
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
                            "settings.title".tr(),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Settings list
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          ...settingsItems.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: item.onTap,
                              child: GlassContainer(
                                isDark: isDark,
                                margin: EdgeInsets.zero,
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Colors.white.withValues(alpha: 0.1)
                                            : Colors.black.withValues(alpha: 0.06),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        item.icon,
                                        size: 24,
                                        color: isDark ? Colors.white : Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.title,
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            item.subtitle,
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
                                    Icon(
                                      CupertinoIcons.chevron_right,
                                      size: 18,
                                      color: isDark ? Colors.white38 : Colors.black26,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )),

                          // Theme toggle
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GlassContainer(
                              isDark: isDark,
                              margin: EdgeInsets.zero,
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.1)
                                          : Colors.black.withValues(alpha: 0.06),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      isDark ? CupertinoIcons.moon_fill : CupertinoIcons.sun_max_fill,
                                      size: 24,
                                      color: isDark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "settings.appearance".tr(),
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                            color: isDark ? Colors.white : Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          themeMode == ThemeMode.dark
                                              ? "settings.theme_dark".tr()
                                              : themeMode == ThemeMode.light
                                                  ? "settings.theme_light".tr()
                                                  : "settings.theme_system".tr(),
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isDark ? Colors.white54 : Colors.black45,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  CupertinoSlidingSegmentedControl<ThemeMode>(
                                    groupValue: themeMode,
                                    backgroundColor: isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : Colors.black.withValues(alpha: 0.06),
                                    thumbColor: isDark
                                        ? const Color(0xFF2C2C2E)
                                        : Colors.white,
                                    children: {
                                      ThemeMode.light: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        child: Icon(CupertinoIcons.sun_max_fill, size: 16,
                                            color: isDark ? Colors.white70 : Colors.black87),
                                      ),
                                      ThemeMode.system: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        child: Icon(CupertinoIcons.device_phone_portrait, size: 16,
                                            color: isDark ? Colors.white70 : Colors.black87),
                                      ),
                                      ThemeMode.dark: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        child: Icon(CupertinoIcons.moon_fill, size: 16,
                                            color: isDark ? Colors.white70 : Colors.black87),
                                      ),
                                    },
                                    onValueChanged: (mode) {
                                      if (mode != null) {
                                        HapticFeedback.lightImpact();
                                        ref.read(themeControllerProvider.notifier).setThemeMode(mode);
                                      }
                                    },
                                  ),
                                ],
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

          // Logout button at bottom
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => onLogoutTap(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: isDark ? 0.3 : 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.square_arrow_left,
                          color: Colors.red.shade300, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.red.shade300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

class _GlassAlertDialog extends StatelessWidget {
  final bool isDark;
  const _GlassAlertDialog({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Container(
          margin: const EdgeInsets.all(40),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.7)
                      : Colors.white.withValues(alpha: 0.85),
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
                              Navigator.pop(context, false);
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
                              Navigator.pop(context, true);
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
}
