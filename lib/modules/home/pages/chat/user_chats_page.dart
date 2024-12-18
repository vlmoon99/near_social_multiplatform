import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:near_social_mobile/config/constants.dart';
import 'package:near_social_mobile/config/theme.dart';
import 'package:rxdart/rxdart.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//VM's
class UserChatsPageController {
  final BehaviorSubject<UserChatPageState> pageStateStream =
      BehaviorSubject<UserChatPageState>()
        ..add(
          UserChatPageState(isSearching: false),
        );
}
//

//Pages //
class UserChatsPage extends StatefulWidget {
  const UserChatsPage({super.key});

  @override
  State<UserChatsPage> createState() => _UserChatsPageState();
}

class _UserChatsPageState extends State<UserChatsPage> {
  // final BehaviorSubject<UserChatPageState> pageStateStream =
  //     BehaviorSubject<UserChatPageState>()
  //       ..add(
  //         UserChatPageState(isSearching: false),
  //       );

  final TextEditingController searchController = TextEditingController();

  List<Chat> chats = [
    Chat(
      name: "John Doe",
      imagePath: "assets/john_doe.jpg",
      isPublic: true,
    ),
    Chat(
      name: "Jane Smith",
      imagePath: "assets/jane_smith.jpg",
      isPublic: false,
    ),
    Chat(
      name: "Robert Brown",
      imagePath: "assets/robert_brown.jpg",
      isPublic: true,
    ),
    Chat(
      name: "Emily Davis",
      imagePath: "assets/emily_davis.jpg",
      isPublic: false,
    ),
  ];

  List<User> users = [
    User(
      name: "Vladyslav Mykolaienko",
      accountId: "vlmoon.near",
      photo: "John Doe",
    ),
    User(
      name: "Illie Polosuhin",
      accountId: "root.near",
      photo: "John Doe",
    ),
    User(
      name: "Vlad Frolov",
      accountId: "frol.near",
      photo: "John Doe",
    ),
  ];

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
        print("state ${state.toString()}");
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
                    // users: users,
                    searchController: searchController,
                  )
                : ChatListBody(
                    key: ValueKey('chatListBody'),
                    chats: chats,
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

class ChatListBody extends StatelessWidget {
  final List<Chat> chats;

  const ChatListBody({super.key, required this.chats});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        return ListTile(
          onTap: () {},
          leading: CircleAvatar(
            backgroundImage: AssetImage(chat.imagePath),
          ),
          title: Text(
            chat.name,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: NEARColors.black),
          ),
          subtitle: Text(
            "near addres",
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: NEARColors.black),
          ),
          trailing: Icon(
            chat.isPublic ? Icons.lock_open : Icons.security,
            color: chat.isPublic ? NEARColors.green : NEARColors.red,
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

    // Initial load of users
    _loadUsers();

    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);

    // Add listener to search controller
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

    // If search text has changed, reset pagination
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
    // Prevent multiple simultaneous loads
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
    final filteredUsers = _currentSearchText.isEmpty
        ? _users
        : _users
            .where(
                (user) => user['id'].toLowerCase().contains(_currentSearchText))
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
            ).then((result) {
              if (result != null) {
                final chatTypeCreation = result['chatType'] as ChatType;
                switch (chatTypeCreation) {
                  case ChatType.publicUserToUser:
                    print("ChatType.publicUserToUser");
                    break;
                  case ChatType.privateUserToUser:
                    print("ChatType.privateUserToUser");
                    break;
                  case ChatType.group:
                    print("ChatType.group");
                    break;
                  case ChatType.ai:
                    print("ChatType.ai");
                    break;
                  default:
                    print("No deafult statement");
                }
                final pageController = Modular.get<UserChatsPageController>();
                pageController.pageStateStream.add(
                  pageController.pageStateStream.value.copyWith(
                    isSearching: false,
                  ),
                );
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

enum ChatType {
  publicUserToUser(
    label: 'Public',
    icon: Icons.public,
  ),
  privateUserToUser(
    label: 'Private',
    icon: Icons.lock_outline,
  ),
  group(
    label: 'Group',
    icon: Icons.group,
  ),
  ai(
    label: 'AI Chat',
    icon: Icons.smart_toy_outlined,
  );

  final String label;
  final IconData icon;

  const ChatType({
    required this.label,
    required this.icon,
  });
}

//Models
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
