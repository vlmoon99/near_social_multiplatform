import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:near_social_mobile/modules/home/vms/p2p_call/models/p2p_chat_message.dart';

class ChatSurface extends StatelessWidget {
  final List<P2PChatMessage> messages;
  final bool isDark;
  final TextEditingController textController;
  final VoidCallback onSend;

  const ChatSurface({
    super.key,
    required this.messages,
    required this.isDark,
    required this.textController,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          height: 240,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.white.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: messages.isEmpty
                    ? const Center(
                        child: Text(
                          'Waiting for messages...',
                          style: TextStyle(
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '${msg.isMe ? "Me" : "Peer"}: ${msg.text}',
                              style: TextStyle(
                                fontSize: 14,
                                color: msg.isMe
                                    ? CupertinoColors.activeBlue
                                    : CupertinoColors.systemGreen,
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoTextField(
                        controller: textController,
                        placeholder: 'Type a message...',
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white10
                              : Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        onSubmitted: (_) => onSend(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onSend,
                      child: const Icon(
                        CupertinoIcons.arrow_up_circle_fill,
                        size: 36,
                        color: CupertinoColors.activeBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
