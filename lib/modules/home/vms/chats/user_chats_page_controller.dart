import 'dart:async';
import 'package:near_social_mobile/modules/home/vms/chats/models/chat_model.dart';
import 'package:near_social_mobile/modules/home/vms/chats/models/user_chat_page_state.dart';
import 'package:rxdart/rxdart.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart';

import 'dart:convert';

//VM's
class UserChatsPageController {
  final BehaviorSubject<UserChatPageState> pageStateStream =
      BehaviorSubject<UserChatPageState>()
        ..add(
          UserChatPageState(isSearching: false),
        );

  Future<Map<String, dynamic>> createChat({
    required ChatType chatType,
    required String currentUserId,
    required String otherUserId,
  }) async {
    try {
      switch (chatType) {
        case ChatType.privateUserToUser:
          return await _createPrivateUserToUserChat(currentUserId, otherUserId);
        // default:
        //   throw ArgumentError('Unsupported chat type');
      }
    } catch (e) {
      return {
        'result': 'error',
        'operation_message': 'Failed to create chat: $e',
      };
    }
  }

  Future<String> generateChatHash(
      String userId1, String userId2, String type) async {
    final sortedIds = [userId1, userId2, type]..sort();

    final bytes = utf8.encode(sortedIds.join('_'));
    final digest = sha256.convert(bytes);
    final chatId = digest.toString();

    return chatId;
  }

  Future<Map<String, dynamic>> createChatUsingEdgeFunction(
      Map<String, dynamic> data) async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'chat_creation',
        headers: {
          "Accept": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
        body: data,
      );
      return response.data;
    } catch (e) {
      print('Unexpected error: $e');
      return {
        'result': 'error',
        'operation_message': 'Unexpected error',
      };
    }
  }

  Future<Map<String, dynamic>> _createPrivateUserToUserChat(
      String currentUserId, String otherUserId) async {
    final chatId =
        await generateChatHash(currentUserId, otherUserId, 'private');

    final metadata = {
      'chat_type': 'private',
      'participants': [currentUserId, otherUserId],
    };

    final data = {
      'id': chatId,
      'metadata': metadata,
    };

    print(data.toString());

    try {
      return createChatUsingEdgeFunction(data);
    } catch (e) {
      return {
        'result': 'error',
        'operation_message': 'Error creating private chat: $e',
      };
    }
  }

  Future<Map<String, dynamic>> deleteChat(String chatId) async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'delete_chat',
        headers: {
          "Accept": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
        body: {"chatId": chatId},
      );
      return response.data;
    } catch (e) {
      print('Unexpected error: $e');
      return {
        'result': 'error',
        'operation_message': 'Unexpected error',
      };
    }
  }
}
