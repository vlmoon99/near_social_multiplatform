import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:near_social_mobile/core/services/crypto_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// TURN credentials received from the signaling server after authentication.
class TurnCredentials {
  final String host;
  final String username;
  final String password;

  const TurnCredentials({
    required this.host,
    required this.username,
    required this.password,
  });
}

class SignalingService {
  static const _wsUrl =
      'wss://18becad2e1cdf1e0331d05b77d243257a7a502a1.dstack-pha-prod9.phala.network/ws';
  static const _defaultTurnHost =
      '18becad2e1cdf1e0331d05b77d243257a7a502a1-3478.dstack-pha-prod9.phala.network';
  static const _maxReconnectDelay = Duration(seconds: 30);

  WebSocketChannel? _channel;
  final _messageController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _authCompleter = Completer<void>();

  String? _accountId;
  Uint8List? _privateKey;
  Uint8List? _publicKey;

  bool _disposed = false;
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;

  TurnCredentials? turnCredentials;

  /// Raw attestation data from the server (null if not provided / dev mode).
  dynamic attestation;

  Stream<Map<String, dynamic>> get messages => _messageController.stream;
  bool get isConnected => _channel != null;

  /// Waits until signaling authentication is complete and TURN credentials
  /// are available.
  Future<void> get authenticated => _authCompleter.future;

  /// Connect with NEAR signature-based authentication.
  ///
  /// [accountId] — the NEAR account id.
  /// [privateKey] — 64-byte Ed25519 private key used for signing.
  /// [publicKey] — 32-byte Ed25519 public key (sent to server as ed25519:base58).
  Future<void> connect(
    String accountId, {
    required Uint8List privateKey,
    required Uint8List publicKey,
  }) async {
    _accountId = accountId;
    _privateKey = privateKey;
    _publicKey = publicKey;
    _disposed = false;
    await _doConnect();
  }

  Future<void> _doConnect() async {
    if (_disposed || _accountId == null) return;

    try {
      _channel?.sink.close();
      _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));
      await _channel!.ready;

      // Authenticate via NEAR signature
      final message =
          'Authenticate to Signaling Server at ${DateTime.now().toUtc().toIso8601String()}';
      final messageBytes = Uint8List.fromList(utf8.encode(message));
      final signature = CryptoService.signMessage(_privateKey!, messageBytes);

      final authPayload = jsonEncode({
        'accountId': _accountId,
        'publicKey': 'ed25519:${Base58.encode(_publicKey!)}',
        'signature': Base58.encode(signature),
        'message': message,
      });
      _channel!.sink.add(authPayload);

      _reconnectAttempts = 0;

      _channel!.stream.listen(
        (data) {
          try {
            final msg = jsonDecode(data as String) as Map<String, dynamic>;
            _handleMessage(msg);
          } catch (_) {}
        },
        onDone: _onDisconnected,
        onError: (_) => _onDisconnected(),
      );
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _handleMessage(Map<String, dynamic> msg) {
    // Auth success response
    if (msg['status'] == 'authenticated') {
      final turn = msg['turn'] as Map<String, dynamic>?;
      if (turn != null) {
        turnCredentials = TurnCredentials(
          host: (turn['host'] as String?) ?? _defaultTurnHost,
          username: turn['username'] as String? ?? '',
          password: turn['password'] as String? ?? '',
        );
      }
      attestation = msg['attestation'];
      if (!_authCompleter.isCompleted) {
        _authCompleter.complete();
      }
      return;
    }

    // Auth error
    if (msg['error'] != null) {
      if (!_authCompleter.isCompleted) {
        _authCompleter.completeError(
            Exception('Signaling auth failed: ${msg['error']}'));
      }
      _channel?.sink.close();
      return;
    }

    // Regular signaling message — normalize "from" to "senderId"
    if (msg.containsKey('from') && !msg.containsKey('senderId')) {
      msg['senderId'] = msg['from'];
    }

    _messageController.add(msg);
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
