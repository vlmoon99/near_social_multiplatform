import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:near_social_mobile/config/constants.dart';
import 'package:near_social_mobile/config/theme.dart';
import 'package:near_social_mobile/modules/home/pages/chat/chat_page.dart';
import 'package:near_social_mobile/modules/vms/core/auth_controller.dart';
import 'package:rxdart/rxdart.dart';

import 'package:flutter_svg/flutter_svg.dart';
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
        case ChatType.publicUserToUser:
          return await _createPublicUserToUserChat(currentUserId, otherUserId);

        case ChatType.privateUserToUser:
          return await _createPrivateUserToUserChat(currentUserId, otherUserId);

        default:
          throw ArgumentError('Unsupported chat type');
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

  Future<Map<String, dynamic>> _createChatUsingEdgeFunction(
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

  Future<Map<String, dynamic>> _createPublicUserToUserChat(
      String currentUserId, String otherUserId) async {
    final chatId = await generateChatHash(currentUserId, otherUserId, 'public');

    final metadata = {
      'chat_type': 'public',
      'participants': [currentUserId, otherUserId],
    };

    final data = {
      'id': chatId,
      'metadata': metadata,
    };

    try {
      return _createChatUsingEdgeFunction(data);
    } catch (e) {
      return {
        'result': 'error',
        'operation_message': 'Error creating public chat: $e',
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
      'isSecure': true,
      'pub_keys': {},
    };

    final data = {
      'id': chatId,
      'metadata': metadata,
    };

    try {
      return _createChatUsingEdgeFunction(data);
    } catch (e) {
      return {
        'result': 'error',
        'operation_message': 'Error creating private chat: $e',
      };
    }
  }

  Future<Map<String, dynamic>> _createAIChat(String userId) async {
    final chatId = '${userId}_ai_${DateTime.now().millisecondsSinceEpoch}';

    final metadata = {
      'chat_type': 'ai',
      'user_id': userId,
    };

    try {
      final response = await Supabase.instance.client
          .from('Chat')
          .insert({
            'id': chatId,
            'metadata': metadata,
          })
          .select()
          .single();

      return {
        'result': 'ok',
        'operation_message': 'AI chat created successfully.',
        'chat_data': response,
      };
    } catch (e) {
      return {
        'result': 'error',
        'operation_message': 'Error creating AI chat: $e',
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

//Pages

class UserChatsPage extends StatefulWidget {
  const UserChatsPage({super.key});

  @override
  State<UserChatsPage> createState() => _UserChatsPageState();
}

class _UserChatsPageState extends State<UserChatsPage> {
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    final pageController = Modular.get<UserChatsPageController>();
    pageController.pageStateStream.close();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pageController = Modular.get<UserChatsPageController>();

    return StreamBuilder<UserChatPageState>(
      stream: pageController.pageStateStream,
      builder: (context, snapshot) {
        final state = snapshot.data ?? UserChatPageState(isSearching: false);
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0, -1),
                    end: Offset(0, 0),
                  ).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: state.isSearching
                  ? SearchAppBar(
                      key: ValueKey('searchAppBar'),
                      searchController: searchController,
                      onCancel: () {
                        searchController.clear();
                        final pageController =
                            Modular.get<UserChatsPageController>();

                        pageController.pageStateStream
                            .add(state.copyWith(isSearching: false));
                      },
                    )
                  : DefaultAppBar(
                      key: ValueKey('defaultAppBar'),
                      onSearchPressed: () {
                        final pageController =
                            Modular.get<UserChatsPageController>();

                        pageController.pageStateStream
                            .add(state.copyWith(isSearching: true));
                      },
                    ),
            ),
          ),
          body: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: state.isSearching
                ? SearchBody(
                    key: ValueKey('searchBody'),
                    searchController: searchController,
                  )
                : ChatListBody(
                    key: ValueKey('chatListBody'),
                  ),
          ),
        );
      },
    );
  }
}

//Widgets

class DefaultAppBar extends StatelessWidget {
  final VoidCallback onSearchPressed;

  const DefaultAppBar({super.key, required this.onSearchPressed});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: NEARColors.blue,
      title: Row(
        children: [
          SvgPicture.asset(
            NearAssets.logoIcon,
            color: NEARColors.white,
          ),
          const SizedBox(width: 15),
          Text(
            'Near Social',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: NEARColors.white),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: onSearchPressed,
          icon: Icon(Icons.search),
        ),
      ],
    );
  }
}

class SearchAppBar extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onCancel;

  const SearchAppBar({
    super.key,
    required this.searchController,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: NEARColors.blue,
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: onCancel,
      ),
      title: TextField(
        controller: searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search users...',
          border: InputBorder.none,
          hintStyle: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(color: NEARColors.white),
        ),
        style: TextStyle(color: NEARColors.white),
      ),
    );
  }
}

class UserChatPageState {
  final bool isSearching;

  UserChatPageState({required this.isSearching});

  UserChatPageState copyWith({bool? isSearching}) {
    return UserChatPageState(
      isSearching: isSearching ?? this.isSearching,
    );
  }

  @override
  String toString() {
    return 'UserChatPageState(isSearching: $isSearching)';
  }
}

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

  bool _isLoading = false;
  DateTime? _lastTimestamp;
  static const int _pageSize = 50;

  @override
  void initState() {
    super.initState();
    _setupInitialStream();
    _scrollController.addListener(_onScroll);
  }

  void _setupInitialStream() async {
    // Get current timestamp for initial query
    _lastTimestamp = DateTime.now();

    chatSubscription = Supabase.instance.client
        .from('Chat')
        .stream(primaryKey: ['id'])
        .lte('updated_at', _lastTimestamp!.toIso8601String())
        .order('updated_at', ascending: false)
        .limit(_pageSize)
        .listen(_handleStreamData);
  }

  void _handleStreamData(List<Map<String, dynamic>> listOfChats) {
    if (!mounted) return;

    print(listOfChats);

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
          final chatTimestamp = DateTime.parse(newChat['updated_at']);
          if (_lastTimestamp == null ||
              chatTimestamp.isBefore(_lastTimestamp!)) {
            _chats.add(newChat);
          }
        }
      }

      // Remove chats that no longer exist in the stream
      _chats.removeWhere((chat) =>
          !listOfChats.any((streamChat) => streamChat['id'] == chat['id']) &&
          DateTime.parse(chat['updated_at']).isAfter(_lastTimestamp!));

      // Sort chats by updated_at
      _chats.sort((a, b) => DateTime.parse(b['updated_at'])
          .compareTo(DateTime.parse(a['updated_at'])));
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreChats();
    }
  }

  Future<void> _loadMoreChats() async {
    if (_isLoading || _lastTimestamp == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get the timestamp of the last chat in our current list
      if (_chats.isNotEmpty) {
        final lastChat = _chats.last;
        _lastTimestamp = DateTime.parse(lastChat['updated_at']);
      }

      // Cancel existing subscription
      await chatSubscription?.cancel();

      // Set up new stream with updated timestamp
      chatSubscription = Supabase.instance.client
          .from('Chat')
          .stream(primaryKey: ['id'])
          .lte('updated_at', _lastTimestamp!.toIso8601String())
          .order('updated_at', ascending: false)
          .limit(_pageSize)
          .listen(_handleStreamData);
    } catch (e) {
      print('Error loading more chats: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
    final screenWidth = MediaQuery.of(context).size.width;

    final dialogWidth = screenWidth > 1200
        ? 400.0
        : screenWidth > 600
            ? screenWidth * 0.3
            : screenWidth * 0.8;

    return ListView.builder(
      controller: _scrollController,
      itemCount: _chats.length + 1,
      itemBuilder: (context, index) {
        if (index == _chats.length) {
          return _isLoading
              ? const Center(child: CircularProgressIndicator())
              : const SizedBox.shrink();
        }

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

                                    setState(() {
                                      _chats.removeAt(index);
                                    });

                                    print("delete chat res : $res");

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

class SearchBody extends StatefulWidget {
  final TextEditingController searchController;

  const SearchBody({super.key, required this.searchController});

  @override
  _SearchBodyState createState() => _SearchBodyState();
}

class _SearchBodyState extends State<SearchBody> {
  final _scrollController = ScrollController();
  final List<Map<String, dynamic>> _users = [];

  String? _lastUserId;
  bool _hasMoreUsers = true;
  bool _isLoading = false;
  String _currentSearchText = '';

  @override
  void initState() {
    super.initState();
    final aiChat = [
      {"id": "AI"},
      {"id": "test.near"}
    ];

    _users.addAll(aiChat);

    // _loadUsers();

    _scrollController.addListener(_onScroll);

    widget.searchController.addListener(_onSearchTextChanged);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadUsers();
    }
  }

  void _onSearchTextChanged() {
    final newSearchText = widget.searchController.text.toLowerCase();

    if (newSearchText != _currentSearchText) {
      setState(() {
        _users.clear();
        _lastUserId = null;
        _hasMoreUsers = true;
        _currentSearchText = newSearchText;
      });
      _loadUsers();
    }
  }

  Future<void> _loadUsers() async {
    if (_isLoading || !_hasMoreUsers) return;

    setState(() {
      _isLoading = true;
    });

    try {
      PostgrestTransformBuilder<List<Map<String, dynamic>>> query;

      if (_currentSearchText.isNotEmpty) {
        query = Supabase.instance.client
            .from('User')
            .select('id')
            .like('id', '%$_currentSearchText%')
            .order('created_at', ascending: false)
            .limit(50);
      } else if (_currentSearchText.isNotEmpty && _lastUserId != null) {
        query = Supabase.instance.client
            .from('User')
            .select('id')
            .like('id', '%$_currentSearchText%')
            .gt('id', _lastUserId!)
            .order('created_at', ascending: false)
            .limit(50);
      } else {
        query = Supabase.instance.client
            .from('User')
            .select('id')
            .order('created_at', ascending: false)
            .limit(50);
      }

      final response = await query;

      setState(() {
        _users.addAll(response);

        if (response.length < 50) {
          _hasMoreUsers = false;
        } else if (response.isNotEmpty) {
          _lastUserId = response.last['id'];
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasMoreUsers = false;
      });
      print('Error loading users: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAccountId = Modular.get<AuthController>().state.accountId;
    final filteredUsers = _currentSearchText.isEmpty
        ? _users.where((user) => user['id'] != currentUserAccountId).toList()
        : _users
            .where(
                (user) => user['id'].toLowerCase().contains(_currentSearchText))
            .where((user) => user['id'] != currentUserAccountId)
            .toList();

    return ListView.builder(
      controller: _scrollController,
      itemCount: filteredUsers.length + (_hasMoreUsers ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == filteredUsers.length) {
          return _isLoading
              ? const Center(child: CircularProgressIndicator())
              : const SizedBox.shrink();
        }

        final user = filteredUsers[index];
        return ListTile(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const ChatTypeSelectionModal(),
            ).then((result) async {
              if (result != null) {
                final chatTypeCreation = result['chatType'] as ChatType;
                final currentUserAccountID =
                    Modular.get<AuthController>().state.accountId;

                final pageController = Modular.get<UserChatsPageController>();

                final res = await pageController.createChat(
                  chatType: chatTypeCreation,
                  currentUserId: currentUserAccountID,
                  otherUserId: user['id'].toString(),
                );

                if (res['result'] == 'ok') {
                  showDialog(
                    context: context,
                    builder: (context) => ChatCreationResultModal(
                      result: 'ok',
                      operationMessage: 'Chat was created successfully.',
                    ),
                  );
                  pageController.pageStateStream.add(
                    pageController.pageStateStream.value.copyWith(
                      isSearching: false,
                    ),
                  );
                } else {
                  print("res $res");

                  final chatData = res['chat_data'];

                  final operationResult = res['operation_message'];
                  print("chatData $chatData");
                  if (chatData != null) {
                    pageController.pageStateStream.add(
                      pageController.pageStateStream.value.copyWith(
                        isSearching: false,
                      ),
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => ChatPage(
                          chat: chatData,
                        ),
                      ),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => ChatCreationResultModal(
                        result: 'error',
                        operationMessage: operationResult,
                      ),
                    );
                    pageController.pageStateStream.add(
                      pageController.pageStateStream.value.copyWith(
                        isSearching: false,
                      ),
                    );
                  }
                }
              }
            });
          },
          leading: CircleAvatar(
            backgroundColor: NEARColors.aqua,
            backgroundImage: user['photo'] != null
                ? AssetImage(user['photo'])
                : AssetImage(
                    NearAssets.standartAvatar,
                  ),
          ),
          title: Text(
            user['name'] ?? 'Near User',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: NEARColors.black),
          ),
          subtitle: Text(
            user['id'],
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: NEARColors.black),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    widget.searchController.removeListener(_onSearchTextChanged);
    super.dispose();
  }
}

class ChatCreationResultModal extends StatelessWidget {
  final String result;
  final String operationMessage;

  const ChatCreationResultModal({
    super.key,
    required this.result,
    required this.operationMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: NEARColors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getTitle(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: NEARColors.black,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            Text(
              operationMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: NEARColors.black,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(100.w, 50.h),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  String _getTitle() {
    if (result == 'ok') {
      return 'Chat Created Successfully';
    } else {
      return 'Chat Creation Failed';
    }
  }
}

class ChatTypeSelectionModal extends StatefulWidget {
  const ChatTypeSelectionModal({super.key});

  @override
  _ChatTypeSelectionModalState createState() => _ChatTypeSelectionModalState();
}

class _ChatTypeSelectionModalState extends State<ChatTypeSelectionModal> {
  int _currentStage = 0;
  ChatType? _selectedChatType;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: NEARColors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getCurrentTitle(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: NEARColors.black,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            _buildCurrentStageContent(),
            SizedBox(height: 20.h),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  String _getCurrentTitle() {
    switch (_currentStage) {
      case 0:
        return 'Choose Chat Type';
      default:
        return 'Create Chat';
    }
  }

  Widget _buildCurrentStageContent() {
    switch (_currentStage) {
      case 0:
        return _buildChatTypeSelection();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildChatTypeSelection() {
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: ChatType.values.map((type) {
        return _buildSelectableCard(
          title: type.label,
          icon: type.icon,
          isSelected: _selectedChatType == type,
          onTap: () {
            setState(() {
              _selectedChatType = type;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildSelectableCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100.w,
        padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 10.w),
        decoration: BoxDecoration(
          color:
              isSelected ? NEARColors.blue.withOpacity(0.2) : NEARColors.white,
          border: Border.all(
            color: isSelected ? NEARColors.blue : NEARColors.grey,
            width: 2.w,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40.sp,
              color: isSelected ? NEARColors.blue : NEARColors.grey,
            ),
            SizedBox(height: 10.h),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected ? NEARColors.blue : NEARColors.black,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: _currentStage == 0
          ? MainAxisAlignment.center
          : MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(100.w, 50.h),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          ),
          onPressed: _canProceed() ? _handleNextOrCreate : null,
          child: Text(_currentStage == 1 ? 'Create Chat' : 'Next'),
        ),
      ],
    );
  }

  bool _canProceed() {
    switch (_currentStage) {
      case 0:
        return _selectedChatType != null;
      default:
        return false;
    }
  }

  void _handleNextOrCreate() {
    if (_currentStage == 0) {
      Navigator.of(context).pop({
        'chatType': _selectedChatType,
      });
    }
  }
}

//Models

enum ChatType {
  publicUserToUser(
    label: 'Public',
    icon: Icons.public,
  ),
  privateUserToUser(
    label: 'Private',
    icon: Icons.lock_outline,
  ),
  ai(
    label: 'AI Chat',
    icon: Icons.smart_toy_outlined,
  );
  // group(
  //   label: 'Group',
  //   icon: Icons.group,
  // ),

  final String label;
  final IconData icon;

  const ChatType({
    required this.label,
    required this.icon,
  });
}

class Chat {
  final String name;
  final String imagePath;
  final bool isPublic;

  Chat({required this.name, required this.imagePath, required this.isPublic});

  Chat copyWith({String? name, String? imagePath, bool? isPublic}) {
    return Chat(
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  @override
  String toString() {
    return 'Chat(name: $name , imagePath :$imagePath , isPublic : $isPublic )';
  }
}

class User {
  final String name;
  final String accountId;
  final String photo;

  User({required this.name, required this.accountId, required this.photo});

  User copyWith({String? name, String? accountId, String? photo}) {
    return User(
      name: name ?? this.name,
      accountId: accountId ?? this.accountId,
      photo: photo ?? this.photo,
    );
  }

  @override
  String toString() {
    return 'Chat(name: $name , accountId :$accountId , photo : $photo )';
  }
}
