// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => _ChatMessage(
  senderId: json['senderId'] as String,
  text: json['text'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  isMe: json['isMe'] as bool? ?? false,
);

Map<String, dynamic> _$ChatMessageToJson(_ChatMessage instance) =>
    <String, dynamic>{
      'senderId': instance.senderId,
      'text': instance.text,
      'timestamp': instance.timestamp.toIso8601String(),
      'isMe': instance.isMe,
    };
