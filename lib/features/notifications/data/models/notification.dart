import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:near_social_mobile/features/people/data/models/general_account_info.dart';

part 'notification.freezed.dart';

@freezed
abstract class Notification with _$Notification {
  const factory Notification({
    required GeneralAccountInfo authorInfo,
    required int blockHeight,
    required DateTime date,
    required NotificationType notificationType,
  }) = _Notification;
}

enum NotificationTypes {
  star,
  poke,
  like,
  comment,
  follow,
  unfollow,
  mention,
  repost,
  unknown
}

@freezed
abstract class NotificationType with _$NotificationType {
  const factory NotificationType({
    required NotificationTypes type,
    required Map<String, dynamic> data,
  }) = _NotificationType;
}

NotificationTypes getNotificationType(String type) {
  switch (type) {
    case "star":
      return NotificationTypes.star;
    case "poke":
      return NotificationTypes.poke;
    case "like":
      return NotificationTypes.like;
    case "comment":
      return NotificationTypes.comment;
    case "follow":
      return NotificationTypes.follow;
    case "unfollow":
      return NotificationTypes.unfollow;
    case "mention":
      return NotificationTypes.mention;
    case "repost":
      return NotificationTypes.repost;
    default:
      return NotificationTypes.unknown;
  }
}

Map<String, dynamic> getNotificationData(
    dynamic rawData, NotificationTypes type) {
  switch (type) {
    case NotificationTypes.star:
      return {
        "path": rawData?["path"] ?? "",
      };
    case NotificationTypes.poke:
      return {};
    case NotificationTypes.like:
      return {
        "path": rawData?["path"] ?? "",
        "blockHeight": rawData?["blockHeight"] ?? 0,
      };
    case NotificationTypes.comment:
      return {
        "path": rawData?["path"] ?? "",
        "blockHeight": rawData?["blockHeight"] ?? 0,
      };
    case NotificationTypes.follow:
      return {};
    case NotificationTypes.unfollow:
      return {};
    case NotificationTypes.mention:
      return {
        "path": rawData?["path"] ?? "",
      };
    case NotificationTypes.repost:
      return {
        "path": rawData?["path"] ?? "",
        "blockHeight": rawData?["blockHeight"] ?? 0,
      };
    default:
      return {};
  }
}
