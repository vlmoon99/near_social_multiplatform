import 'dart:convert';

import 'package:near_social_mobile/core/services/secure_storage_service.dart';
import 'package:near_social_mobile/features/chat/data/models/chat_message.dart';

/// Persists chat history locally using [CryptoStorageService] (AES-256-CBC
/// encrypted FlutterSecureStorage).
class ChatStorageService {
  final CryptoStorageService _cryptoStorage;

  ChatStorageService({required CryptoStorageService cryptoStorage})
      : _cryptoStorage = cryptoStorage;

  String _historyKey(String myAccountId, String peerId) =>
      'chat_history_${myAccountId}_$peerId';

  String _peersKey(String myAccountId) => 'chat_peers_$myAccountId';

  /// Save messages for a specific peer conversation.
  Future<void> saveMessages(
    String myAccountId,
    String peerId,
    List<ChatMessage> messages,
  ) async {
    final jsonList = messages.map((m) => m.toJson()).toList();
    await _cryptoStorage.write(
      storageKey: _historyKey(myAccountId, peerId),
      data: jsonEncode(jsonList),
    );
    await _addPeer(myAccountId, peerId);
  }

  /// Load messages for a specific peer conversation.
  Future<List<ChatMessage>> loadMessages(
    String myAccountId,
    String peerId,
  ) async {
    try {
      final raw = await _cryptoStorage.read(
        storageKey: _historyKey(myAccountId, peerId),
      );
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Delete chat history for a specific peer.
  Future<void> deleteHistory(String myAccountId, String peerId) async {
    try {
      await _cryptoStorage.write(
        storageKey: _historyKey(myAccountId, peerId),
        data: jsonEncode([]),
      );
    } catch (_) {}
  }

  /// Get list of known peer IDs for this account.
  Future<List<String>> getChatPeers(String myAccountId) async {
    try {
      final raw = await _cryptoStorage.read(storageKey: _peersKey(myAccountId));
      final list = jsonDecode(raw) as List;
      return list.cast<String>();
    } catch (_) {
      return [];
    }
  }

  Future<void> _addPeer(String myAccountId, String peerId) async {
    final peers = await getChatPeers(myAccountId);
    if (!peers.contains(peerId)) {
      peers.add(peerId);
      await _cryptoStorage.write(
        storageKey: _peersKey(myAccountId),
        data: jsonEncode(peers),
      );
    }
  }
}
