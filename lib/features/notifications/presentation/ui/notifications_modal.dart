import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:near_social_mobile/core/config/animation_constants.dart';
import 'package:near_social_mobile/features/notifications/data/models/notification.dart'
    as app_notification;
import 'package:near_social_mobile/features/notifications/presentation/ui/widgets/notification_tile.dart';
import 'package:near_social_mobile/features/notifications/presentation/providers/notifications_controller.dart';
import 'package:near_social_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:near_social_mobile/core/providers/filter_controller.dart';
import 'package:near_social_mobile/core/shared_widgets/spinner_loading_indicator.dart';
import 'package:near_social_mobile/core/shared_widgets/tappable_scale_widget.dart';

/// Shows notifications in a glassmorphism modal dialog.
void showNotificationsModal(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "notifications.close".tr(),
    barrierColor: Colors.black.withValues(alpha: 0.5),
    transitionDuration: AppAnimations.modalTransition,
    pageBuilder: (ctx, anim1, anim2) => NotificationsModal(isDark: isDark),
    transitionBuilder: (ctx, anim1, anim2, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.25),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: anim1,
          curve: AppAnimations.modalCurve,
        )),
        child: FadeTransition(opacity: anim1, child: child),
      );
    },
  );
}

class NotificationsModal extends ConsumerStatefulWidget {
  final bool isDark;

  const NotificationsModal({super.key, required this.isDark});

  @override
  ConsumerState<NotificationsModal> createState() => _NotificationsModalState();
}

class _NotificationsModalState extends ConsumerState<NotificationsModal> {
  final ScrollController _scrollController = ScrollController();
  bool _allNotificationsLoaded = false;
  bool _moreLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialIfNeeded();
  }

  void _loadInitialIfNeeded() {
    final notificationsState = ref.read(notificationsControllerProvider);
    if (notificationsState.status ==
        NotificationsLoadingState.initial) {
      final authInfo = ref.read(authControllerProvider);
      ref.read(notificationsControllerProvider.notifier).loadNotifications(
        accountId: authInfo.accountId,
      );
    }
  }

  Future<void> _refresh() async {
    final authInfo = ref.read(authControllerProvider);
    await ref.read(notificationsControllerProvider.notifier).loadNotifications(
      accountId: authInfo.accountId,
    );
    _allNotificationsLoaded = false;
  }

  Future<void> _loadMore() async {
    if (_moreLoading || _allNotificationsLoaded) return;
    setState(() => _moreLoading = true);

    try {
      final authInfo = ref.read(authControllerProvider);
      final notifications =
          await ref.read(notificationsControllerProvider.notifier).loadMoreNotifications(
        accountId: authInfo.accountId,
      );
      if (notifications.isEmpty) {
        _allNotificationsLoaded = true;
      }
    } finally {
      if (mounted) setState(() => _moreLoading = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: screenHeight * 0.8,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 40,
                spreadRadius: 5,
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
                    : Colors.white.withValues(alpha: 0.85),
                child: Column(
                  children: [
                    _buildHeader(isDark),
                    Divider(
                      height: 1,
                      color: isDark ? Colors.white10 : Colors.black12,
                    ),
                    Expanded(child: _buildNotificationsList(isDark)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          TappableScaleWidget(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.xmark,
                color: isDark ? Colors.white70 : Colors.black54,
                size: 16,
              ),
            ),
          ),
          const Spacer(),
          Text(
            "notifications.title".tr(),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              letterSpacing: -0.5,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 32), // Balance the close button
        ],
      ),
    );
  }

  Widget _buildNotificationsList(bool isDark) {
    final notificationsState = ref.watch(notificationsControllerProvider);
    final filterState = ref.watch(filterControllerProvider);

    if (notificationsState.status !=
        NotificationsLoadingState.loaded) {
      return const Center(child: SpinnerLoadingIndicator());
    }

    final filterUtil = FiltersUtil(filters: filterState);
    final notifications = notificationsState.notifications
        .where((n) => !filterUtil.userIsBlocked(n.authorInfo.accountId))
        .toList();

    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.bell_slash,
              size: 48,
              color: isDark ? Colors.white30 : Colors.black26,
            ),
            const SizedBox(height: 12),
            Text(
              "notifications.no_notifications".tr(),
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      color: CupertinoColors.activeBlue,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification) {
            if (_scrollController.position.extentAfter < 200) {
              _loadMore();
            }
          }
          return false;
        },
        child: ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.all(12),
          itemCount: notifications.length + (_moreLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == notifications.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: SpinnerLoadingIndicator()),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _GlassNotificationTile(
                notification: notifications[index],
                isDark: isDark,
                onNavigate: () => Navigator.pop(context),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Glassmorphism-styled notification tile
class _GlassNotificationTile extends StatelessWidget {
  final app_notification.Notification notification;
  final bool isDark;
  final VoidCallback onNavigate;

  const _GlassNotificationTile({
    required this.notification,
    required this.isDark,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return TappableScaleWidget(
      scaleDown: 0.98,
      onTap: onNavigate,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white12
                    : Colors.black.withValues(alpha: 0.08),
              ),
            ),
            child: NotificationTile(notification: notification),
          ),
        ),
      ),
    );
  }
}
