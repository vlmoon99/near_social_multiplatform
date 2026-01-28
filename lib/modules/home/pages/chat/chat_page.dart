// =============================================================================
// CHAT PAGE - TEMPORARILY DISABLED FOR DECENTRALIZATION
// =============================================================================
//
// This file contains the chat functionality that was dependent on Supabase.
// It has been disabled as part of the decentralization effort.
//
// To re-enable in the future:
// 1. Implement a decentralized messaging solution (IPFS, NEAR SocialDB, etc.)
// 2. Update the message streaming to use the new backend
// 3. Uncomment and update this code
//
// Original dependencies:
// - supabase_flutter (real-time message streaming)
// - flutter_chat_ui (chat UI components)
// - flutter_chat_types (message models)
//
// =============================================================================

import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({
    super.key,
    required this.chat,
  });

  final Map<String, dynamic> chat;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: const Center(
        child: Text(
          'Chat functionality is temporarily disabled\n'
          'for decentralization.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
