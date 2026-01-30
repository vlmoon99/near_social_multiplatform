import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:near_social_mobile/modules/home/pages/people/widgets/user_tile.dart';
import 'package:near_social_mobile/modules/home/pages/shared_design/glassmorphism_components.dart';
import 'package:near_social_mobile/modules/home/vms/users/models/user_list_state.dart';
import 'package:near_social_mobile/modules/home/vms/users/user_list_controller.dart';
import 'package:near_social_mobile/shared_widgets/spinner_loading_indicator.dart';

class PeopleListPage extends StatefulWidget {
  const PeopleListPage({super.key, this.onScroll});

  final VoidCallback? onScroll;

  @override
  State<PeopleListPage> createState() => _PeopleListPageState();
}

class _PeopleListPageState extends State<PeopleListPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {});
    });
    _scrollController.addListener(() {
      widget.onScroll?.call();
    });
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final UserListController userListController =
          Modular.get<UserListController>();
      if (userListController.state.loadingState == UserListState.initial) {
        userListController.loadUsers();
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final UserListController userListController =
        Modular.get<UserListController>();

    return StreamBuilder<UsersList>(
      stream: userListController.stream,
      builder: (context, snapshot) {
        if (userListController.state.loadingState != UserListState.loaded) {
          return const Center(child: SpinnerLoadingIndicator());
        }

        final users = searchController.text != ""
            ? userListController.state.cachedUsers.entries
                .where(
                  (entry) {
                    return entry.key.contains(
                      RegExp(searchController.text, caseSensitive: false),
                    );
                  },
                )
                .map((e) => e.value)
                .toList()
            : userListController.state.cachedUsers.values.toList();

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 140)),
                SliverToBoxAdapter(
                  child: GlassSearchBar(
                    controller: searchController,
                    isDark: isDark,
                    placeholder: 'Search for people...',
                  ),
                ),
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: UserTile(user: users[index]),
                        );
                      },
                      childCount: users.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 140)),
              ],
            ),
          ),
        );
      },
    );
  }
}
