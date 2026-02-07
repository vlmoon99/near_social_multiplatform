// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_operation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PendingOperation _$PendingOperationFromJson(Map<String, dynamic> json) =>
    PendingOperation(
      id: json['id'] as String,
      type: $enumDecode(_$OperationTypeEnumMap, json['type']),
      payload: json['payload'] as Map<String, dynamic>,
      status: $enumDecodeNullable(_$OperationStatusEnumMap, json['status']) ??
          OperationStatus.pending,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastAttemptAt: json['lastAttemptAt'] == null
          ? null
          : DateTime.parse(json['lastAttemptAt'] as String),
      attemptCount: (json['attemptCount'] as num?)?.toInt() ?? 0,
      errorMessage: json['errorMessage'] as String?,
      maxRetries: (json['maxRetries'] as num?)?.toInt() ?? 3,
    );

Map<String, dynamic> _$PendingOperationToJson(PendingOperation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$OperationTypeEnumMap[instance.type]!,
      'status': _$OperationStatusEnumMap[instance.status]!,
      'payload': instance.payload,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastAttemptAt': instance.lastAttemptAt?.toIso8601String(),
      'attemptCount': instance.attemptCount,
      'errorMessage': instance.errorMessage,
      'maxRetries': instance.maxRetries,
    };

const _$OperationTypeEnumMap = {
  OperationType.likePost: 'likePost',
  OperationType.unlikePost: 'unlikePost',
  OperationType.likeComment: 'likeComment',
  OperationType.unlikeComment: 'unlikeComment',
  OperationType.repostPost: 'repostPost',
  OperationType.createPost: 'createPost',
  OperationType.createComment: 'createComment',
  OperationType.followAccount: 'followAccount',
  OperationType.unfollowAccount: 'unfollowAccount',
  OperationType.pokeAccount: 'pokeAccount',
};

const _$OperationStatusEnumMap = {
  OperationStatus.pending: 'pending',
  OperationStatus.inProgress: 'inProgress',
  OperationStatus.completed: 'completed',
  OperationStatus.failed: 'failed',
  OperationStatus.retrying: 'retrying',
};
