import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:near_social_mobile/modules/home/apis/near_social.dart';
import 'package:near_social_mobile/modules/home/vms/blockchain/models/pending_operation.dart';
import 'package:near_social_mobile/modules/vms/core/auth_controller.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

const _storageKey = 'pending_blockchain_operations';

class OperationQueueState {
  final List<PendingOperation> operations;
  final bool isProcessing;
  final PendingOperation? currentOperation;

  const OperationQueueState({
    this.operations = const [],
    this.isProcessing = false,
    this.currentOperation,
  });

  OperationQueueState copyWith({
    List<PendingOperation>? operations,
    bool? isProcessing,
    PendingOperation? currentOperation,
    bool clearCurrentOperation = false,
  }) {
    return OperationQueueState(
      operations: operations ?? this.operations,
      isProcessing: isProcessing ?? this.isProcessing,
      currentOperation:
          clearCurrentOperation ? null : (currentOperation ?? this.currentOperation),
    );
  }

  int get pendingCount =>
      operations.where((op) => op.status == OperationStatus.pending).length;

  int get failedCount =>
      operations.where((op) => op.status == OperationStatus.failed).length;

  int get inProgressCount =>
      operations.where((op) => op.status == OperationStatus.inProgress).length;
}

class OperationQueueController {
  final FlutterSecureStorage _secureStorage;
  final NearSocialApi _nearSocialApi;
  final AuthController _authController;

  final BehaviorSubject<OperationQueueState> _streamController =
      BehaviorSubject.seeded(const OperationQueueState());

  Stream<OperationQueueState> get stream => _streamController.stream;
  OperationQueueState get state => _streamController.value;

  bool _isProcessing = false;
  final _uuid = const Uuid();

  OperationQueueController(
    this._secureStorage,
    this._nearSocialApi,
    this._authController,
  ) {
    _loadPersistedOperations();
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

      _streamController.add(state.copyWith(operations: operations));

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
    _streamController.add(state.copyWith(operations: newOperations));

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
      _streamController.add(state.copyWith(
        isProcessing: true,
        currentOperation: pending,
      ));

      try {
        await _executeOperation(pending);

        // Mark as completed and remove from list
        final remaining = state.operations
            .where((op) => op.id != pending.id)
            .toList();
        _streamController.add(state.copyWith(
          operations: remaining,
          clearCurrentOperation: true,
        ));
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
    _streamController.add(state.copyWith(
      isProcessing: false,
      clearCurrentOperation: true,
    ));
  }

  void _updateOperation(
    String id, {
    OperationStatus? status,
    String? errorMessage,
    int? attemptCount,
    DateTime? lastAttemptAt,
  }) {
    final updated = state.operations.map((op) {
      if (op.id == id) {
        return op.copyWith(
          status: status,
          errorMessage: errorMessage,
          attemptCount: attemptCount,
          lastAttemptAt: lastAttemptAt ?? DateTime.now(),
        );
      }
      return op;
    }).toList();

    _streamController.add(state.copyWith(operations: updated));
  }

  Future<void> _executeOperation(PendingOperation op) async {
    final accountId = _authController.state.accountId;
    final publicKey = _authController.state.publicKey;
    final privateKey = _authController.state.privateKey;

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
    _streamController.add(state.copyWith(operations: remaining));
    await _persistOperations();
  }

  /// Clear all failed operations
  Future<void> clearFailedOperations() async {
    final remaining = state.operations
        .where((op) => op.status != OperationStatus.failed)
        .toList();
    _streamController.add(state.copyWith(operations: remaining));
    await _persistOperations();
  }

  /// Clear all completed operations (already removed automatically, but for safety)
  Future<void> clearCompletedOperations() async {
    final remaining = state.operations
        .where((op) => op.status != OperationStatus.completed)
        .toList();
    _streamController.add(state.copyWith(operations: remaining));
    await _persistOperations();
  }

  void dispose() {
    _streamController.close();
  }
}
