import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_social_mobile/modules/home/pages/notifications/widgets/notification_tile.dart';
import 'package:near_social_mobile/modules/home/vms/notifications/notifications_controller.dart';
import 'package:near_social_mobile/modules/vms/core/auth_controller.dart';
import 'package:near_social_mobile/modules/vms/core/filter_controller.dart';
import 'package:near_social_mobile/shared_widgets/custom_button.dart';
import 'package:near_social_mobile/shared_widgets/spinner_loading_indicator.dart';
import 'package:rxdart/rxdart.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key, this.onScroll});

  final VoidCallback? onScroll;

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
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
    final NotificationsController notificationsController =
        Modular.get<NotificationsController>();
    final AuthController authController = Modular.get<AuthController>();
    try {
      if (!mounted) return;

      setState(() {
        moreNotificationsLoading = true;
      });

      final moreNotifications =
          await notificationsController.loadMoreNotifications(
        accountId: authController.state.accountId,
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
    final NotificationsController notificationsController =
        Modular.get<NotificationsController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (notificationsController.state.status ==
          NotificationsLoadingState.initial) {
        final AuthController authController = Modular.get<AuthController>();
        final accountId = authController.state.accountId;
        notificationsController.loadNotifications(accountId: accountId);
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
    final AuthController authController = Modular.get<AuthController>();
    final NotificationsController notificationsController =
        Modular.get<NotificationsController>();
    final FilterController filterController = Modular.get<FilterController>();

    return StreamBuilder(
      stream:
          Rx.merge([notificationsController.stream, filterController.stream]),
      builder: (context, snapshot) {
        if (notificationsController.state.status !=
            NotificationsLoadingState.loaded) {
          return const Center(
            child: SpinnerLoadingIndicator(),
          );
        }
        return RefreshIndicator.adaptive(
          onRefresh: () async {
            await notificationsController.loadNotifications(
              accountId: authController.state.accountId,
              loadingIndicator: false,
            );
          },
          child: Builder(builder: (context) {
            final filterUtil = FiltersUtil(filters: filterController.state);
            final notifications = notificationsController.state.notifications
                .where((notification) => !filterUtil
                    .userIsBlocked(notification.authorInfo.accountId))
                .toList();

            if (notifications.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) {
                  if (notificationsController.state.status ==
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
                  children: const [
                    SizedBox(height: 300),
                    Center(
                      child: Text(
                        "No notifications",
                        style: TextStyle(
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
                              notificationsController.state.status ==
                                  NotificationsLoadingState.loaded &&
                              !moreNotificationsLoading &&
                              !allNotificationsLoaded) {
                            loadMoreNotifications();
                          }
                        },
                      );
                      return const SizedBox(height: 140);
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
                                            ? "No more notifications"
                                            : "Load more notifications",
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
                      child: NotificationTile(notification: notification),
                    );
                  },
                  itemCount: notifications.length + 2,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
