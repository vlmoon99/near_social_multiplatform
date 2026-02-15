sealed class ChatEvent {}

class ConnectSignalingEvent extends ChatEvent {}

class DisconnectSignalingEvent extends ChatEvent {}

class StartChatEvent extends ChatEvent {
  final String targetAccountId;
  StartChatEvent({required this.targetAccountId});
}

class SendMessageEvent extends ChatEvent {
  final String text;
  SendMessageEvent({required this.text});
}

class StartCallEvent extends ChatEvent {
  final String targetAccountId;
  final bool video;
  StartCallEvent({required this.targetAccountId, this.video = false});
}

class AcceptCallEvent extends ChatEvent {}

class RejectCallEvent extends ChatEvent {}

class EndCallEvent extends ChatEvent {}

class ToggleVideoEvent extends ChatEvent {}

class ToggleAudioEvent extends ChatEvent {}

class StartScreenShareEvent extends ChatEvent {}

class StopScreenShareEvent extends ChatEvent {}

class LoadHistoryEvent extends ChatEvent {
  final String peerId;
  LoadHistoryEvent({required this.peerId});
}

class ClearHistoryEvent extends ChatEvent {}
