import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_social_mobile/modules/home/pages/posts_page/widgets/post_card.dart';
import 'package:near_social_mobile/modules/home/vms/posts/posts_controller.dart';
import 'package:near_social_mobile/modules/vms/core/filter_controller.dart';
import 'package:near_social_mobile/modules/vms/core/models/filters.dart';
import 'package:near_social_mobile/shared_widgets/spinner_loading_indicator.dart';
import 'package:rxdart/rxdart.dart';

class PostsFeedPage extends StatefulWidget {
  const PostsFeedPage({super.key, this.onScroll});

  final VoidCallback? onScroll;

  @override
  State<PostsFeedPage> createState() => _PostsFeedPageState();
}

class _PostsFeedPageState extends State<PostsFeedPage> {
  final _scrollController = ScrollController();
  final _postsLoaderDebouncer = StreamController();

  void _onScroll() async {
    widget.onScroll?.call();
    final postsController = Modular.get<PostsController>();
    if (_isBottom &&
        postsController.state.status != PostLoadingStatus.loadingMorePosts) {
      postsController.loadMorePosts(postsViewMode: PostsViewMode.main);
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.8);
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      _postsLoaderDebouncer.add(null);
    });
    _postsLoaderDebouncer.stream
        .debounceTime(const Duration(milliseconds: 300))
        .listen((_) => _onScroll());
  }

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
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _postsLoaderDebouncer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

          return RefreshIndicator.adaptive(
            onRefresh: () async {
              return postsController.loadPosts(
                postsViewMode: PostsViewMode.main,
                filters: filterController.state,
              );
            },
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      WidgetsBinding.instance
                          .addPostFrameCallback((timeStamp) {
                        if (_scrollController.hasClients &&
                            _scrollController.position.maxScrollExtent == 0 &&
                            postsState.status == PostLoadingStatus.loaded) {
                          postsController.loadMorePosts(
                              postsViewMode: PostsViewMode.main,
                              filters: filterController.state);
                        }
                      });
                      return const SizedBox(height: 140);
                    }

                    if (index == posts.length + 1) {
                      return const SizedBox(height: 140);
                    }

                    final post = posts[index - 1];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          PostCard(
                            post: post,
                            postsViewMode: PostsViewMode.main,
                          ),
                          if (postsController.state.status ==
                                  PostLoadingStatus.loadingMorePosts &&
                              index == posts.length) ...[
                            const Center(child: SpinnerLoadingIndicator()),
                          ]
                        ],
                      ),
                    );
                  },
                  itemCount: posts.length + 2, // +2 for top and bottom spacing
                ),
              ),
            ),
          );
        }
        return const Center(
          child: SpinnerLoadingIndicator(),
        );
      },
    );
  }
}
