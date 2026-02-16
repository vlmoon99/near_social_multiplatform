import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:near_social_mobile/core/providers/service_providers.dart';
import 'package:near_social_mobile/core/services/crypto_service.dart';
import 'package:near_social_mobile/core/services/near_connect_service_stub.dart'
    if (dart.library.js_interop) 'package:near_social_mobile/core/services/near_connect_service.dart';
import 'package:near_social_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:near_social_mobile/features/chat/data/models/chat_message.dart';
import 'package:near_social_mobile/features/chat/data/models/chat_state.dart';
import 'package:near_social_mobile/features/chat/data/services/chat_encryption_service.dart';
import 'package:near_social_mobile/features/chat/data/services/chat_storage_service.dart';
import 'package:near_social_mobile/features/chat/data/services/signaling_service.dart';
import 'package:near_social_mobile/features/chat/data/services/webrtc_service.dart';
import 'package:near_social_mobile/features/chat/presentation/logic/chat_events.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_controller.g.dart';

@Riverpod(keepAlive: true)
class ChatController extends _$ChatController {
  SignalingService? _signaling;
  WebRTCService? _webrtc;
  final List<StreamSubscription> _subscriptions = [];

  // Video renderers — managed outside freezed state
  RTCVideoRenderer? localRenderer;
  RTCVideoRenderer? remoteRenderer;

  ChatEncryptionService get _encryption =>
      ref.read(chatEncryptionServiceProvider);
  ChatStorageService get _storage => ref.read(chatStorageServiceProvider);

  @override
  ChatState build() {
    // Auto-connect when auth state changes
    ref.listen(authControllerProvider, (prev, next) {
      if (next.accountId.isNotEmpty && _signaling == null) {
        onEvent(ConnectSignalingEvent());
      }
      if (next.accountId.isEmpty && _signaling != null) {
        onEvent(DisconnectSignalingEvent());
      }
    });

    // If already authenticated at build time, connect immediately
    final auth = ref.read(authControllerProvider);
    if (auth.accountId.isNotEmpty) {
      Future.microtask(() => onEvent(ConnectSignalingEvent()));
    }

    return const ChatState();
  }

  Future<void> onEvent(ChatEvent event) async {
    switch (event) {
      case ConnectSignalingEvent():
        await _connectSignaling();
      case DisconnectSignalingEvent():
        _disconnectSignaling();
      case StartChatEvent(:final targetAccountId):
        await _startChat(targetAccountId);
      case SendMessageEvent(:final text):
        await _sendMessage(text);
      case StartCallEvent(:final targetAccountId, :final video):
        await _startCall(targetAccountId, video);
      case AcceptCallEvent():
        await _acceptCall();
      case RejectCallEvent():
        _rejectCall();
      case EndCallEvent():
        await _endCall();
      case ToggleVideoEvent():
        _toggleVideo();
      case ToggleAudioEvent():
        _toggleAudio();
      case StartScreenShareEvent():
        await _startScreenShare();
      case StopScreenShareEvent():
        await _stopScreenShare();
      case LoadHistoryEvent(:final peerId):
        await _loadHistory(peerId);
      case ClearHistoryEvent():
        await _clearHistory();
    }
  }

  // --- Auth helpers ---

  String get _myAccountId => ref.read(authControllerProvider).accountId;

  Uint8List get _myPrivateKey =>
      base64.decode(ref.read(authControllerProvider).devicePrivateKey);

  String get _myPublicKeyBase64 =>
      ref.read(authControllerProvider).devicePublicKey;

  Uint8List? get _peerPublicKey {
    final pk = state.peerPublicKey;
    if (pk == null || pk.isEmpty) return null;
    return base64.decode(pk);
  }

  // --- Signaling ---

  Future<void> _connectSignaling() async {
    final auth = ref.read(authControllerProvider);
    if (auth.accountId.isEmpty) return;

    // Build the appropriate auth payload builder based on login type.
    final AuthPayloadBuilder buildAuthPayload;

    if (auth.accountPrivateKey.isNotEmpty) {
      // Key login: sign with raw Ed25519 private key
      final privateKey = base64.decode(auth.accountPrivateKey);
      final publicKey = Uint8List.sublistView(privateKey, 32, 64);
      buildAuthPayload = (message) async => {
            'accountId': auth.accountId,
            'publicKey': 'ed25519:${Base58.encode(publicKey)}',
            'signature': Base58.encode(
              CryptoService.signMessage(
                  privateKey, Uint8List.fromList(utf8.encode(message))),
            ),
            'message': message,
          };
    } else if (kIsWeb) {
      // Wallet login on web: use NEP-413 signMessage
      buildAuthPayload = (message) async {
        final result = await NearConnectService.signMessage(
          message,
          'signaling-server',
        );
        return {
          'authType': 'nep413',
          'accountId': auth.accountId,
          'publicKey': result.publicKey,
          'signature': result.signature,
          'message': message,
          'nonce': result.nonce,
          'recipient': 'signaling-server',
        };
      };
    } else {
      // No private key and not on web — cannot authenticate
      return;
    }

    _signaling = SignalingService();
    try {
      await _signaling!.connect(
        auth.accountId,
        buildAuthPayload: buildAuthPayload,
      );
    } catch (_) {
      // Connection failed (network error etc.)
      _signaling = null;
      return;
    }

    // Check if auth was rejected by the server
    if (_signaling!.authError != null) {
      _signaling!.disconnect();
      _signaling = null;
      return;
    }

    // Store TEE attestation (null if server is in dev mode)
    final att = _signaling!.attestation;
    state = state.copyWith(
      signalingConnected: true,
      teeAttestation: att is String ? att : att?.toString(),
    );

    _subscriptions.add(
      _signaling!.messages.listen(_handleSignalingMessage),
    );
  }

  void _disconnectSignaling() {
    _signaling?.disconnect();
    _signaling = null;
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    state = state.copyWith(signalingConnected: false);
  }

  void _handleSignalingMessage(Map<String, dynamic> msg) async {
    final type = msg['type'] as String?;
    final data = msg['data'];
    final senderId = msg['senderId'] as String? ?? '';

    switch (type) {
      case 'call-request':
        // Store peer's public key from call request
        if (data is Map && data['publicKey'] != null) {
          state = state.copyWith(peerPublicKey: data['publicKey'] as String);
        }
        state = state.copyWith(incomingCallFrom: senderId);
      case 'call-accepted':
        // Store peer's public key from call acceptance
        if (data is Map && data['publicKey'] != null) {
          state = state.copyWith(peerPublicKey: data['publicKey'] as String);
        }
        await _onCallAccepted();
      case 'offer':
        // Store peer's public key from offer
        if (data is Map && data['publicKey'] != null) {
          state = state.copyWith(peerPublicKey: data['publicKey'] as String);
        }
        await _onOffer(senderId, data);
      case 'answer':
        // Store peer's public key from answer
        if (data is Map && data['publicKey'] != null) {
          state = state.copyWith(peerPublicKey: data['publicKey'] as String);
        }
        await _onAnswer(data);
      case 'candidate':
        await _onCandidate(data);
      case 'call-ended':
        await _endCall();
    }
  }

  // --- Chat (Data Channel) ---

  Future<void> _startChat(String targetId) async {
    if (targetId == _myAccountId) return;
    state = state.copyWith(
      remotePeerId: targetId,
      peerStatus: PeerConnectionStatus.connecting,
    );

    // Load saved history for this peer
    await _loadHistory(targetId);

    _webrtc = WebRTCService(turnCredentials: _signaling?.turnCredentials);
    await _webrtc!.initPeerConnection();
    _listenWebRTC();
    await _webrtc!.createDataChannel('chat');

    final offer = await _webrtc!.createOffer();
    _signaling?.send(targetId, 'offer', {
      'sdp': offer.sdp,
      'type': offer.type,
      'publicKey': _myPublicKeyBase64,
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.isEmpty) return;
    final accountId = _myAccountId;

    // Build the plaintext payload
    final payload = jsonEncode({
      'senderId': accountId,
      'text': text,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Encrypt if we have the peer's public key
    final peerPk = _peerPublicKey;
    String wireData;
    if (peerPk != null) {
      final encrypted = _encryption.encrypt(
        myEd25519PrivateKey: _myPrivateKey,
        theirEd25519PublicKey: peerPk,
        plaintext: payload,
      );
      wireData = jsonEncode({'e': encrypted});
    } else {
      wireData = payload;
    }

    _webrtc?.dataChannel?.send(RTCDataChannelMessage(wireData));

    final msg = ChatMessage(
      senderId: accountId,
      text: text,
      timestamp: DateTime.now(),
      isMe: true,
    );

    state = state.copyWith(messages: [...state.messages, msg]);
    _persistMessages();
  }

  // --- Calls ---

  Future<void> _startCall(String targetId, bool video) async {
    if (targetId == _myAccountId) return;
    state = state.copyWith(
      remotePeerId: targetId,
      peerStatus: PeerConnectionStatus.connecting,
      isVideoEnabled: video,
      isAudioEnabled: true,
    );

    _signaling?.send(targetId, 'call-request', {
      'video': video,
      'publicKey': _myPublicKeyBase64,
    });
  }

  Future<void> _acceptCall() async {
    final callerId = state.incomingCallFrom;
    if (callerId == null) return;

    state = state.copyWith(
      remotePeerId: callerId,
      incomingCallFrom: null,
      peerStatus: PeerConnectionStatus.connecting,
      isAudioEnabled: true,
    );

    _signaling?.send(callerId, 'call-accepted', {
      'publicKey': _myPublicKeyBase64,
    });
  }

  void _rejectCall() {
    final callerId = state.incomingCallFrom;
    if (callerId != null) {
      _signaling?.send(callerId, 'call-ended', {});
    }
    state = state.copyWith(incomingCallFrom: null);
  }

  Future<void> _onCallAccepted() async {
    // Caller creates the offer after acceptance
    _webrtc = WebRTCService(turnCredentials: _signaling?.turnCredentials);
    await _webrtc!.initPeerConnection();
    _listenWebRTC();
    await _webrtc!.createDataChannel('chat');

    await _initRenderers();

    await _webrtc!.startLocalMedia(
      video: state.isVideoEnabled,
      audio: state.isAudioEnabled,
    );

    final offer = await _webrtc!.createOffer();
    _signaling?.send(state.remotePeerId, 'offer', {
      'sdp': offer.sdp,
      'type': offer.type,
      'publicKey': _myPublicKeyBase64,
    });

    state = state.copyWith(peerStatus: PeerConnectionStatus.inCall);
  }

  Future<void> _onOffer(String senderId, dynamic data) async {
    if (_webrtc == null) {
      _webrtc = WebRTCService(turnCredentials: _signaling?.turnCredentials);
      await _webrtc!.initPeerConnection();
      _listenWebRTC();
    }

    await _initRenderers();

    final isCall = state.peerStatus == PeerConnectionStatus.connecting ||
        state.peerStatus == PeerConnectionStatus.inCall;

    if (isCall) {
      await _webrtc!.startLocalMedia(
        video: state.isVideoEnabled,
        audio: state.isAudioEnabled,
      );
    }

    await _webrtc!.setRemoteDescription(
      RTCSessionDescription(data['sdp'] as String?, data['type'] as String?),
    );

    final answer = await _webrtc!.createAnswer();
    _signaling?.send(
        senderId.isNotEmpty ? senderId : state.remotePeerId, 'answer', {
      'sdp': answer.sdp,
      'type': answer.type,
      'publicKey': _myPublicKeyBase64,
    });

    if (state.remotePeerId.isEmpty) {
      state = state.copyWith(remotePeerId: senderId);
    }
    state = state.copyWith(
      peerStatus:
          isCall ? PeerConnectionStatus.inCall : PeerConnectionStatus.connected,
    );
  }

  Future<void> _onAnswer(dynamic data) async {
    await _webrtc?.setRemoteDescription(
      RTCSessionDescription(data['sdp'] as String?, data['type'] as String?),
    );
    if (state.peerStatus == PeerConnectionStatus.connecting) {
      state = state.copyWith(peerStatus: PeerConnectionStatus.connected);
    }
  }

  Future<void> _onCandidate(dynamic data) async {
    if (data is Map) {
      await _webrtc?.addCandidate(
        RTCIceCandidate(
          data['candidate'] as String?,
          data['sdpMid'] as String?,
          data['sdpMLineIndex'] as int?,
        ),
      );
    }
  }

  Future<void> _endCall() async {
    _signaling?.send(state.remotePeerId, 'call-ended', {});

    await localRenderer?.dispose();
    await remoteRenderer?.dispose();
    localRenderer = null;
    remoteRenderer = null;

    await _webrtc?.dispose();
    _webrtc = null;

    state = state.copyWith(
      peerStatus: PeerConnectionStatus.disconnected,
      isVideoEnabled: false,
      isAudioEnabled: false,
      isScreenSharing: false,
      incomingCallFrom: null,
    );
  }

  // --- Media Controls ---

  void _toggleVideo() {
    final enabled = !state.isVideoEnabled;
    _webrtc?.toggleVideo(enabled);
    state = state.copyWith(isVideoEnabled: enabled);
  }

  void _toggleAudio() {
    final enabled = !state.isAudioEnabled;
    _webrtc?.toggleAudio(enabled);
    state = state.copyWith(isAudioEnabled: enabled);
  }

  Future<void> _startScreenShare() async {
    await _webrtc?.startScreenShare();
    state = state.copyWith(isScreenSharing: true);
  }

  Future<void> _stopScreenShare() async {
    await _webrtc?.stopScreenShare();
    state = state.copyWith(isScreenSharing: false);
  }

  // --- Storage ---

  Future<void> _loadHistory(String peerId) async {
    try {
      final messages = await _storage.loadMessages(_myAccountId, peerId);
      if (messages.isNotEmpty) {
        state = state.copyWith(messages: messages);
      }
    } catch (_) {}
  }

  Future<void> _clearHistory() async {
    if (state.remotePeerId.isEmpty) return;
    try {
      await _storage.deleteHistory(_myAccountId, state.remotePeerId);
    } catch (_) {}
    state = state.copyWith(messages: []);
  }

  Future<void> _persistMessages() async {
    if (state.remotePeerId.isEmpty) return;
    try {
      await _storage.saveMessages(
        _myAccountId,
        state.remotePeerId,
        state.messages,
      );
    } catch (_) {}
  }

  // --- Helpers ---

  Future<void> _initRenderers() async {
    localRenderer ??= RTCVideoRenderer();
    remoteRenderer ??= RTCVideoRenderer();
    await localRenderer!.initialize();
    await remoteRenderer!.initialize();
  }

  void _listenWebRTC() {
    if (_webrtc == null) return;

    _subscriptions.add(
      _webrtc!.onIceCandidate.listen((candidate) {
        _signaling?.send(state.remotePeerId, 'candidate', {
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
        });
      }),
    );

    _subscriptions.add(
      _webrtc!.onDataChannelMessage.listen((message) {
        try {
          final data = jsonDecode(message) as Map<String, dynamic>;

          // Check if the message is encrypted
          if (data.containsKey('e')) {
            final peerPk = _peerPublicKey;
            if (peerPk == null) return;
            final decryptedJson = _encryption.decrypt(
              myEd25519PrivateKey: _myPrivateKey,
              theirEd25519PublicKey: peerPk,
              base64Ciphertext: data['e'] as String,
            );
            final payload = jsonDecode(decryptedJson) as Map<String, dynamic>;
            _addReceivedMessage(payload);
          } else {
            // Plaintext fallback (legacy / no key exchange)
            _addReceivedMessage(data);
          }
        } catch (_) {}
      }),
    );

    _subscriptions.add(
      _webrtc!.onRemoteStream.listen((stream) {
        remoteRenderer?.srcObject = stream;
      }),
    );

    _subscriptions.add(
      _webrtc!.onDataChannelOpen.listen((_) {
        if (state.peerStatus == PeerConnectionStatus.connecting) {
          state = state.copyWith(peerStatus: PeerConnectionStatus.connected);
        }
      }),
    );
  }

  void _addReceivedMessage(Map<String, dynamic> data) {
    final msg = ChatMessage(
      senderId: data['senderId'] as String? ?? '',
      text: data['text'] as String? ?? '',
      timestamp:
          DateTime.tryParse(data['timestamp'] as String? ?? '') ?? DateTime.now(),
    );

    state = state.copyWith(messages: [...state.messages, msg]);
    _persistMessages();
  }
}
