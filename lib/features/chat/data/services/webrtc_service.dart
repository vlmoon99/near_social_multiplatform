import 'dart:async';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:near_social_mobile/features/chat/data/services/signaling_service.dart';

class WebRTCService {
  final TurnCredentials? _turnCredentials;

  WebRTCService({TurnCredentials? turnCredentials})
      : _turnCredentials = turnCredentials;

  Map<String, dynamic> get _iceConfig {
    final iceServers = <Map<String, dynamic>>[
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      {'urls': 'stun:stun2.l.google.com:19302'},
      {'urls': 'stun:global.stun.twilio.com:3478'},
    ];

    if (_turnCredentials != null) {
      iceServers.add({
        'urls': 'turn:${_turnCredentials.host}:3478?transport=tcp',
        'username': _turnCredentials.username,
        'credential': _turnCredentials.password,
      });
    }

    return {'iceServers': iceServers};
  }

  RTCPeerConnection? peerConnection;
  RTCDataChannel? dataChannel;
  MediaStream? localStream;
  MediaStream? remoteStream;
  MediaStream? screenStream;
  bool _hasRemoteDescription = false;
  final List<RTCIceCandidate> _pendingCandidates = [];

  final _onIceCandidate = StreamController<RTCIceCandidate>.broadcast();
  final _onDataChannelMessage = StreamController<String>.broadcast();
  final _onDataChannelOpen = StreamController<void>.broadcast();
  final _onRemoteStream = StreamController<MediaStream>.broadcast();
  final _onConnectionState = StreamController<RTCPeerConnectionState>.broadcast();

  Stream<RTCIceCandidate> get onIceCandidate => _onIceCandidate.stream;
  Stream<String> get onDataChannelMessage => _onDataChannelMessage.stream;
  Stream<void> get onDataChannelOpen => _onDataChannelOpen.stream;
  Stream<MediaStream> get onRemoteStream => _onRemoteStream.stream;
  Stream<RTCPeerConnectionState> get onConnectionState => _onConnectionState.stream;

  Future<void> initPeerConnection() async {
    peerConnection = await createPeerConnection(_iceConfig);

    peerConnection!.onIceCandidate = (candidate) {
      _onIceCandidate.add(candidate);
    };

    peerConnection!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        remoteStream = event.streams[0];
        _onRemoteStream.add(remoteStream!);
      }
    };

    peerConnection!.onDataChannel = (channel) {
      _setupDataChannel(channel);
    };

    peerConnection!.onConnectionState = (state) {
      _onConnectionState.add(state);
    };
  }

  Future<void> createDataChannel(String label) async {
    if (peerConnection == null) return;
    final channel = await peerConnection!.createDataChannel(
      label,
      RTCDataChannelInit()..ordered = true,
    );
    _setupDataChannel(channel);
  }

  void _setupDataChannel(RTCDataChannel channel) {
    dataChannel = channel;
    channel.onMessage = (message) {
      _onDataChannelMessage.add(message.text);
    };
    channel.onDataChannelState = (state) {
      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        _onDataChannelOpen.add(null);
      }
    };
  }

  Future<RTCSessionDescription> createOffer() async {
    final offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);
    return offer;
  }

  Future<RTCSessionDescription> createAnswer() async {
    final answer = await peerConnection!.createAnswer();
    await peerConnection!.setLocalDescription(answer);
    return answer;
  }

  Future<void> setRemoteDescription(RTCSessionDescription description) async {
    await peerConnection!.setRemoteDescription(description);
    _hasRemoteDescription = true;
    // Flush any ICE candidates that arrived before the remote description
    for (final candidate in _pendingCandidates) {
      await peerConnection!.addCandidate(candidate);
    }
    _pendingCandidates.clear();
  }

  Future<void> addCandidate(RTCIceCandidate candidate) async {
    if (_hasRemoteDescription && peerConnection != null) {
      await peerConnection!.addCandidate(candidate);
    } else {
      _pendingCandidates.add(candidate);
    }
  }

  Future<void> startLocalMedia({bool video = true, bool audio = true}) async {
    // At least one track must be requested
    if (!video && !audio) return;
    final constraints = <String, dynamic>{
      'audio': audio,
      'video': video ? {'facingMode': 'user'} : false,
    };
    localStream = await navigator.mediaDevices.getUserMedia(constraints);
    for (final track in localStream!.getTracks()) {
      await peerConnection!.addTrack(track, localStream!);
    }
  }

  Future<void> startScreenShare() async {
    screenStream = await navigator.mediaDevices.getDisplayMedia({
      'video': true,
      'audio': false,
    });

    if (peerConnection != null && screenStream != null) {
      final senders = await peerConnection!.getSenders();
      final videoTrack = screenStream!.getVideoTracks().first;
      for (final sender in senders) {
        if (sender.track?.kind == 'video') {
          await sender.replaceTrack(videoTrack);
          break;
        }
      }
    }
  }

  Future<void> stopScreenShare() async {
    if (screenStream != null) {
      for (final track in screenStream!.getTracks()) {
        await track.stop();
      }
      screenStream?.dispose();
      screenStream = null;

      // Restore camera track
      if (localStream != null && peerConnection != null) {
        final senders = await peerConnection!.getSenders();
        final videoTrack = localStream!.getVideoTracks().firstOrNull;
        if (videoTrack != null) {
          for (final sender in senders) {
            if (sender.track?.kind == 'video') {
              await sender.replaceTrack(videoTrack);
              break;
            }
          }
        }
      }
    }
  }

  void toggleAudio(bool enabled) {
    localStream?.getAudioTracks().forEach((track) {
      track.enabled = enabled;
    });
  }

  void toggleVideo(bool enabled) {
    localStream?.getVideoTracks().forEach((track) {
      track.enabled = enabled;
    });
  }

  Future<void> dispose() async {
    dataChannel?.close();
    dataChannel = null;

    if (localStream != null) {
      for (final track in localStream!.getTracks()) {
        await track.stop();
      }
      await localStream!.dispose();
      localStream = null;
    }

    if (screenStream != null) {
      for (final track in screenStream!.getTracks()) {
        await track.stop();
      }
      await screenStream!.dispose();
      screenStream = null;
    }

    remoteStream?.dispose();
    remoteStream = null;

    await peerConnection?.close();
    peerConnection = null;

    _onIceCandidate.close();
    _onDataChannelMessage.close();
    _onDataChannelOpen.close();
    _onRemoteStream.close();
    _onConnectionState.close();
  }
}
