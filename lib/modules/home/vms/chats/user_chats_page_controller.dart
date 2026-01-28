// =============================================================================
// USER CHATS PAGE CONTROLLER - TEMPORARILY DISABLED FOR DECENTRALIZATION
// =============================================================================
//
// This controller was used to manage chats via Supabase Edge Functions.
// It has been disabled as part of the decentralization effort.
//
// =============================================================================

import 'package:near_social_mobile/modules/home/vms/chats/models/chat_model.dart';
import 'package:near_social_mobile/modules/home/vms/chats/models/user_chat_page_state.dart';
import 'package:rxdart/rxdart.dart';

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
    return {
      'result': 'error',
      'operation_message': 'Chat functionality disabled for decentralization',
    };
  }

  Future<Map<String, dynamic>> deleteChat(String chatId) async {
    return {
      'result': 'error',
      'operation_message': 'Chat functionality disabled for decentralization',
    };
  }
}
