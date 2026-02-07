import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pending_operation.g.dart';

enum OperationType {
  likePost,
  unlikePost,
  likeComment,
  unlikeComment,
  repostPost,
  createPost,
  createComment,
  followAccount,
  unfollowAccount,
  pokeAccount,
}

enum OperationStatus {
  pending,
  inProgress,
  completed,
  failed,
  retrying,
}

@JsonSerializable()
class PendingOperation extends Equatable {
  final String id;
  final OperationType type;
  final OperationStatus status;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final DateTime? lastAttemptAt;
  final int attemptCount;
  final String? errorMessage;
  final int maxRetries;

  const PendingOperation({
    required this.id,
    required this.type,
    required this.payload,
    this.status = OperationStatus.pending,
    required this.createdAt,
    this.lastAttemptAt,
    this.attemptCount = 0,
    this.errorMessage,
    this.maxRetries = 3,
  });

  PendingOperation copyWith({
    String? id,
    OperationType? type,
    OperationStatus? status,
    Map<String, dynamic>? payload,
    DateTime? createdAt,
    DateTime? lastAttemptAt,
    int? attemptCount,
    String? errorMessage,
    int? maxRetries,
  }) {
    return PendingOperation(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      attemptCount: attemptCount ?? this.attemptCount,
      errorMessage: errorMessage,
      maxRetries: maxRetries ?? this.maxRetries,
    );
  }

  bool get canRetry => attemptCount < maxRetries;

  bool get isExpired {
    // Operations older than 24 hours are considered expired
    return DateTime.now().difference(createdAt).inHours > 24;
  }

  factory PendingOperation.fromJson(Map<String, dynamic> json) =>
      _$PendingOperationFromJson(json);

  Map<String, dynamic> toJson() => _$PendingOperationToJson(this);

  @override
  List<Object?> get props => [
        id,
        type,
        status,
        payload,
        createdAt,
        lastAttemptAt,
        attemptCount,
        errorMessage,
        maxRetries,
      ];
}
