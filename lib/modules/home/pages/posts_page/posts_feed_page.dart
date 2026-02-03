import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:near_social_mobile/modules/home/pages/posts_page/widgets/post_card.dart';
import 'package:near_social_mobile/modules/home/vms/posts/posts_controller.dart';
import 'package:near_social_mobile/modules/vms/core/filter_controller.dart';
import 'package:near_social_mobile/modules/vms/core/models/filters.dart';
import 'package:near_social_mobile/shared_widgets/spinner_loading_indicator.dart';
import 'package:rxdart/rxdart.dart';

/// Standard page snap but with lower velocity threshold so less swipe force is needed.
class _EasySwipePhysics extends PageScrollPhysics {
  const _EasySwipePhysics({super.parent});

  @override
  _EasySwipePhysics applyTo(ScrollPhysics? ancestor) {
    return _EasySwipePhysics(parent: buildParent(ancestor));
  }

  @override
  double get minFlingVelocity => 100;

  @override
  double get minPageTurnDistance => 0.15;
}

class PostsFeedPage extends StatefulWidget {
  const PostsFeedPage({super.key, this.onScroll});

  final VoidCallback? onScroll;

  @override
  State<PostsFeedPage> createState() => _PostsFeedPageState();
}

class _PostsFeedPageState extends State<PostsFeedPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _pageController = PageController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final FilterController filterController = Modular.get<FilterController>();
      if (filterController.state.status == FilterLoadStatus.initial) {
        filterController.loadFilters();
      }
      final PostsController postsController = Modular.get<PostsController>();
      if (postsController.state.status == PostLoadingStatus.initial) {
        postsController.loadPosts(postsViewMode: PostsViewMode.main);
      }
      if (postsController.state.status == PostLoadingStatus.loaded) {
        postsController.checkPostsForFullLoadAndLoadIfNecessary(
          postsViewMode: PostsViewMode.main,
          filters: filterController.state,
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
    final PostsController postsController = Modular.get<PostsController>();
    final FilterController filterController = Modular.get<FilterController>();

    return StreamBuilder<dynamic>(
      stream: Rx.merge([
        postsController.stream.distinct(
          (previous, next) =>
              previous.posts.length == next.posts.length ||
              previous.status == next.status,
        ),
        filterController.stream
      ]),
      builder: (context, _) {
        final postsState = postsController.state;
        final filterUtil = FiltersUtil(filters: filterController.state);
        final posts = postsState.posts
            .where((post) => !filterUtil.postIsHided(
                post.authorInfo.accountId, post.blockHeight))
            .toList();

        if (postsState.status == PostLoadingStatus.loaded ||
            postsState.status == PostLoadingStatus.loadingMorePosts) {
          if (posts.isEmpty &&
              postsState.status == PostLoadingStatus.loaded) {
            postsController.loadMorePosts(
                postsViewMode: PostsViewMode.main,
                filters: filterController.state);
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
                        postsController.state.status !=
                            PostLoadingStatus.loadingMorePosts) {
                      postsController.loadMorePosts(
                        postsViewMode: PostsViewMode.main,
                        filters: filterController.state,
                      );
                    }
                  },
                  itemCount: posts.length + 1, // +1 for loading indicator at end
                  itemBuilder: (context, index) {
                    if (index == posts.length) {
                      // Loading indicator / end of list
                      if (postsState.status ==
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
      },
    );
  }
}
