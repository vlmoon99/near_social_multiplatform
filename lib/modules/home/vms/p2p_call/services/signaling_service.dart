import 'dart:async';
import 'dart:convert';

import 'package:rxdart/rxdart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SignalingMessage {
  final String type;
  final String from;
  final Map<String, dynamic> data;

  SignalingMessage({
    required this.type,
    required this.from,
    required this.data,
  });

  @override
  String toString() =>
      'SignalingMessage(type: $type, from: $from, data: ${data.keys.toList()})';
}

class SignalingService {
  static const String _tag = '📡 SignalingService';
  static const String defaultWsUrl = 'wss://p2ptest1.duckdns.org/ws';

  WebSocketChannel? _channel;
  StreamSubscription? _channelSubscription;

  final BehaviorSubject<bool> _connectionStatus = BehaviorSubject.seeded(false);
  final PublishSubject<SignalingMessage> _messageStream = PublishSubject();

  Stream<bool> get connectionStream => _connectionStatus.stream;
  Stream<SignalingMessage> get messageStream => _messageStream.stream;
  bool get isConnected => _connectionStatus.value;

  Future<void> connect({required String userId, String? wsUrl}) async {
    final url = wsUrl ?? defaultWsUrl;
    print('$_tag: ──────────────────────────────────────');
    print('$_tag: connect() called');
    print('$_tag:   userId = $userId');
    print('$_tag:   wsUrl  = $url');
    print('$_tag: ──────────────────────────────────────');

    try {
      print('$_tag: Creating WebSocketChannel...');
      _channel = WebSocketChannel.connect(Uri.parse(url));

      print('$_tag: Waiting for channel.ready...');
      await _channel!.ready;
      print('$_tag: Channel is ready (WebSocket connected)');

      final registerPayload = jsonEncode({'userId': userId});
      print('$_tag: Sending registration: $registerPayload');
      _channel!.sink.add(registerPayload);

      _connectionStatus.add(true);
      print('$_tag: Connection status set to TRUE');

      _channelSubscription = _channel!.stream.listen(
        (raw) {
          print('$_tag: ← RAW message received: $raw');
          try {
            final msg = jsonDecode(raw as String) as Map<String, dynamic>;
            final parsed = SignalingMessage(
              type: msg['type'] as String? ?? '',
              from: msg['from'] as String? ?? '',
              data: msg['data'] as Map<String, dynamic>? ?? {},
            );
            print('$_tag: ← Parsed message: type=${parsed.type}, from=${parsed.from}, dataKeys=${parsed.data.keys.toList()}');
            _messageStream.add(parsed);
          } catch (e, st) {
            print('$_tag: ✗ Parse error: $e');
            print('$_tag: ✗ Stack trace: $st');
          }
        },
        onDone: () {
          print('$_tag: ✗ WebSocket closed (onDone)');
          print('$_tag:   closeCode: ${_channel?.closeCode}');
          print('$_tag:   closeReason: ${_channel?.closeReason}');
          _connectionStatus.add(false);
        },
        onError: (error, stackTrace) {
          print('$_tag: ✗ WebSocket error: $error');
          print('$_tag: ✗ Stack trace: $stackTrace');
          _connectionStatus.add(false);
        },
      );
      print('$_tag: Stream listener attached');
    } catch (e, st) {
      print('$_tag: ✗ connect() FAILED: $e');
      print('$_tag: ✗ Stack trace: $st');
      _connectionStatus.add(false);
      rethrow;
    }
  }

  void send(String targetId, String type, Map<String, dynamic> data) {
    if (_channel == null) {
      print('$_tag: ✗ send() SKIPPED — channel is null! type=$type, targetId=$targetId');
      return;
    }
    final payload = jsonEncode({
      'targetId': targetId,
      'type': type,
      'data': data,
    });
    print('$_tag: → SEND to=$targetId, type=$type, dataKeys=${data.keys.toList()}');
    print('$_tag: → Full payload: $payload');
    _channel!.sink.add(payload);
  }

  void disconnect() {
    print('$_tag: disconnect() called');
    _channelSubscription?.cancel();
    _channelSubscription = null;
    _channel?.sink.close();
    _channel = null;
    _connectionStatus.add(false);
    print('$_tag: Disconnected, status set to FALSE');
  }

  void dispose() {
    print('$_tag: dispose() called');
    disconnect();
    _connectionStatus.close();
    _messageStream.close();
  }
}
