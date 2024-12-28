import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:near_social_mobile/config/theme.dart';
import 'package:near_social_mobile/modules/home/pages/posts_page/widgets/post_card.dart';
import 'package:near_social_mobile/modules/home/vms/posts/posts_controller.dart';

class SmartFeedPage extends StatefulWidget {
  const SmartFeedPage({super.key});

  @override
  State<SmartFeedPage> createState() => _SmartFeedPageState();
}

class _SmartFeedPageState extends State<SmartFeedPage> {
  final PostsController postsController = Modular.get<PostsController>();
  final PageController pageController = PageController();
  final ValueNotifier<int> currentPage = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    postsController.loadPosts(postsViewMode: PostsViewMode.main);
  }

  @override
  Widget build(BuildContext context) {
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
        child: LayoutBuilder(builder: (_, constraints) {
          return StreamBuilder(
              stream: postsController.stream.distinct(
                (previous, next) => previous.posts.length == next.posts.length,
              ),
              builder: (_, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator.adaptive();
                }
                final posts = postsController.state.posts;
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
                                (postsController.state.posts.length * 2 / 3)
                                    .round() &&
                            postsController.state.status !=
                                PostLoadingStatus.loadingMorePosts) {
                          postsController.loadMorePosts(
                              postsViewMode: PostsViewMode.main);
                        }
                      },
                      itemCount: posts.length,
                    ),
                  ],
                );
              });
        }),
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
