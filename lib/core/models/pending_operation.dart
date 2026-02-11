import 'package:freezed_annotation/freezed_annotation.dart';

part 'pending_operation.freezed.dart';
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

@freezed
abstract class PendingOperation with _$PendingOperation {
  const PendingOperation._();

  const factory PendingOperation({
    required String id,
    required OperationType type,
    @Default(OperationStatus.pending) OperationStatus status,
    required Map<String, dynamic> payload,
    required DateTime createdAt,
    DateTime? lastAttemptAt,
    @Default(0) int attemptCount,
    String? errorMessage,
    @Default(3) int maxRetries,
  }) = _PendingOperation;

  bool get canRetry => attemptCount < maxRetries;

  bool get isExpired {
    // Operations older than 24 hours are considered expired
    return DateTime.now().difference(createdAt).inHours > 24;
  }

  factory PendingOperation.fromJson(Map<String, dynamic> json) =>
      _$PendingOperationFromJson(json);
}
