import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:near_social_mobile/config/theme.dart';
import 'package:near_social_mobile/exceptions/exceptions.dart';
import 'package:near_social_mobile/modules/home/pages/posts_page/widgets/post_card.dart';
import 'package:near_social_mobile/modules/home/vms/posts/posts_controller.dart';

class SmartPostsPage extends StatefulWidget {
  const SmartPostsPage({super.key});

  @override
  State<SmartPostsPage> createState() => _SmartPostsPageState();
}

class _SmartPostsPageState extends State<SmartPostsPage> {
  final PostsController postsController = Modular.get<PostsController>();
  final PageController pageController = PageController();
  final ValueNotifier<int> currentPage = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(builder: (_, constraints) {
          return StreamBuilder(
              stream: postsController.stream.distinct(
                (previous, next) => previous.posts.length == next.posts.length,
              ),
              builder: (_, snapshot) {
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
                          padding: const EdgeInsets.all(20).r,
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
                    ValueListenableBuilder(
                      valueListenable: currentPage,
                      builder: (context, value, child) {
                        if (kIsWeb &&
                            defaultTargetPlatform != TargetPlatform.android &&
                            defaultTargetPlatform != TargetPlatform.iOS &&
                            value > 0) {
                          return child!;
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20).r,
                          child: NavigationButton(
                            icon: const Icon(
                              Icons.keyboard_arrow_up,
                              color: NEARColors.black,
                            ),
                            onPressed: () {
                              pageController.animateToPage(
                                  currentPage.value - 1,
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut);
                            },
                          ),
                        ),
                      ),
                    ),
                    if (kIsWeb &&
                        defaultTargetPlatform != TargetPlatform.android &&
                        defaultTargetPlatform != TargetPlatform.iOS) ...[
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20).r,
                          child: NavigationButton(
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: NEARColors.black,
                            ),
                            onPressed: () {
                              pageController.animateToPage(
                                  currentPage.value + 1,
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut);
                            },
                          ),
                        ),
                      ),
                    ]
                  ],
                );
              });
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          throw const AppExceptions(
            messageForUser: "Feature in development",
            messageForDev: "Feature in development",
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

class NavigationButton extends StatelessWidget {
  const NavigationButton(
      {super.key, required this.icon, required this.onPressed});
  final Icon icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width < 600 ? 100.w : 50.w,
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
        style: IconButton.styleFrom(
          backgroundColor: NEARColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.0),
            side: const BorderSide(
              color: NEARColors.black,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
