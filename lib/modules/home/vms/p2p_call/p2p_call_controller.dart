import 'dart:async';

import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:rxdart/rxdart.dart';

import 'package:near_social_mobile/modules/vms/core/auth_controller.dart';
import 'models/p2p_call_state.dart';
import 'models/p2p_chat_message.dart';
import 'services/signaling_service.dart';
import 'services/webrtc_service.dart';

class P2PCallController extends Disposable {
  static const String _tag = '📞 P2PCallController';

  final AuthController _authController;

  P2PCallController(this._authController);

  final BehaviorSubject<P2PCallState> _streamController =
      BehaviorSubject.seeded(const P2PCallState());

  Stream<P2PCallState> get stream => _streamController.stream.distinct();
  P2PCallState get state => _streamController.value;

  final SignalingService _signalingService = SignalingService();
  final WebRTCService _webrtcService = WebRTCService();

  final List<StreamSubscription> _subscriptions = [];
  bool _initialized = false;

  RTCVideoRenderer get localRenderer => _webrtcService.localRenderer;
  RTCVideoRenderer get remoteRenderer => _webrtcService.remoteRenderer;

  void _updateState(P2PCallState newState) {
    final oldStatus = state.status;
    final newStatus = newState.status;
    if (oldStatus != newStatus) {
      print('$_tag: ═══ STATE CHANGE: $oldStatus → $newStatus ═══');
    }
    _streamController.add(newState);
  }

  Future<void> connectSignaling({String? wsUrl}) async {
    print('$_tag: ──────────────────────────────────────');
    print('$_tag: connectSignaling() called');
    print('$_tag:   wsUrl: $wsUrl');
    print('$_tag:   isConnected: ${_signalingService.isConnected}');
    print('$_tag:   _initialized: $_initialized');
    print('$_tag: ──────────────────────────────────────');

    if (_signalingService.isConnected) {
      print('$_tag: Already connected — skipping');
      return;
    }

    final userId = _authController.state.accountId;
    if (userId.isEmpty) {
      print('$_tag: ✗ No accountId available — aborting');
      return;
    }
    print('$_tag: userId = $userId');

    if (!_initialized) {
      print('$_tag: First time — initializing WebRTC service...');
      await _webrtcService.initialize();
      _initialized = true;
      print('$_tag: WebRTC service initialized');
    }

    _updateState(state.copyWith(
      status: P2PCallStatus.connecting,
      localUserId: userId,
    ));

    try {
      print('$_tag: Connecting to signaling server...');
      await _signalingService.connect(userId: userId, wsUrl: wsUrl);
      print('$_tag: Signaling connected successfully');
    } catch (e, st) {
      print('$_tag: ✗ Signaling connection FAILED: $e');
      print('$_tag: ✗ $st');
      _updateState(state.copyWith(
        status: P2PCallStatus.failed,
        errorMessage: 'Failed to connect to signaling server: $e',
      ));
      return;
    }

    _updateState(state.copyWith(
      status: P2PCallStatus.registered,
      localUserId: userId,
    ));

    print('$_tag: Setting up subscriptions...');

    // --- Signaling messages ---
    _subscriptions.add(
      _signalingService.messageStream.listen(
        (msg) {
          print('$_tag: ← Signaling message received: type=${msg.type}, from=${msg.from}');
          _handleSignalingMessage(msg);
        },
        onError: (e) => print('$_tag: ✗ Signaling message stream error: $e'),
      ),
    );

    // --- ICE candidates → signaling ---
    _subscriptions.add(
      _webrtcService.onIceCandidate.listen(
        (candidate) {
          print('$_tag: → Forwarding ICE candidate to ${state.remoteUserId}');
          print('$_tag:   candidate: ${candidate.candidate}');
          _signalingService.send(
            state.remoteUserId,
            'candidate',
            candidate.toMap() as Map<String, dynamic>,
          );
        },
        onError: (e) => print('$_tag: ✗ ICE candidate stream error: $e'),
      ),
    );

    // --- Local description → signaling ---
    _subscriptions.add(
      _webrtcService.onLocalDescription.listen(
        (desc) {
          print('$_tag: → Forwarding local description to ${state.remoteUserId}');
          print('$_tag:   type: ${desc.type}');
          _signalingService.send(
            state.remoteUserId,
            desc.type!,
            {'type': desc.type, 'sdp': desc.sdp},
          );
        },
        onError: (e) => print('$_tag: ✗ Local description stream error: $e'),
      ),
    );

    // --- Data channel messages ---
    _subscriptions.add(
      _webrtcService.onDataChannelMessage.listen(
        (text) {
          print('$_tag: ← DataChannel message received: "${text.length > 50 ? text.substring(0, 50) : text}"');
          final msgs = List<P2PChatMessage>.from(state.chatMessages)
            ..add(P2PChatMessage(
              text: text,
              isMe: false,
              timestamp: DateTime.now(),
            ));
          _updateState(state.copyWith(chatMessages: msgs));
        },
        onError: (e) => print('$_tag: ✗ DataChannel message stream error: $e'),
      ),
    );

    // --- WebRTC connection state ---
    _subscriptions.add(
      _webrtcService.onConnectionStateChange.listen(
        (s) {
          print('$_tag: ← WebRTC connection state change: "$s"');
          P2PCallStatus? newStatus;
          if (s.contains('connected')) {
            newStatus = P2PCallStatus.connected;
          } else if (s.contains('failed')) {
            newStatus = P2PCallStatus.failed;
          } else if (s.contains('disconnected')) {
            newStatus = P2PCallStatus.disconnected;
          }
          if (newStatus != null) {
            print('$_tag:   → Mapping to P2PCallStatus: $newStatus');
            _updateState(state.copyWith(status: newStatus));
          } else {
            print('$_tag:   → No status mapping for "$s"');
          }
        },
        onError: (e) => print('$_tag: ✗ Connection state stream error: $e'),
      ),
    );

    // --- Stats ---
    _subscriptions.add(
      _webrtcService.onStats.listen(
        (stats) {
          _updateState(state.copyWith(connectionStats: stats));
        },
        onError: (e) => print('$_tag: ✗ Stats stream error: $e'),
      ),
    );

    // --- Signaling connection status ---
    _subscriptions.add(
      _signalingService.connectionStream.listen(
        (connected) {
          print('$_tag: ← Signaling connection status: $connected');
          if (!connected && state.status != P2PCallStatus.idle) {
            print('$_tag: ⚠ Signaling disconnected while not idle — updating state');
            _updateState(state.copyWith(
              status: P2PCallStatus.disconnected,
              errorMessage: 'Signaling server disconnected',
            ));
          }
        },
        onError: (e) => print('$_tag: ✗ Signaling connection stream error: $e'),
      ),
    );

    print('$_tag: All subscriptions set up (${_subscriptions.length} total)');
    print('$_tag: connectSignaling() completed — status: ${state.status}');
  }

  Future<void> requestCall(String targetAccountId) async {
    print('$_tag: ══════════════════════════════════════');
    print('$_tag: requestCall(targetAccountId: $targetAccountId)');
    print('$_tag:   isConnected: ${_signalingService.isConnected}');
    print('$_tag:   current status: ${state.status}');
    print('$_tag: ══════════════════════════════════════');

    if (!_signalingService.isConnected) {
      print('$_tag: Not connected — calling connectSignaling() first');
      await connectSignaling();
    }

    print('$_tag: Sending call-request to $targetAccountId');
    _signalingService.send(targetAccountId, 'call-request', {'mode': 'video'});
    _updateState(state.copyWith(
      status: P2PCallStatus.calling,
      remoteUserId: targetAccountId,
      isInitiator: true,
    ));
    print('$_tag: requestCall() — waiting for call-accepted from $targetAccountId');
  }

  Future<void> acceptCall() async {
    print('$_tag: ══════════════════════════════════════');
    print('$_tag: acceptCall()');
    print('$_tag:   remoteUserId: ${state.remoteUserId}');
    print('$_tag:   current status: ${state.status}');
    print('$_tag: ══════════════════════════════════════');

    print('$_tag: Sending call-accepted to ${state.remoteUserId}');
    _signalingService.send(state.remoteUserId, 'call-accepted', {});
    _updateState(state.copyWith(status: P2PCallStatus.negotiating));

    print('$_tag: Starting WebRTC call as NON-initiator (will wait for offer)');
    await _webrtcService.startCall(isInitiator: false);
    print('$_tag: acceptCall() — WebRTC startCall completed, waiting for offer');
  }

  void rejectCall() {
    print('$_tag: rejectCall() — rejecting call from ${state.remoteUserId}');
    _updateState(state.copyWith(
      status: P2PCallStatus.registered,
      remoteUserId: '',
    ));
  }

  void _handleSignalingMessage(SignalingMessage msg) async {
    print('$_tag: ┌─────────────────────────────────────');
    print('$_tag: │ _handleSignalingMessage');
    print('$_tag: │   type: ${msg.type}');
    print('$_tag: │   from: ${msg.from}');
    print('$_tag: │   data keys: ${msg.data.keys.toList()}');
    print('$_tag: │   current status: ${state.status}');
    print('$_tag: │   current remoteUserId: ${state.remoteUserId}');
    print('$_tag: │   isInitiator: ${state.isInitiator}');
    print('$_tag: └─────────────────────────────────────');

    try {
      switch (msg.type) {
        case 'call-request':
          print('$_tag: [call-request] Incoming call from ${msg.from}');
          _updateState(state.copyWith(
            status: P2PCallStatus.incomingCall,
            remoteUserId: msg.from,
          ));
          break;

        case 'call-accepted':
          print('$_tag: [call-accepted] Call accepted by ${msg.from}');
          _updateState(state.copyWith(
            status: P2PCallStatus.negotiating,
            remoteUserId: msg.from,
          ));
          print('$_tag: [call-accepted] Starting WebRTC as INITIATOR...');
          await _webrtcService.startCall(isInitiator: true);
          print('$_tag: [call-accepted] WebRTC startCall completed — offer should have been sent');
          break;

        case 'offer':
          print('$_tag: [offer] Received SDP offer from ${msg.from}');
          print('$_tag: [offer] sdp type: ${msg.data['type']}');
          print('$_tag: [offer] sdp length: ${(msg.data['sdp'] as String?)?.length ?? 0}');
          await _webrtcService.handleOffer(
            RTCSessionDescription(
              msg.data['sdp'] as String?,
              msg.data['type'] as String?,
            ),
          );
          print('$_tag: [offer] handleOffer completed — answer should have been sent');
          break;

        case 'answer':
          print('$_tag: [answer] Received SDP answer from ${msg.from}');
          print('$_tag: [answer] sdp type: ${msg.data['type']}');
          print('$_tag: [answer] sdp length: ${(msg.data['sdp'] as String?)?.length ?? 0}');
          await _webrtcService.handleAnswer(
            RTCSessionDescription(
              msg.data['sdp'] as String?,
              msg.data['type'] as String?,
            ),
          );
          print('$_tag: [answer] handleAnswer completed — ICE negotiation should proceed');
          break;

        case 'candidate':
          print('$_tag: [candidate] Received ICE candidate from ${msg.from}');
          print('$_tag: [candidate] candidate: ${msg.data['candidate']}');
          print('$_tag: [candidate] sdpMid: ${msg.data['sdpMid']}');
          print('$_tag: [candidate] sdpMLineIndex: ${msg.data['sdpMLineIndex']}');
          await _webrtcService.addIceCandidate(
            RTCIceCandidate(
              msg.data['candidate'] as String?,
              msg.data['sdpMid'] as String?,
              msg.data['sdpMLineIndex'] as int?,
            ),
          );
          print('$_tag: [candidate] ICE candidate processed');
          break;

        default:
          print('$_tag: ⚠ Unknown message type: ${msg.type}');
      }
    } catch (e, st) {
      print('$_tag: ✗ _handleSignalingMessage ERROR for type=${msg.type}: $e');
      print('$_tag: ✗ Stack trace: $st');
    }
  }

  void toggleAudio() {
    final newVal = !state.audioEnabled;
    print('$_tag: toggleAudio() → $newVal');
    _webrtcService.toggleAudio(newVal);
    _updateState(state.copyWith(audioEnabled: newVal));
  }

  void toggleVideo() {
    final newVal = !state.videoEnabled;
    print('$_tag: toggleVideo() → $newVal');
    _webrtcService.toggleVideo(newVal);
    _updateState(state.copyWith(videoEnabled: newVal));
  }

  Future<void> toggleScreenShare() async {
    print('$_tag: toggleScreenShare()');
    try {
      final sharing = await _webrtcService.toggleScreenShare();
      print('$_tag: toggleScreenShare result: $sharing');
      _updateState(state.copyWith(isScreenSharing: sharing));
    } catch (e, st) {
      print('$_tag: ✗ toggleScreenShare error: $e');
      print('$_tag: ✗ $st');
    }
  }

  void sendChatMessage(String text) {
    if (text.isEmpty) return;
    print('$_tag: sendChatMessage() — text="${text.length > 50 ? text.substring(0, 50) : text}"');
    _webrtcService.sendChatMessage(text);
    final msgs = List<P2PChatMessage>.from(state.chatMessages)
      ..add(P2PChatMessage(
        text: text,
        isMe: true,
        timestamp: DateTime.now(),
      ));
    _updateState(state.copyWith(chatMessages: msgs));
  }

  Future<void> hangUp() async {
    print('$_tag: hangUp() called — current status: ${state.status}');
    await _webrtcService.hangUp();
    _updateState(P2PCallState(
      status: _signalingService.isConnected
          ? P2PCallStatus.registered
          : P2PCallStatus.idle,
      localUserId: state.localUserId,
    ));
    print('$_tag: hangUp() completed — new status: ${state.status}');
  }

  Future<void> disconnectAll() async {
    print('$_tag: disconnectAll() called');
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions.clear();
    await _webrtcService.hangUp();
    _signalingService.disconnect();
    _updateState(const P2PCallState());
    print('$_tag: disconnectAll() — fully disconnected, state reset');
  }

  @override
  void dispose() {
    print('$_tag: dispose() called');
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    _signalingService.dispose();
    _webrtcService.dispose();
    _streamController.close();
    print('$_tag: dispose() — complete');
  }
}
