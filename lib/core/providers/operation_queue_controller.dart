import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:near_social_mobile/core/network/near_social_api.dart';
import 'package:near_social_mobile/core/models/pending_operation.dart';
import 'package:near_social_mobile/core/providers/service_providers.dart';
import 'package:near_social_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'operation_queue_controller.freezed.dart';
part 'operation_queue_controller.g.dart';

const _storageKey = 'pending_blockchain_operations';

@freezed
abstract class OperationQueueState with _$OperationQueueState {
  const OperationQueueState._();

  const factory OperationQueueState({
    @Default([]) List<PendingOperation> operations,
    @Default(false) bool isProcessing,
    PendingOperation? currentOperation,
  }) = _OperationQueueState;

  int get pendingCount =>
      operations.where((op) => op.status == OperationStatus.pending).length;

  int get failedCount =>
      operations.where((op) => op.status == OperationStatus.failed).length;

  int get inProgressCount =>
      operations.where((op) => op.status == OperationStatus.inProgress).length;
}

@Riverpod(keepAlive: true)
class OperationQueueController extends _$OperationQueueController {
  late FlutterSecureStorage _secureStorage;
  late NearSocialApi _nearSocialApi;

  bool _isProcessing = false;
  final _uuid = const Uuid();

  @override
  OperationQueueState build() {
    _secureStorage = ref.watch(secureStorageProvider);
    _nearSocialApi = ref.watch(nearSocialApiProvider);

    // Load persisted operations on initialization
    Future.microtask(() => _loadPersistedOperations());

    return const OperationQueueState();
  }

  /// Load operations from secure storage on startup
  Future<void> _loadPersistedOperations() async {
    try {
      final stored = await _secureStorage.read(key: _storageKey);
      if (stored == null || stored.isEmpty) return;

      final List<dynamic> decoded = jsonDecode(stored);
      final operations = decoded
          .map((e) => PendingOperation.fromJson(e as Map<String, dynamic>))
          .where((op) => !op.isExpired) // Remove expired operations
          .where((op) => op.status != OperationStatus.completed) // Remove completed
          .toList();

      state = state.copyWith(operations: operations);

      // Resume processing pending operations
      _processQueue();
    } catch (e) {
      log('Failed to load persisted operations: $e');
    }
  }

  /// Save operations to secure storage
  Future<void> _persistOperations() async {
    try {
      final json = jsonEncode(
        state.operations.map((op) => op.toJson()).toList(),
      );
      await _secureStorage.write(key: _storageKey, value: json);
    } catch (e) {
      log('Failed to persist operations: $e');
    }
  }

  /// Add a new operation to the queue
  Future<String> enqueue({
    required OperationType type,
    required Map<String, dynamic> payload,
  }) async {
    final id = _uuid.v4();
    final operation = PendingOperation(
      id: id,
      type: type,
      payload: payload,
      createdAt: DateTime.now(),
    );

    final newOperations = [...state.operations, operation];
    state = state.copyWith(operations: newOperations);

    // Persist immediately
    await _persistOperations();

    // Start processing
    _processQueue();

    return id;
  }

  /// Process the queue
  Future<void> _processQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;

    while (true) {
      // Find next pending operation
      final pendingIndex = state.operations.indexWhere(
        (op) => op.status == OperationStatus.pending && op.canRetry,
      );

      if (pendingIndex == -1) break;

      final pending = state.operations[pendingIndex];

      // Mark as in progress
      _updateOperation(pending.id, status: OperationStatus.inProgress);
      state = state.copyWith(
        isProcessing: true,
        currentOperation: pending,
      );

      try {
        await _executeOperation(pending);

        // Mark as completed and remove from list
        final remaining = state.operations
            .where((op) => op.id != pending.id)
            .toList();
        state = state.copyWith(
          operations: remaining,
          currentOperation: null,
        );
      } catch (e) {
        log('Operation ${pending.id} failed: $e');

        final newAttemptCount = pending.attemptCount + 1;
        if (newAttemptCount >= pending.maxRetries) {
          _updateOperation(
            pending.id,
            status: OperationStatus.failed,
            errorMessage: e.toString(),
            attemptCount: newAttemptCount,
          );
        } else {
          _updateOperation(
            pending.id,
            status: OperationStatus.pending,
            attemptCount: newAttemptCount,
            lastAttemptAt: DateTime.now(),
          );

          // Wait before retry (exponential backoff)
          await Future.delayed(Duration(seconds: 2 * newAttemptCount));
        }
      }

      await _persistOperations();
    }

    _isProcessing = false;
    state = state.copyWith(
      isProcessing: false,
      currentOperation: null,
    );
  }

  void _updateOperation(
    String id, {
    required OperationStatus status,
    String? errorMessage,
    int attemptCount = -1,
    DateTime? lastAttemptAt,
  }) {
    final updated = state.operations.map((op) {
      if (op.id == id) {
        return op.copyWith(
          status: status,
          errorMessage: errorMessage,
          attemptCount: attemptCount >= 0 ? attemptCount : op.attemptCount,
          lastAttemptAt: lastAttemptAt ?? DateTime.now(),
        );
      }
      return op;
    }).toList();

    state = state.copyWith(operations: updated);
  }

  Future<void> _executeOperation(PendingOperation op) async {
    final authState = ref.read(authControllerProvider);
    final accountId = authState.accountId;
    final publicKey = authState.publicKey;
    final privateKey = authState.privateKey;

    switch (op.type) {
      case OperationType.likePost:
        await _nearSocialApi.likePost(
          accountIdOfPost: op.payload['accountIdOfPost'] as String,
          accountId: accountId,
          blockHeight: op.payload['blockHeight'] as int,
          publicKey: publicKey,
          privateKey: privateKey,
        );
        break;

      case OperationType.unlikePost:
        await _nearSocialApi.unlikePost(
          accountIdOfPost: op.payload['accountIdOfPost'] as String,
          accountId: accountId,
          blockHeight: op.payload['blockHeight'] as int,
          publicKey: publicKey,
          privateKey: privateKey,
        );
        break;

      case OperationType.repostPost:
        await _nearSocialApi.repostPost(
          accountIdOfPost: op.payload['accountIdOfPost'] as String,
          accountId: accountId,
          blockHeight: op.payload['blockHeight'] as int,
          publicKey: publicKey,
          privateKey: privateKey,
        );
        break;

      case OperationType.likeComment:
        await _nearSocialApi.likeComment(
          accountIdOfPost: op.payload['accountIdOfPost'] as String,
          accountId: accountId,
          blockHeight: op.payload['blockHeight'] as int,
          publicKey: publicKey,
          privateKey: privateKey,
        );
        break;

      case OperationType.unlikeComment:
        await _nearSocialApi.unlikeComment(
          accountIdOfPost: op.payload['accountIdOfPost'] as String,
          accountId: accountId,
          blockHeight: op.payload['blockHeight'] as int,
          publicKey: publicKey,
          privateKey: privateKey,
        );
        break;

      case OperationType.followAccount:
        await _nearSocialApi.followAccount(
          accountIdToFollow: op.payload['accountIdToFollow'] as String,
          accountId: accountId,
          publicKey: publicKey,
          privateKey: privateKey,
        );
        break;

      case OperationType.unfollowAccount:
        await _nearSocialApi.unfollowAccount(
          accountIdToUnfollow: op.payload['accountIdToUnfollow'] as String,
          accountId: accountId,
          publicKey: publicKey,
          privateKey: privateKey,
        );
        break;

      case OperationType.pokeAccount:
        await _nearSocialApi.pokeAccount(
          accountIdToPoke: op.payload['accountIdToPoke'] as String,
          accountId: accountId,
          publicKey: publicKey,
          privateKey: privateKey,
        );
        break;

      case OperationType.createPost:
      case OperationType.createComment:
        // These require additional handling for media uploads
        throw UnimplementedError('Post/Comment creation not yet implemented in queue');
    }
  }

  /// Retry a failed operation
  Future<void> retryOperation(String id) async {
    _updateOperation(
      id,
      status: OperationStatus.pending,
      attemptCount: 0,
      errorMessage: null,
    );
    await _persistOperations();
    _processQueue();
  }

  /// Cancel a pending operation
  Future<void> cancelOperation(String id) async {
    final remaining = state.operations
        .where((op) => op.id != id)
        .toList();
    state = state.copyWith(operations: remaining);
    await _persistOperations();
  }

  /// Clear all failed operations
  Future<void> clearFailedOperations() async {
    final remaining = state.operations
        .where((op) => op.status != OperationStatus.failed)
        .toList();
    state = state.copyWith(operations: remaining);
    await _persistOperations();
  }

  /// Clear all completed operations (already removed automatically, but for safety)
  Future<void> clearCompletedOperations() async {
    final remaining = state.operations
        .where((op) => op.status != OperationStatus.completed)
        .toList();
    state = state.copyWith(operations: remaining);
    await _persistOperations();
  }
}
