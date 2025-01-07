import 'dart:convert';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();
  factory NotificationService() => instance;
  static final Dio _dio = Dio();
  static final notificationStream = BehaviorSubject<Notification>();

  static init({required String baseUrl}) async {
    _dio.options.baseUrl = baseUrl;
    web.window.onMessage.listen((event) {
      final data = event.data.dartify();
      if (data != null && data is Map && data["type"] == "PUSH_NOTIFICATION") {
        notificationStream.add(
            Notification.fromJson(Map<String, dynamic>.from(data["payload"])));
      }
    });
  }

  static Future<void> subscribeToPushNotifications() async {
    final vapidPublicKey = (await _dio.get('/vapidPublicKey')).data;
    final subscription =
        (await _subscribeToPushNotifications(vapidPublicKey).toDart)?.toDart;

    if (subscription == null) {
      throw Exception("User didn't allow notifications");
    }

    await _dio.post(
      '/register',
      data: {'subscription': jsonDecode(subscription)},
    );
  }

  /// `default` if not asked, then `granted` or `denied`
  static String getNotificationStatus() {
    return _getNotificationStatus();
  }

  static Future<bool> isUserSubscribed() async {
    return (await _isSubscriptionCreated().toDart).toDart;
  }

  static Future<void> unsubscribeFromPushNotifications() async {
    await _unsubscribeFromPushNotifications().toDart;
  }
}

class Notification {
  final String title;
  final String body;

  Notification({required this.title, required this.body});

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      title: json['title'],
      body: json['body'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
    };
  }

  @override
  String toString() {
    return 'Notification{title: $title, body: $body}';
  }
}

@JS("subscribeToPushNotifications")
external JSPromise<JSString?> _subscribeToPushNotifications(
    String vapidPublicKey);

@JS("getNotificationStatus")
external String _getNotificationStatus();

@JS("isSubscriptionCreated")
external JSPromise<JSBoolean> _isSubscriptionCreated();

@JS("unsubscribeFromPushNotifications")
external JSPromise _unsubscribeFromPushNotifications();
