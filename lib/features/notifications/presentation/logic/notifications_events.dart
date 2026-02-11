sealed class NotificationsEvent {}

class LoadNotificationsEvent extends NotificationsEvent {
  final String accountId;
  final bool loadingIndicator;
  final int? from;
  LoadNotificationsEvent({
    required this.accountId,
    this.loadingIndicator = true,
    this.from,
  });
}

class LoadMoreNotificationsEvent extends NotificationsEvent {
  final String accountId;
  LoadMoreNotificationsEvent({required this.accountId});
}

class ClearNotificationsEvent extends NotificationsEvent {}
