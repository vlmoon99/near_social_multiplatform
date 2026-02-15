import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:near_social_mobile/features/feed/presentation/ui/widgets/post_card.dart';
import 'package:near_social_mobile/features/feed/presentation/providers/posts_controller.dart';
import 'package:near_social_mobile/core/providers/filter_controller.dart';
import 'package:near_social_mobile/core/models/filters.dart';
import 'package:near_social_mobile/core/shared_widgets/spinner_loading_indicator.dart';

/// Standard page snap but with lower velocity threshold so less swipe force is needed.
class _EasySwipePhysics extends PageScrollPhysics {
  const _EasySwipePhysics({super.parent});

  @override
  _EasySwipePhysics applyTo(ScrollPhysics? ancestor) {
    return _EasySwipePhysics(parent: buildParent(ancestor));
  }

  @override
  double get minFlingVelocity => 100;

  double get minPageTurnDistance => 0.15;
}

class PostsFeedPage extends ConsumerStatefulWidget {
  const PostsFeedPage({super.key, this.onScroll});

  final VoidCallback? onScroll;

  @override
  ConsumerState<PostsFeedPage> createState() => _PostsFeedPageState();
}

class _PostsFeedPageState extends ConsumerState<PostsFeedPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _pageController = PageController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final filterController = ref.read(filterControllerProvider.notifier);
      final filterState = ref.read(filterControllerProvider);
      if (filterState.status == FilterLoadStatus.initial) {
        filterController.loadFilters();
      }
      final postsController = ref.read(postsControllerProvider.notifier);
      final postsStatus = ref.read(postsControllerProvider).status;
      if (postsStatus == PostLoadingStatus.initial) {
        postsController.loadPosts(postsViewMode: PostsViewMode.main);
      }
      if (postsStatus == PostLoadingStatus.loaded) {
        postsController.checkPostsForFullLoadAndLoadIfNecessary(
          postsViewMode: PostsViewMode.main,
          filters: filterState,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final filterState = ref.watch(filterControllerProvider);
    final filterUtil = FiltersUtil(filters: filterState);
    final postsController = ref.read(postsControllerProvider.notifier);
    final status = ref.watch(postsControllerProvider.select((s) => s.status));
    final posts = ref.watch(postsControllerProvider.select(
      (s) => s.posts
          .where((post) => !filterUtil.postIsHided(
              post.authorInfo.accountId, post.blockHeight))
          .toList(),
    ));

    if (status == PostLoadingStatus.loaded ||
        status == PostLoadingStatus.loadingMorePosts) {
      if (posts.isEmpty &&
          status == PostLoadingStatus.loaded) {
        postsController.loadMorePosts(
            postsViewMode: PostsViewMode.main,
            filters: filterState);
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          return ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(
              scrollbars: false,
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.stylus,
                PointerDeviceKind.trackpad,
              },
            ),
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              physics: const _EasySwipePhysics(),
              onPageChanged: (index) {
                widget.onScroll?.call();
                // Load more posts when reaching 2/3 of the list
                if (index >= (posts.length * 2 / 3).round() &&
                    status !=
                        PostLoadingStatus.loadingMorePosts) {
                  postsController.loadMorePosts(
                    postsViewMode: PostsViewMode.main,
                    filters: filterState,
                  );
                }
              },
              itemCount: posts.length + 1, // +1 for loading indicator at end
              itemBuilder: (context, index) {
                if (index == posts.length) {
                  // Loading indicator / end of list
                  if (status ==
                      PostLoadingStatus.loadingMorePosts) {
                    return const Center(child: SpinnerLoadingIndicator());
                  }
                  return const SizedBox.shrink();
                }

                final post = posts[index];
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: PostCard(
                        post: post,
                        postsViewMode: PostsViewMode.main,
                        maxContentHeight: constraints.maxHeight * 0.55,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    }
    return const Center(
      child: SpinnerLoadingIndicator(),
    );
  }
}
