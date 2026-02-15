import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:near_social_mobile/features/people/presentation/ui/widgets/user_tile.dart';
import 'package:near_social_mobile/core/shared_widgets/glassmorphism_components.dart';
import 'package:near_social_mobile/features/people/data/models/user_list_state.dart';
import 'package:near_social_mobile/features/people/presentation/providers/user_list_controller.dart';
import 'package:near_social_mobile/core/shared_widgets/spinner_loading_indicator.dart';

class PeopleListPage extends ConsumerStatefulWidget {
  const PeopleListPage({super.key, this.onScroll});

  final VoidCallback? onScroll;

  @override
  ConsumerState<PeopleListPage> createState() => _PeopleListPageState();
}

class _PeopleListPageState extends ConsumerState<PeopleListPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
    _scrollController.addListener(() {
      widget.onScroll?.call();
    });
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted && _searchQuery != searchController.text) {
        setState(() {
          _searchQuery = searchController.text;
        });
      }
    });
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final userListController = ref.read(userListControllerProvider.notifier);
      final userListState = ref.read(userListControllerProvider);
      if (userListState.loadingState == UserListState.initial) {
        userListController.loadUsers();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userListState = ref.watch(userListControllerProvider);

    if (userListState.loadingState != UserListState.loaded) {
      return const Center(child: SpinnerLoadingIndicator());
    }

    final query = _searchQuery.toLowerCase();
    final users = query.isEmpty
        ? userListState.cachedUsers.values.toList()
        : userListState.cachedUsers.entries
            .where((entry) => entry.key.toLowerCase().contains(query))
            .map((e) => e.value)
            .toList();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 90)),
            SliverToBoxAdapter(
              child: GlassSearchBar(
                controller: searchController,
                isDark: isDark,
                placeholder: 'Search for people...',
              ),
            ),
            if (users.isEmpty && query.isNotEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.person_2,
                        size: 48,
                        color: isDark ? Colors.white30 : Colors.black26,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "people.no_users_found".tr(),
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: UserTile(
                          key: ValueKey(users[index].generalAccountInfo.accountId),
                          user: users[index],
                        ),
                      );
                    },
                    childCount: users.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 90)),
          ],
        ),
      ),
    );
  }
}
