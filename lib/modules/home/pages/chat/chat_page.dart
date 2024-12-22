import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_social_mobile/config/theme.dart';
import 'package:near_social_mobile/modules/vms/core/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//Controller
class ChatPageController {
  Future<Map<String, dynamic>> addMessage(Map<String, dynamic> message) async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'add_message_to_the_chat',
        headers: {
          "Accept": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
        body: message,
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

  Future<Map<String, dynamic>> deleteMessage(String messageId) async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'delete_message_from_the_chat',
        headers: {
          "Accept": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
        body: {"messageId": messageId},
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

//Page

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.chat,
  });
  final Map<String, dynamic> chat;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<types.Message> _messages = [];
  final _scrollController = ScrollController();

  late final types.User _user;
  StreamSubscription<List<Map<String, dynamic>>>? messagesSubscription;

  bool _isLoading = false;
  DateTime? _lastTimestamp;
  static const int _pageSize = 50;

  @override
  void initState() {
    super.initState();
    final currentUserAccountID = Modular.get<AuthController>().state.accountId;
    _user = types.User(id: currentUserAccountID);
    _setupInitialStream();
    _scrollController.addListener(_onScroll);
  }

  void _setupInitialStream() {
    _lastTimestamp = DateTime.now();
    print("widget.chat['id'] ${widget.chat['id']}");
    messagesSubscription = Supabase.instance.client
        .from('Message')
        .stream(primaryKey: ['id'])
        .eq('chat_id', widget.chat['id'])
        .order('created_at', ascending: false)
        .limit(_pageSize)
        .listen(
          _handleStreamData,
          onError: (err) {
            print(err.toString());
          },
        );
  }

  void _handleStreamData(List<Map<String, dynamic>> listOfMessages) {
    print("listOfMessages $listOfMessages");

    if (!mounted) return;

    setState(() {
      for (var newMessage in listOfMessages) {
        final existingIndex =
            _messages.indexWhere((msg) => msg.id == newMessage['id']);

        if (existingIndex != -1) {
          _messages[existingIndex] = _mapMessage(newMessage);
        } else {
          _messages.insert(0, _mapMessage(newMessage));
        }
      }

      _messages.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
    });
  }

  types.Message _mapMessage(Map<String, dynamic> rawMessage) {
    return types.TextMessage(
      id: rawMessage['id'],
      text: rawMessage['message']['text'],
      createdAt:
          DateTime.parse(rawMessage['created_at']).millisecondsSinceEpoch,
      author: types.User(id: rawMessage['author_id']),
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.minScrollExtent) {
      _loadMoreMessages();
    }
  }

  Future<void> _loadMoreMessages() async {
    if (_isLoading || _lastTimestamp == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Update last timestamp for pagination
      final oldestMessage = _messages.isNotEmpty ? _messages.first : null;
      if (oldestMessage != null) {
        _lastTimestamp = DateTime.fromMillisecondsSinceEpoch(
          oldestMessage.createdAt!,
        );
      }

      // Fetch older messages
      final olderMessages = await Supabase.instance.client
          .from('Message')
          .select()
          .eq('chat_id', widget.chat['id'])
          .lte('updated_at', _lastTimestamp!.toIso8601String())
          .order('updated_at', ascending: false)
          .limit(_pageSize);

      if (olderMessages.isNotEmpty) {
        setState(() {
          final newMessages =
              olderMessages.map((msg) => _mapMessage(msg)).toList();
          _messages.insertAll(0, newMessages);
        });
      }
    } catch (e) {
      print('Error loading more messages: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleSendPressed(types.PartialText message) async {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: Random().nextInt(1000000).toString(),
      text: message.text,
    );
    print(
        "widget.chat['participants'] ${widget.chat['metadata']['participants']}");
    final participants =
        (widget.chat['metadata']['participants'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();

    final participantsMap = {
      for (int i = 0; i < participants.length; i++) participants[i]: false
    };

    final pageController = Modular.get<ChatPageController>();

    final res = await pageController.addMessage({
      'chatId': widget.chat['id'],
      'authorId': _user.id,
      'messageType': 'text',
      'message': {'text': textMessage.text, 'delete': participantsMap},
    });

    print("res $res");
  }

  void _handleMessageDelete(String messageId) async {
    final pageController = Modular.get<ChatPageController>();

    final res = await pageController.deleteMessage(messageId);
    print("res $res");
  }

  @override
  void dispose() {
    messagesSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final dialogWidth = screenWidth > 1200
        ? 400.0
        : screenWidth > 600
            ? screenWidth * 0.3
            : screenWidth * 0.8;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: NEARColors.blue,
        title: Row(
          children: [
            Text(
              'Chat',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: NEARColors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              print("Start Call");
            },
            icon: Icon(Icons.video_call),
          ),
          IconButton(
            onPressed: () {
              print("Start Call");
            },
            icon: Icon(Icons.call),
          ),
        ],
      ),
      body: Chat(
        messages: _messages,
        onMessageLongPress: (context, message) {
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
                        'Delete Message',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: NEARColors.black,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Are you sure you want to delete this message?',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                                'No',
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
                              onPressed: () {
                                _handleMessageDelete(
                                  message.id,
                                );
                                Navigator.of(context).pop();
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
                                'Yes',
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
        onAttachmentPressed: () {
          print("_handleAttachmentPressed");
        },
        onMessageTap: (context, msg) {
          print('_handleMessageTap');
        },
        onPreviewDataFetched: (text, preview) {
          print('_handlePreviewDataFetched');
        },
        onSendPressed: _handleSendPressed,
        showUserAvatars: true,
        showUserNames: true,
        user: _user,
      ),
    );
  }
}
