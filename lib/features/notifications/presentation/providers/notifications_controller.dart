import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:near_social_mobile/core/network/near_social_api.dart';
import 'package:near_social_mobile/core/providers/service_providers.dart';
import 'package:near_social_mobile/features/notifications/data/models/notification.dart';
import 'package:near_social_mobile/features/notifications/presentation/logic/notifications_events.dart';

part 'notifications_controller.freezed.dart';
part 'notifications_controller.g.dart';

enum NotificationsLoadingState { initial, loading, loaded }

@freezed
abstract class Notifications with _$Notifications {
  const factory Notifications({
    @Default(NotificationsLoadingState.initial) NotificationsLoadingState status,
    @Default([]) List<Notification> notifications,
  }) = _Notifications;
}

@Riverpod(keepAlive: true)
class NotificationsController extends _$NotificationsController {
  late NearSocialApi _nearSocialApi;

  @override
  Notifications build() {
    _nearSocialApi = ref.watch(nearSocialApiProvider);
    return const Notifications();
  }

  Future<void> onEvent(NotificationsEvent event) async {
    switch (event) {
      case LoadNotificationsEvent(:final accountId, :final loadingIndicator, :final from):
        await loadNotifications(accountId: accountId, loadingIndicator: loadingIndicator, from: from);
      case LoadMoreNotificationsEvent(:final accountId):
        await loadMoreNotifications(accountId: accountId);
      case ClearNotificationsEvent():
        clear();
    }
  }

  Future<void> loadNotifications({
    required String accountId,
    bool loadingIndicator = true,
    int? from,
  }) async {
    try {
      if (loadingIndicator) {
        state = state.copyWith(status: NotificationsLoadingState.loading);
      }
      final notifications = await _nearSocialApi.getNotificationsOfAccount(
        accountId: accountId,
        from: from,
      );
      if (state.status != NotificationsLoadingState.loading) {
        return;
      }
      state = state.copyWith(
        status: NotificationsLoadingState.loaded,
        notifications: notifications,
      );
    } catch (err) {
      state = state.copyWith(status: NotificationsLoadingState.initial);
      rethrow;
    }
  }

  Future<List<Notification>> loadMoreNotifications(
      {required String accountId}) async {
    try {
      final notifications = await _nearSocialApi.getNotificationsOfAccount(
        accountId: accountId,
        from: state.notifications.isNotEmpty
            ? state.notifications.last.blockHeight
            : 20,
      );
      notifications.removeWhere((notification) =>
          notification.blockHeight == state.notifications.last.blockHeight);
      state = state.copyWith(
        notifications: [...state.notifications, ...notifications],
      );
      return notifications;
    } catch (err) {
      rethrow;
    }
  }

  void clear() {
    state = const Notifications();
  }
}
