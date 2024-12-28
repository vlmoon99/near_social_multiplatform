import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:near_social_mobile/modules/home/pages/chat/widgets/chat_app_bar.dart';
import 'package:near_social_mobile/modules/home/pages/chat/widgets/chat_list_body.dart';
import 'package:near_social_mobile/modules/home/pages/chat/widgets/search_body.dart';
import 'package:near_social_mobile/modules/home/vms/chats/models/user_chat_page_state.dart';
import 'package:near_social_mobile/modules/home/vms/chats/user_chats_page_controller.dart';

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
