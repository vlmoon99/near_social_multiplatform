import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_social_mobile/features/notifications/presentation/ui/widgets/notification_tile.dart';
import 'package:near_social_mobile/features/notifications/presentation/providers/notifications_controller.dart';
import 'package:near_social_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:near_social_mobile/core/providers/filter_controller.dart';
import 'package:near_social_mobile/core/shared_widgets/custom_button.dart';
import 'package:near_social_mobile/core/shared_widgets/spinner_loading_indicator.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key, this.onScroll});

  final VoidCallback? onScroll;

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool allNotificationsLoaded = false;
  bool moreNotificationsLoading = false;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      widget.onScroll?.call();
    });
  }

  Future<void> loadMoreNotifications() async {
    final notificationsController =
        ref.read(notificationsControllerProvider.notifier);
    final authInfo = ref.read(authControllerProvider);
    try {
      if (!mounted) return;

      setState(() {
        moreNotificationsLoading = true;
      });

      final moreNotifications =
          await notificationsController.loadMoreNotifications(
        accountId: authInfo.accountId,
      );
      if (moreNotifications.isEmpty) {
        if (mounted) {
          setState(() {
            allNotificationsLoaded = true;
          });
        }
      }
    } catch (err) {
      rethrow;
    } finally {
      if (mounted) {
        setState(() {
          moreNotificationsLoading = false;
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    final notificationsState = ref.read(notificationsControllerProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (notificationsState.status ==
          NotificationsLoadingState.initial) {
        final authInfo = ref.read(authControllerProvider);
        final accountId = authInfo.accountId;
        ref.read(notificationsControllerProvider.notifier).loadNotifications(accountId: accountId);
      }
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final authInfo = ref.watch(authControllerProvider);
    final notificationsState = ref.watch(notificationsControllerProvider);
    final filterState = ref.watch(filterControllerProvider);

    if (notificationsState.status !=
        NotificationsLoadingState.loaded) {
      return const Center(
        child: SpinnerLoadingIndicator(),
      );
    }
    return RefreshIndicator.adaptive(
      onRefresh: () async {
        await ref.read(notificationsControllerProvider.notifier).loadNotifications(
          accountId: authInfo.accountId,
          loadingIndicator: false,
        );
      },
      child: Builder(builder: (context) {
        final filterUtil = FiltersUtil(filters: filterState);
        final notifications = notificationsState.notifications
            .where((notification) => !filterUtil
                .userIsBlocked(notification.authorInfo.accountId))
            .toList();

        if (notifications.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) {
              if (notificationsState.status ==
                      NotificationsLoadingState.loaded &&
                  !moreNotificationsLoading &&
                  !allNotificationsLoaded) {
                loadMoreNotifications();
              }
            },
          );

          return Center(
            child: ListView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              children: [
                const SizedBox(height: 300),
                Center(
                  child: Text(
                    "notifications.no_notifications".tr(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: ListView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                if (index == 0) {
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) {
                      if (_scrollController.hasClients &&
                          _scrollController.position.maxScrollExtent == 0 &&
                          notificationsState.status ==
                              NotificationsLoadingState.loaded &&
                          !moreNotificationsLoading &&
                          !allNotificationsLoaded) {
                        loadMoreNotifications();
                      }
                    },
                  );
                  return const SizedBox(height: 90);
                }

                if (index == notifications.length + 1) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 140),
                    child: RPadding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 16),
                      child: moreNotificationsLoading
                          ? const Center(child: SpinnerLoadingIndicator())
                          : (notifications.length < 20 &&
                                  allNotificationsLoaded)
                              ? const SizedBox.shrink()
                              : CustomButton(
                                  onPressed: allNotificationsLoaded
                                      ? null
                                      : () async {
                                          loadMoreNotifications();
                                        },
                                  child: Text(
                                    allNotificationsLoaded
                                        ? "notifications.no_more".tr()
                                        : "notifications.load_more".tr(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                    ),
                  );
                }

                final notification = notifications[index - 1];
                return Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: index == 1 ? 5 : 0,
                  ),
                  child: NotificationTile(
                    key: ValueKey('${notification.authorInfo.accountId}_${notification.blockHeight}'),
                    notification: notification,
                  ),
                );
              },
              itemCount: notifications.length + 2,
            ),
          ),
        );
      }),
    );
  }
}
