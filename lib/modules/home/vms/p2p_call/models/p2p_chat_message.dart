import 'package:equatable/equatable.dart';

class P2PChatMessage extends Equatable {
  final String text;
  final bool isMe;
  final DateTime timestamp;

  const P2PChatMessage({
    required this.text,
    required this.isMe,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [text, isMe, timestamp];
}
