import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:near_social_mobile/config/constants.dart';
import 'package:near_social_mobile/config/theme.dart';
import 'package:rxdart/rxdart.dart';

import 'package:flutter_svg/flutter_svg.dart';

//Pages //
class UserChatsPage extends StatefulWidget {
  const UserChatsPage({super.key});

  @override
  State<UserChatsPage> createState() => _UserChatsPageState();
}

class _UserChatsPageState extends State<UserChatsPage> {
  final BehaviorSubject<UserChatPageState> pageStateStream =
      BehaviorSubject<UserChatPageState>()
        ..add(
          UserChatPageState(isSearching: false),
        );

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
    pageStateStream.close();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserChatPageState>(
      stream: pageStateStream,
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
                        pageStateStream.add(state.copyWith(isSearching: false));
                      },
                    )
                  : DefaultAppBar(
                      key: ValueKey('defaultAppBar'),
                      onSearchPressed: () {
                        pageStateStream.add(state.copyWith(isSearching: true));
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
                    users: users,
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

class SearchBody extends StatelessWidget {
  final List<User> users;
  final TextEditingController searchController;

  const SearchBody(
      {super.key, required this.users, required this.searchController});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: searchController,
      builder: (context, value, child) {
        final searchText = searchController.text.toLowerCase();
        final filteredChats = users
            .where((chat) => chat.name.toLowerCase().contains(searchText))
            .toList();

        return ListView.builder(
          itemCount: filteredChats.length,
          itemBuilder: (context, index) {
            final chat = filteredChats[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage(chat.photo),
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
            );
          },
        );
      },
    );
  }
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
    return 'Chat(name: $name ,imagePath :$imagePath ,isPublic : $isPublic )';
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
    return 'Chat(name: $name ,accountId :$accountId ,photo : $photo )';
  }
}
