import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:near_social_mobile/services/cryptography/internal_cryptography_service.dart';
// ignore: depend_on_referenced_packages
import 'package:scroll_to_index/scroll_to_index.dart';

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
  final _scrollController = AutoScrollController();

  late final types.User _user;
  StreamSubscription<List<Map<String, dynamic>>>? newMessageSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? chatSubscription;

  @override
  void initState() {
    super.initState();
    final currentUserAccountID = Modular.get<AuthController>().state.accountId;
    _user = types.User(id: currentUserAccountID);
    _setupNewMessageStream();
    _setupChatStream();
    _scrollController.addListener(_onScroll);
  }

  void _setupChatStream() async {
    chatSubscription = Supabase.instance.client
        .from('Chat')
        .stream(primaryKey: ['id'])
        .eq('id', widget.chat['id'].toString())
        .listen((data) {
          widget.chat['metadata'] = data[0]['metadata'];
        });
  }

  Future<void> _setupNewMessageStream() async {
    final currentUserAccountID = Modular.get<AuthController>().state.accountId;

    final pubKeys = widget.chat['metadata']['pub_keys'] as Map<String, dynamic>;

    if (pubKeys[currentUserAccountID] == null) {
      final secureStorage = Modular.get<FlutterSecureStorage>();

      var res = (await secureStorage.read(
        key: widget.chat['id'],
      ));

      if (res == null) {
        final keyPair = await Modular.get<InternalCryptographyService>()
            .encryptionRunner
            .generateKeyPair();

        await secureStorage.write(
            key: widget.chat['id'], value: jsonEncode(keyPair.toJson()));
        res = (await secureStorage.read(
          key: widget.chat['id'],
        ));
      }

      final keys = jsonDecode(res!);

      final publicKey = keys['public_key'];

      pubKeys.putIfAbsent(currentUserAccountID, () => publicKey);

      widget.chat['metadata']['pub_keys'] = pubKeys;
      try {
        final response = await Supabase.instance.client.functions.invoke(
          'chat_creation',
          headers: {
            "Accept": "application/json",
            "Access-Control-Allow-Origin": "*",
          },
          body: widget.chat,
        );

        print("response.data ${response.data}");

        return response.data;
      } catch (e) {
        print('Unexpected error: $e');
      }
    }

    newMessageSubscription = Supabase.instance.client
        .from('Message')
        .stream(primaryKey: ['id'])
        .eq('chat_id', widget.chat['id'])
        .order('created_at', ascending: false)
        .listen(
          _handlePushNewMessage,
          onError: (err) {},
        );
  }

  Future<void> _handlePushNewMessage(
      List<Map<String, dynamic>> listOfMessages) async {
    try {
      print("step 1");
      if (!mounted) return;
      for (var newMessage in listOfMessages) {
        print("step 2");

        final existingIndex =
            _messages.indexWhere((msg) => msg.id == newMessage['id']);
        final mapedMessage = await _mapMessage(newMessage);
        print("step 3");

        if (existingIndex != -1) {
          _messages[existingIndex] = mapedMessage;
        } else {
          _messages.insert(0, mapedMessage);
        }
        print("step 4");
      }
      _messages.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
      print("step 5");

      setState(() {});
    } catch (e) {
      print("Error $e");
    }
  }

  Future<types.Message> _mapMessage(Map<String, dynamic> rawMessage) async {
    print("rawMessage $rawMessage");
    final parsedMessage = types.TextMessage(
      id: rawMessage['id'],
      text: rawMessage['message']['text'],
      createdAt:
          DateTime.parse(rawMessage['created_at']).millisecondsSinceEpoch,
      author: types.User(id: rawMessage['author_id']),
    );

    print("parsedMessage $parsedMessage");

    return types.TextMessage(
      id: rawMessage['id'],
      text: rawMessage['message']['text'],
      createdAt:
          DateTime.parse(rawMessage['created_at']).millisecondsSinceEpoch,
      author: types.User(id: rawMessage['author_id']),
    );
  }

  void _onScroll() {
    final comparsion1 = _scrollController.position.pixels ==
        _scrollController.position.minScrollExtent;
    final comparsion2 = _scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent;

    if (comparsion1) {
      print("comparsion1 $comparsion1");
    } else if (comparsion2) {
      print("comparsion2 $comparsion2");
    }
  }

  Future<void> _handleSendPressed(types.PartialText message) async {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: Random().nextInt(1000000).toString(),
      text: message.text,
    );
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

    final messageData = res['message_data'];
    final mappedMessage = await _mapMessage(messageData);

    setState(() {
      _messages.add(mappedMessage);
      newMessageSubscription?.cancel();
      _setupNewMessageStream();
    });
  }

  void _handleMessageDelete(String messageId) async {
    final pageController = Modular.get<ChatPageController>();

    final res = await pageController.deleteMessage(messageId);
    setState(() {
      _messages.removeWhere((msg) => msg.id == res['updated_message']['id']);
      newMessageSubscription?.cancel();
      _setupNewMessageStream();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    newMessageSubscription?.cancel();
    chatSubscription?.cancel();
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
        scrollController: _scrollController,
        onEndReached: () async {
          print("onEndReached");
        },
        messages: _messages.reversed.toList(),
        onMessageLongPress: (context, message) {
          final currentUserAccountID =
              Modular.get<AuthController>().state.accountId;

          if (message.author.id != currentUserAccountID) {
            return;
          }

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
        onSendPressed: (text) async {
          final screenWidth = MediaQuery.of(context).size.width;

          final dialogWidth = screenWidth > 1200
              ? 400.0
              : screenWidth > 600
                  ? screenWidth * 0.3
                  : screenWidth * 0.8;
          print(widget.chat);
          final pubKeys =
              widget.chat['metadata']['pub_keys'] as Map<String, dynamic>;
          if (pubKeys.length < 2) {
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
                          Icons.error,
                          size: 32.r,
                          color: NEARColors.red,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Error',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: NEARColors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Another user in Chat must add his public key',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: NEARColors.black,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
            return;
          }
          _handleSendPressed(text);
        },
        showUserAvatars: true,
        showUserNames: true,
        user: _user,
      ),
    );
  }
}
