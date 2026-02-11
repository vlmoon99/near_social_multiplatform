import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:near_social_mobile/core/config/theme.dart';
import 'package:near_social_mobile/features/feed/presentation/ui/widgets/post_card.dart';
import 'package:near_social_mobile/features/feed/presentation/providers/posts_controller.dart';

class SmartFeedPage extends ConsumerStatefulWidget {
  const SmartFeedPage({super.key});

  @override
  ConsumerState<SmartFeedPage> createState() => _SmartFeedPageState();
}

class _SmartFeedPageState extends ConsumerState<SmartFeedPage> {
  final PageController pageController = PageController();
  final ValueNotifier<int> currentPage = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(postsControllerProvider.notifier).loadPosts(postsViewMode: PostsViewMode.main);
    });
  }

  @override
  Widget build(BuildContext context) {
    final postsState = ref.watch(postsControllerProvider);
    final postsController = ref.read(postsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Smart Feed',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: NEARColors.white),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: NEARColors.blue,
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF0F9FF),
                Color(0xFFF8F9FF),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: LayoutBuilder(builder: (_, constraints) {
            if (postsState.status == PostLoadingStatus.initial ||
                postsState.posts.isEmpty) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }
            final posts = postsState.posts;
            return Stack(
              children: [
                PageView.builder(
                  controller: pageController,
                  scrollBehavior: const ScrollBehavior()
                      .copyWith(scrollbars: false, dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.stylus,
                    PointerDeviceKind.trackpad,
                  }),
                  scrollDirection: Axis.vertical,
                  itemBuilder: (_, index) {
                    final post = posts[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        top: 10.w,
                        right: 20.w,
                        left: 20.w,
                        bottom: 10.w,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            PostCard(
                              post: post,
                              postsViewMode: PostsViewMode.main,
                              maxContentHeight:
                                  constraints.maxHeight * 0.55,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  onPageChanged: (value) {
                    currentPage.value = value;
                    if (value ==
                            (postsState.posts.length * 2 / 3)
                                .round() &&
                        postsState.status !=
                            PostLoadingStatus.loadingMorePosts) {
                      postsController.loadMorePosts(
                          postsViewMode: PostsViewMode.main);
                    }
                  },
                  itemCount: posts.length,
                ),
              ],
            );
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          throw Exception(
            "Feature in development",
          );
        },
        child: SvgPicture.asset(
          "assets/media/icons/feather-icon.svg",
          height: 24,
          color: NEARColors.white,
        ),
      ),
    );
  }
}
