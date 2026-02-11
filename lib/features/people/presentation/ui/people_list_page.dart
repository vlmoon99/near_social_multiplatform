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
      final userListController = ref.read(userListControllerProvider.notifier);
      final userListState = ref.read(userListControllerProvider);
      if (userListState.loadingState == UserListState.initial) {
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
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userListState = ref.watch(userListControllerProvider);

    if (userListState.loadingState != UserListState.loaded) {
      return const Center(child: SpinnerLoadingIndicator());
    }

    final users = searchController.text != ""
        ? userListState.cachedUsers.entries
            .where(
              (entry) {
                return entry.key.contains(
                  RegExp(searchController.text, caseSensitive: false),
                );
              },
            )
            .map((e) => e.value)
            .toList()
        : userListState.cachedUsers.values.toList();

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
            const SliverToBoxAdapter(child: SizedBox(height: 90)),
          ],
        ),
      ),
    );
  }
}
