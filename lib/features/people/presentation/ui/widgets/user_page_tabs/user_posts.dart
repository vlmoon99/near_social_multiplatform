import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_social_mobile/features/feed/data/models/post.dart';
import 'package:near_social_mobile/features/feed/presentation/ui/widgets/post_card.dart';
import 'package:near_social_mobile/features/feed/presentation/providers/posts_controller.dart';
import 'package:near_social_mobile/core/shared_widgets/custom_button.dart';
import 'package:near_social_mobile/core/shared_widgets/spinner_loading_indicator.dart';

class UserPostsView extends ConsumerStatefulWidget {
  const UserPostsView({
    super.key,
    required this.accountIdOfUser,
  });

  final String accountIdOfUser;

  @override
  ConsumerState<UserPostsView> createState() => _UserPostsViewState();
}

class _UserPostsViewState extends ConsumerState<UserPostsView> {
  final ValueNotifier<bool> loadingMorePosts = ValueNotifier<bool>(false);
  final ValueNotifier<bool> allPostsLoaded = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    final postsState = ref.watch(postsControllerProvider);
    if (postsState.postsOfAccounts[widget.accountIdOfUser] == null) {
      return const Center(child: SpinnerLoadingIndicator());
    }
    final List<Post> posts =
        postsState.postsOfAccounts[widget.accountIdOfUser]!;
    if (posts.isEmpty) {
      return Center(child: Text("people.no_posts".tr()));
    }
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20).r,
      itemBuilder: (context, index) {
        if (index == posts.length) {
          return AnimatedBuilder(
            animation: Listenable.merge([
              loadingMorePosts,
              allPostsLoaded,
            ]),
            builder: (context, _) {
              if (loadingMorePosts.value) {
                return const Center(child: SpinnerLoadingIndicator());
              } else {
                return CustomButton(
                  primary: true,
                  onPressed: allPostsLoaded.value
                      ? null
                      : () async {
                          try {
                            loadingMorePosts.value = true;
                            final posts =
                                await ref.read(postsControllerProvider.notifier)
                                    .loadMorePosts(
                              postsOfAccountId: widget.accountIdOfUser,
                              postsViewMode: PostsViewMode.account,
                            );
                            if (posts.isEmpty) {
                              allPostsLoaded.value = true;
                            }
                          } catch (err) {
                            rethrow;
                          } finally {
                            if (mounted) {
                              loadingMorePosts.value = false;
                            }
                          }
                        },
                  child: Text(
                    allPostsLoaded.value
                        ? "No more posts"
                        : "Load more posts",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
            },
          );
        }
        return PostCard(
          post: posts[index],
          postsViewMode: PostsViewMode.account,
          postsOfAccountId: widget.accountIdOfUser,
          allowToNavigateToPostAuthorPage:
              posts[index].authorInfo.accountId != widget.accountIdOfUser,
          allowToNavigateToReposterAuthorPage:
              posts[index].reposterInfo?.accountInfo.accountId !=
                  widget.accountIdOfUser,
        );
      },
      itemCount: posts.length + 1,
    );
  }
}
