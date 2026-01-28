// =============================================================================
// CHAT PAGE CONTROLLER - TEMPORARILY DISABLED FOR DECENTRALIZATION
// =============================================================================
//
// This controller was used to manage chat messages via Supabase Edge Functions.
// It has been disabled as part of the decentralization effort.
//
// =============================================================================

class ChatPageController {
  Future<Map<String, dynamic>> addMessage(Map<String, dynamic> message) async {
    return {
      'result': 'error',
      'operation_message': 'Chat functionality disabled for decentralization',
    };
  }

  Future<Map<String, dynamic>> deleteMessage(String messageId) async {
    return {
      'result': 'error',
      'operation_message': 'Chat functionality disabled for decentralization',
    };
  }
}
