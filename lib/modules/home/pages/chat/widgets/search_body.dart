import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:near_social_mobile/config/constants.dart';
import 'package:near_social_mobile/config/theme.dart';
import 'package:near_social_mobile/modules/home/pages/chat/chat_page.dart';
import 'package:near_social_mobile/modules/home/pages/chat/user_chats_page.dart';
import 'package:near_social_mobile/modules/home/pages/chat/widgets/chat_creation_result_modal.dart';
import 'package:near_social_mobile/modules/home/pages/chat/widgets/chat_type_selection_modal.dart';
import 'package:near_social_mobile/modules/home/vms/chats/models/chat_model.dart';
import 'package:near_social_mobile/modules/home/vms/chats/user_chats_page_controller.dart';
import 'package:near_social_mobile/modules/vms/core/auth_controller.dart';
import 'package:rxdart/rxdart.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart';

import 'dart:convert';

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

    _loadUsers();

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
