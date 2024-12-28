import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:near_social_mobile/config/theme.dart';
import 'package:near_social_mobile/modules/home/pages/chat/chat_page.dart';
import 'package:near_social_mobile/modules/home/vms/chats/user_chats_page_controller.dart';
import 'package:near_social_mobile/modules/vms/core/auth_controller.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class ChatListBody extends StatefulWidget {
  const ChatListBody({
    super.key,
  });

  @override
  _ChatListBodyState createState() => _ChatListBodyState();
}

class _ChatListBodyState extends State<ChatListBody> {
  final _scrollController = ScrollController();
  final List<Map<String, dynamic>> _chats = [];
  StreamSubscription<List<Map<String, dynamic>>>? chatSubscription;

  @override
  void initState() {
    super.initState();
    _setupInitialStream();
    print("uid ${Supabase.instance.client.auth.currentUser!.id}");
  }

  void _setupInitialStream() async {
    chatSubscription = Supabase.instance.client
        .from('Chat')
        .stream(primaryKey: ['id']).listen(_handleStreamData);
  }

  void _handleStreamData(List<Map<String, dynamic>> listOfChats) {
    print(listOfChats);

    if (!mounted) return;

    setState(() {
      // Handle updates to existing chats
      for (var newChat in listOfChats) {
        final existingIndex =
            _chats.indexWhere((chat) => chat['id'] == newChat['id']);

        if (existingIndex != -1) {
          // Update existing chat
          _chats[existingIndex] = newChat;
        } else {
          // Add new chat if it's within our time window
          _chats.add(newChat);
        }
      }
    });
  }

  @override
  void dispose() {
    chatSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  String _getChatTitle(Map<String, dynamic> chat) {
    final metadata = chat['metadata'] as Map<String, dynamic>;
    final participants = List<String>.from(metadata['participants']);
    final currentUserAccountId = Modular.get<AuthController>().state.accountId;

    participants.remove(currentUserAccountId);

    return participants.isNotEmpty ? participants.first : 'Chat';
  }

  @override
  Widget build(BuildContext context) {
    final dialogWidth = 500.0;

    return ListView.builder(
      controller: _scrollController,
      itemCount: _chats.length,
      itemBuilder: (context, index) {
        final chat = _chats[index];
        final metadata = chat['metadata'] as Map<String, dynamic>;

        return ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => ChatPage(
                  chat: chat,
                ),
              ),
            );
          },
          leading: CircleAvatar(
            backgroundColor: NEARColors.aqua,
            child: Text(_getChatTitle(chat)[index].toUpperCase()),
          ),
          title: Text(
            _getChatTitle(chat),
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: NEARColors.black),
          ),
          subtitle: Text(
            "Type of chat : ${metadata['chat_type']} , Last update : ${DateFormat('MMM d, y').format(
              DateTime.parse(chat['updated_at']),
            )}",
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: NEARColors.black),
          ),
          trailing: IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: dialogWidth,
                        minWidth: 280.0,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 24.h,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 32.r,
                            color: NEARColors.red,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Delete Chat',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: NEARColors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'Are you sure you want to delete this chat?',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: NEARColors.black,
                                    ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 24.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                      side: BorderSide(
                                        color: NEARColors.grey,
                                        width: 1.0,
                                      ),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 12.h,
                                    ),
                                    minimumSize: Size(100.w, 44.h),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          color: NEARColors.grey,
                                          // fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final pageController =
                                        Modular.get<UserChatsPageController>();
                                    final res = await pageController
                                        .deleteChat(chat['id'].toString());

                                    print("delete chat res : $res");

                                    Navigator.of(context).pop();

                                    setState(() {
                                      chatSubscription?.cancel();
                                      final chatId = res['chat_data']['id'];
                                      _chats.removeWhere(
                                          (chat) => chat['id'] == chatId);

                                      _setupInitialStream();
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: NEARColors.red,
                                    padding: EdgeInsets.symmetric(
                                      vertical: 12.h,
                                    ),
                                    minimumSize: Size(100.w, 44.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                  child: Text(
                                    'Delete',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          color: NEARColors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            icon: Icon(
              Icons.delete,
              color: NEARColors.red,
            ),
          ),
        );
      },
    );
  }
}
