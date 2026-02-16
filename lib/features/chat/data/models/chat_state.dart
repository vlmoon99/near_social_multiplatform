import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:near_social_mobile/features/chat/data/models/chat_message.dart';

part 'chat_state.freezed.dart';

enum PeerConnectionStatus { disconnected, connecting, connected, inCall }

@freezed
abstract class ChatState with _$ChatState {
  const factory ChatState({
    @Default(false) bool signalingConnected,
    @Default(PeerConnectionStatus.disconnected) PeerConnectionStatus peerStatus,
    @Default([]) List<ChatMessage> messages,
    @Default('') String remotePeerId,
    @Default(false) bool isVideoEnabled,
    @Default(false) bool isAudioEnabled,
    @Default(false) bool isScreenSharing,
    @Default(null) String? incomingCallFrom,
    @Default(null) String? peerPublicKey,
    @Default(null) String? teeAttestation,
  }) = _ChatState;
}
