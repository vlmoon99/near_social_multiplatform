import 'package:equatable/equatable.dart';

import 'p2p_chat_message.dart';
import 'p2p_connection_stats.dart';

enum P2PCallStatus {
  idle,
  connecting,
  registered,
  calling,
  incomingCall,
  negotiating,
  connected,
  disconnected,
  failed,
}

class P2PCallState extends Equatable {
  final P2PCallStatus status;
  final String localUserId;
  final String remoteUserId;
  final bool isInitiator;
  final bool audioEnabled;
  final bool videoEnabled;
  final bool isScreenSharing;
  final List<P2PChatMessage> chatMessages;
  final P2PConnectionStats? connectionStats;
  final String? errorMessage;

  const P2PCallState({
    this.status = P2PCallStatus.idle,
    this.localUserId = '',
    this.remoteUserId = '',
    this.isInitiator = false,
    this.audioEnabled = true,
    this.videoEnabled = true,
    this.isScreenSharing = false,
    this.chatMessages = const [],
    this.connectionStats,
    this.errorMessage,
  });

  P2PCallState copyWith({
    P2PCallStatus? status,
    String? localUserId,
    String? remoteUserId,
    bool? isInitiator,
    bool? audioEnabled,
    bool? videoEnabled,
    bool? isScreenSharing,
    List<P2PChatMessage>? chatMessages,
    P2PConnectionStats? connectionStats,
    String? errorMessage,
  }) {
    return P2PCallState(
      status: status ?? this.status,
      localUserId: localUserId ?? this.localUserId,
      remoteUserId: remoteUserId ?? this.remoteUserId,
      isInitiator: isInitiator ?? this.isInitiator,
      audioEnabled: audioEnabled ?? this.audioEnabled,
      videoEnabled: videoEnabled ?? this.videoEnabled,
      isScreenSharing: isScreenSharing ?? this.isScreenSharing,
      chatMessages: chatMessages ?? this.chatMessages,
      connectionStats: connectionStats ?? this.connectionStats,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        localUserId,
        remoteUserId,
        isInitiator,
        audioEnabled,
        videoEnabled,
        isScreenSharing,
        chatMessages,
        connectionStats,
        errorMessage,
      ];
}
