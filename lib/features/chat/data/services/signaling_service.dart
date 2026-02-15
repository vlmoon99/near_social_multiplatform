import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

class SignalingService {
  static const _wsUrl = 'wss://p2ptest1.duckdns.org/ws';
  static const _maxReconnectDelay = Duration(seconds: 30);

  WebSocketChannel? _channel;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  String? _accountId;
  bool _disposed = false;
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;

  Stream<Map<String, dynamic>> get messages => _messageController.stream;
  bool get isConnected => _channel != null;

  Future<void> connect(String accountId) async {
    _accountId = accountId;
    _disposed = false;
    await _doConnect();
  }

  Future<void> _doConnect() async {
    if (_disposed || _accountId == null) return;

    try {
      _channel?.sink.close();
      _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));
      await _channel!.ready;

      // Register with signaling server
      _channel!.sink.add(jsonEncode({'userId': _accountId}));
      _reconnectAttempts = 0;

      _channel!.stream.listen(
        (data) {
          try {
            final msg = jsonDecode(data as String) as Map<String, dynamic>;
            _messageController.add(msg);
          } catch (_) {}
        },
        onDone: _onDisconnected,
        onError: (_) => _onDisconnected(),
      );
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _onDisconnected() {
    _channel = null;
    if (!_disposed) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _reconnectTimer?.cancel();
    final delay = Duration(
      seconds: (1 << _reconnectAttempts).clamp(1, _maxReconnectDelay.inSeconds),
    );
    _reconnectAttempts++;
    _reconnectTimer = Timer(delay, _doConnect);
  }

  void send(String targetId, String type, dynamic data) {
    if (_channel == null) return;
    _channel!.sink.add(jsonEncode({
      'targetId': targetId,
      'type': type,
      'data': data,
    }));
  }

  void disconnect() {
    _disposed = true;
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    disconnect();
    _messageController.close();
  }
}
