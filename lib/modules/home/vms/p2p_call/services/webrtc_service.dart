import 'dart:async';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:rxdart/rxdart.dart';

import '../models/p2p_connection_stats.dart';

class WebRTCService {
  static const String _tag = '🔌 WebRTCService';

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _screenStream;
  RTCDataChannel? _dataChannel;
  Timer? _statsTimer;

  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  final PublishSubject<RTCIceCandidate> onIceCandidate = PublishSubject();
  final PublishSubject<RTCSessionDescription> onLocalDescription =
      PublishSubject();
  final PublishSubject<String> onDataChannelMessage = PublishSubject();
  final PublishSubject<String> onConnectionStateChange = PublishSubject();
  final PublishSubject<P2PConnectionStats> onStats = PublishSubject();
  final PublishSubject<bool> onDataChannelOpen = PublishSubject();

  final List<RTCIceCandidate> _candidateQueue = [];

  String stunUrl = 'stun:stun.l.google.com:19302';
  String turnUrl = 'turn:p2ptest1.duckdns.org:3478';
  String turnUser = 'myuser';
  String turnPass = 'mypassword';

  Map<String, dynamic> get _iceConfig => {
        'iceServers': [
          {'urls': stunUrl},
          {
            'urls': turnUrl,
            'username': turnUser,
            'credential': turnPass,
          },
        ]
      };

  Future<void> initialize() async {
    print('$_tag: initialize() — initializing renderers');
    await localRenderer.initialize();
    await remoteRenderer.initialize();
    print('$_tag: initialize() — renderers ready');
  }

  Future<void> startCall({required bool isInitiator}) async {
    print('$_tag: ══════════════════════════════════════');
    print('$_tag: startCall(isInitiator: $isInitiator)');
    print('$_tag: ══════════════════════════════════════');

    // --- Get user media ---
    print('$_tag: Requesting getUserMedia (audio: true, video: user)...');
    try {
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {
          'facingMode': 'user',
        },
      });
      print('$_tag: getUserMedia SUCCESS');
      print('$_tag:   stream id: ${_localStream!.id}');
      print('$_tag:   audio tracks: ${_localStream!.getAudioTracks().length}');
      print('$_tag:   video tracks: ${_localStream!.getVideoTracks().length}');
      for (final t in _localStream!.getAudioTracks()) {
        print('$_tag:   audio track: id=${t.id}, enabled=${t.enabled}, muted=${t.muted}');
      }
      for (final t in _localStream!.getVideoTracks()) {
        print('$_tag:   video track: id=${t.id}, enabled=${t.enabled}, muted=${t.muted}, settings=${t.getSettings()}');
      }
    } catch (e, st) {
      print('$_tag: ✗ getUserMedia FAILED: $e');
      print('$_tag: ✗ $st');
      rethrow;
    }

    localRenderer.srcObject = _localStream;
    print('$_tag: Local renderer srcObject set');

    // --- Create peer connection ---
    print('$_tag: Creating peer connection with ICE config:');
    print('$_tag:   STUN: $stunUrl');
    print('$_tag:   TURN: $turnUrl (user: $turnUser)');
    try {
      _peerConnection = await createPeerConnection(_iceConfig);
      print('$_tag: PeerConnection created successfully');
    } catch (e, st) {
      print('$_tag: ✗ createPeerConnection FAILED: $e');
      print('$_tag: ✗ $st');
      rethrow;
    }

    // --- Add local tracks ---
    print('$_tag: Adding local tracks to peer connection...');
    for (final track in _localStream!.getTracks()) {
      print('$_tag:   Adding track: kind=${track.kind}, id=${track.id}');
      await _peerConnection!.addTrack(track, _localStream!);
    }
    print('$_tag: All local tracks added');

    // --- Data channel ---
    if (isInitiator) {
      print('$_tag: Creating data channel "chat" (initiator)...');
      _dataChannel = await _peerConnection!.createDataChannel(
        'chat',
        RTCDataChannelInit(),
      );
      _setupDataChannel(_dataChannel!);
      print('$_tag: Data channel created and configured');
    } else {
      print('$_tag: Waiting for remote data channel (non-initiator)...');
      _peerConnection!.onDataChannel = (channel) {
        print('$_tag: ← Remote data channel received: label=${channel.label}, id=${channel.id}');
        _dataChannel = channel;
        _setupDataChannel(channel);
      };
    }

    // --- onTrack ---
    _peerConnection!.onTrack = (event) {
      print('$_tag: ← onTrack event:');
      print('$_tag:   track kind=${event.track.kind}, id=${event.track.id}');
      print('$_tag:   streams count=${event.streams.length}');
      if (event.streams.isNotEmpty) {
        print('$_tag:   Setting remote renderer srcObject (stream id: ${event.streams[0].id})');
        remoteRenderer.srcObject = event.streams[0];
      } else {
        print('$_tag:   ⚠ No streams in onTrack event!');
      }
    };

    // --- ICE Candidate ---
    _peerConnection!.onIceCandidate = (candidate) {
      print('$_tag: ← onIceCandidate:');
      print('$_tag:   candidate: ${candidate.candidate}');
      print('$_tag:   sdpMid: ${candidate.sdpMid}');
      print('$_tag:   sdpMLineIndex: ${candidate.sdpMLineIndex}');
      onIceCandidate.add(candidate);
    };

    // --- ICE Gathering State ---
    _peerConnection!.onIceGatheringState = (state) {
      print('$_tag: ← ICE Gathering State: ${state.name}');
    };

    // --- ICE Connection State ---
    _peerConnection!.onIceConnectionState = (state) {
      print('$_tag: ← ICE Connection State: ${state.name}');
    };

    // --- Signaling State ---
    _peerConnection!.onSignalingState = (state) {
      print('$_tag: ← Signaling State: ${state.name}');
    };

    // --- Connection State ---
    _peerConnection!.onConnectionState = (state) {
      final stateName = state.name;
      print('$_tag: ← PeerConnection State: $stateName');
      onConnectionStateChange.add(stateName);
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        print('$_tag: ✓ CONNECTED — starting stats collection');
        _startStats();
      } else if (state ==
              RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state ==
              RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        print('$_tag: ✗ Connection $stateName — stopping stats');
        _statsTimer?.cancel();
      }
    };

    // --- Renegotiation needed ---
    _peerConnection!.onRenegotiationNeeded = () {
      print('$_tag: ← onRenegotiationNeeded triggered');
    };

    // --- Create offer if initiator ---
    if (isInitiator) {
      print('$_tag: Creating offer (initiator)...');
      try {
        final offer = await _peerConnection!.createOffer();
        print('$_tag: Offer created:');
        print('$_tag:   type: ${offer.type}');
        print('$_tag:   sdp (first 200 chars): ${offer.sdp?.substring(0, offer.sdp!.length > 200 ? 200 : offer.sdp!.length)}');

        print('$_tag: Setting local description (offer)...');
        await _peerConnection!.setLocalDescription(offer);
        print('$_tag: Local description set');

        print('$_tag: Signaling state after setLocalDescription: ${_peerConnection!.signalingState}');

        onLocalDescription.add(offer);
        print('$_tag: Offer emitted via onLocalDescription');
      } catch (e, st) {
        print('$_tag: ✗ createOffer/setLocalDescription FAILED: $e');
        print('$_tag: ✗ $st');
        rethrow;
      }
    } else {
      print('$_tag: Non-initiator — waiting for remote offer');
    }

    print('$_tag: startCall() completed');
  }

  Future<void> handleOffer(RTCSessionDescription offer) async {
    print('$_tag: ──────────────────────────────────────');
    print('$_tag: handleOffer()');
    print('$_tag:   type: ${offer.type}');
    print('$_tag:   sdp (first 200 chars): ${offer.sdp?.substring(0, (offer.sdp?.length ?? 0) > 200 ? 200 : offer.sdp?.length ?? 0)}');

    if (_peerConnection == null) {
      print('$_tag: ✗ handleOffer SKIPPED — peerConnection is null!');
      return;
    }

    print('$_tag: Current signaling state: ${_peerConnection!.signalingState}');

    print('$_tag: Setting remote description (offer)...');
    try {
      await _peerConnection!.setRemoteDescription(offer);
      print('$_tag: Remote description set successfully');
      print('$_tag: Signaling state after setRemoteDescription: ${_peerConnection!.signalingState}');
    } catch (e, st) {
      print('$_tag: ✗ setRemoteDescription FAILED: $e');
      print('$_tag: ✗ $st');
      rethrow;
    }

    print('$_tag: Processing queued candidates (${_candidateQueue.length} in queue)...');
    await _processQueue();

    print('$_tag: Creating answer...');
    try {
      final answer = await _peerConnection!.createAnswer();
      print('$_tag: Answer created:');
      print('$_tag:   type: ${answer.type}');
      print('$_tag:   sdp (first 200 chars): ${answer.sdp?.substring(0, (answer.sdp?.length ?? 0) > 200 ? 200 : answer.sdp?.length ?? 0)}');

      print('$_tag: Setting local description (answer)...');
      await _peerConnection!.setLocalDescription(answer);
      print('$_tag: Local description set');
      print('$_tag: Signaling state after setLocalDescription: ${_peerConnection!.signalingState}');

      onLocalDescription.add(answer);
      print('$_tag: Answer emitted via onLocalDescription');
    } catch (e, st) {
      print('$_tag: ✗ createAnswer/setLocalDescription FAILED: $e');
      print('$_tag: ✗ $st');
      rethrow;
    }
  }

  Future<void> handleAnswer(RTCSessionDescription answer) async {
    print('$_tag: ──────────────────────────────────────');
    print('$_tag: handleAnswer()');
    print('$_tag:   type: ${answer.type}');
    print('$_tag:   sdp (first 200 chars): ${answer.sdp?.substring(0, (answer.sdp?.length ?? 0) > 200 ? 200 : answer.sdp?.length ?? 0)}');

    if (_peerConnection == null) {
      print('$_tag: ✗ handleAnswer SKIPPED — peerConnection is null!');
      return;
    }

    print('$_tag: Current signaling state: ${_peerConnection!.signalingState}');

    print('$_tag: Setting remote description (answer)...');
    try {
      await _peerConnection!.setRemoteDescription(answer);
      print('$_tag: Remote description set successfully');
      print('$_tag: Signaling state after setRemoteDescription: ${_peerConnection!.signalingState}');
    } catch (e, st) {
      print('$_tag: ✗ setRemoteDescription FAILED: $e');
      print('$_tag: ✗ $st');
      rethrow;
    }

    print('$_tag: Processing queued candidates (${_candidateQueue.length} in queue)...');
    await _processQueue();
  }

  Future<void> addIceCandidate(RTCIceCandidate candidate) async {
    print('$_tag: addIceCandidate()');
    print('$_tag:   candidate: ${candidate.candidate}');
    print('$_tag:   sdpMid: ${candidate.sdpMid}');
    print('$_tag:   sdpMLineIndex: ${candidate.sdpMLineIndex}');

    if (_peerConnection != null &&
        await _peerConnection!.getRemoteDescription() != null) {
      print('$_tag:   Remote description exists — adding candidate directly');
      try {
        await _peerConnection!.addCandidate(candidate);
        print('$_tag:   Candidate added successfully');
      } catch (e, st) {
        print('$_tag: ✗ addCandidate FAILED: $e');
        print('$_tag: ✗ $st');
      }
    } else {
      _candidateQueue.add(candidate);
      print('$_tag:   ⚠ Remote description NOT set yet — queued (queue size: ${_candidateQueue.length})');
    }
  }

  Future<void> _processQueue() async {
    print('$_tag: _processQueue() — processing ${_candidateQueue.length} queued candidates');
    for (final c in _candidateQueue) {
      try {
        await _peerConnection?.addCandidate(c);
        print('$_tag:   Queued candidate added: ${c.candidate?.substring(0, c.candidate!.length > 80 ? 80 : c.candidate!.length)}...');
      } catch (e) {
        print('$_tag: ✗ Failed to add queued candidate: $e');
      }
    }
    _candidateQueue.clear();
    print('$_tag: _processQueue() — queue cleared');
  }

  void toggleAudio(bool enabled) {
    print('$_tag: toggleAudio($enabled)');
    _localStream?.getAudioTracks().forEach((t) {
      t.enabled = enabled;
      print('$_tag:   Audio track ${t.id}: enabled=$enabled');
    });
  }

  void toggleVideo(bool enabled) {
    print('$_tag: toggleVideo($enabled)');
    _localStream?.getVideoTracks().forEach((t) {
      t.enabled = enabled;
      print('$_tag:   Video track ${t.id}: enabled=$enabled');
    });
  }

  Future<bool> toggleScreenShare() async {
    print('$_tag: toggleScreenShare() — current screenStream: ${_screenStream != null ? "active" : "null"}');
    if (_peerConnection == null) {
      print('$_tag: ✗ toggleScreenShare — peerConnection is null');
      return false;
    }

    final senders = await _peerConnection!.getSenders();
    print('$_tag:   Senders count: ${senders.length}');
    final videoSender = senders.cast<RTCRtpSender?>().firstWhere(
          (s) => s?.track?.kind == 'video',
          orElse: () => null,
        );
    if (videoSender == null) {
      print('$_tag: ✗ No video sender found');
      return false;
    }

    if (_screenStream == null) {
      print('$_tag: Starting screen share...');
      _screenStream =
          await navigator.mediaDevices.getDisplayMedia({'video': true});
      final screenTrack = _screenStream!.getVideoTracks()[0];
      await videoSender.replaceTrack(screenTrack);
      localRenderer.srcObject = _screenStream;
      print('$_tag: Screen share started, track replaced');

      screenTrack.onEnded = () async {
        print('$_tag: Screen share track ended (user stopped sharing)');
        final camTrack = _localStream?.getVideoTracks().firstOrNull;
        if (camTrack != null) {
          await videoSender.replaceTrack(camTrack);
          localRenderer.srcObject = _localStream;
          print('$_tag: Reverted to camera track');
        }
        _screenStream?.getTracks().forEach((t) => t.stop());
        _screenStream = null;
      };
      return true;
    } else {
      print('$_tag: Stopping screen share...');
      final camTrack = _localStream?.getVideoTracks().firstOrNull;
      if (camTrack != null) {
        await videoSender.replaceTrack(camTrack);
      }
      localRenderer.srcObject = _localStream;
      _screenStream!.getTracks().forEach((t) => t.stop());
      _screenStream = null;
      print('$_tag: Screen share stopped');
      return false;
    }
  }

  void sendChatMessage(String text) {
    print('$_tag: sendChatMessage() — dataChannel state: ${_dataChannel?.state}');
    if (_dataChannel?.state == RTCDataChannelState.RTCDataChannelOpen) {
      _dataChannel!.send(RTCDataChannelMessage(text));
      print('$_tag: Chat message sent: "${text.length > 50 ? text.substring(0, 50) : text}..."');
    } else {
      print('$_tag: ✗ sendChatMessage SKIPPED — data channel not open (state: ${_dataChannel?.state})');
    }
  }

  bool get isDataChannelOpen =>
      _dataChannel?.state == RTCDataChannelState.RTCDataChannelOpen;

  void _setupDataChannel(RTCDataChannel dc) {
    print('$_tag: _setupDataChannel() — label=${dc.label}, id=${dc.id}, state=${dc.state}');
    dc.onMessage = (msg) {
      print('$_tag: ← DataChannel message: "${msg.text.length > 80 ? msg.text.substring(0, 80) : msg.text}"');
      onDataChannelMessage.add(msg.text);
    };
    dc.onDataChannelState = (state) {
      print('$_tag: ← DataChannel state changed: $state');
      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        print('$_tag: ✓ DataChannel is OPEN');
        onDataChannelOpen.add(true);
      }
    };
  }

  void _startStats() {
    _statsTimer?.cancel();
    _statsTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (_peerConnection == null) return;
      try {
        final stats = await _peerConnection!.getStats();
        StatsReport? activePair;
        int packetsLost = 0;

        for (final report in stats) {
          if (report.type == 'candidate-pair' &&
              report.values['state'] == 'succeeded') {
            activePair = report;
          }
          if (report.type == 'inbound-rtp' &&
              report.values['kind'] == 'video') {
            packetsLost =
                (report.values['packetsLost'] as num?)?.toInt() ?? 0;
          }
        }

        if (activePair != null) {
          final localCandidateId =
              activePair.values['localCandidateId'] as String?;
          final remoteCandidateId =
              activePair.values['remoteCandidateId'] as String?;

          StatsReport? localCandidate;
          StatsReport? remoteCandidate;
          for (final report in stats) {
            if (report.id == localCandidateId) localCandidate = report;
            if (report.id == remoteCandidateId) remoteCandidate = report;
          }

          onStats.add(P2PConnectionStats(
            connectionType:
                (localCandidate?.values['candidateType'] as String?) ??
                    'unknown',
            protocol:
                (localCandidate?.values['protocol'] as String?) ?? 'unknown',
            localAddress:
                '${localCandidate?.values['ip'] ?? localCandidate?.values['address'] ?? '?'}:${localCandidate?.values['port'] ?? '?'}',
            remoteAddress:
                '${remoteCandidate?.values['ip'] ?? remoteCandidate?.values['address'] ?? '?'}:${remoteCandidate?.values['port'] ?? '?'}',
            packetsLost: packetsLost,
            connectionState:
                (activePair.values['state'] as String?) ?? 'unknown',
          ));
        }
      } catch (e) {
        print('$_tag: stats error: $e');
      }
    });
  }

  Future<void> hangUp() async {
    print('$_tag: hangUp() called');
    _statsTimer?.cancel();
    _statsTimer = null;
    _dataChannel?.close();
    _dataChannel = null;
    await _peerConnection?.close();
    _peerConnection = null;
    _localStream?.getTracks().forEach((t) => t.stop());
    _localStream = null;
    _screenStream?.getTracks().forEach((t) => t.stop());
    _screenStream = null;
    localRenderer.srcObject = null;
    remoteRenderer.srcObject = null;
    _candidateQueue.clear();
    print('$_tag: hangUp() — all resources cleaned up');
  }

  Future<void> dispose() async {
    print('$_tag: dispose() called');
    await hangUp();
    await localRenderer.dispose();
    await remoteRenderer.dispose();
    onIceCandidate.close();
    onLocalDescription.close();
    onDataChannelMessage.close();
    onConnectionStateChange.close();
    onStats.close();
    onDataChannelOpen.close();
    print('$_tag: dispose() — complete');
  }
}
