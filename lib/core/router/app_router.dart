import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:near_social_mobile/core/exceptions/exceptions.dart';
import 'package:near_social_mobile/core/router/routes.dart';
import 'package:near_social_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:near_social_mobile/features/auth/presentation/ui/start_page.dart';
import 'package:near_social_mobile/features/auth/presentation/ui/qr_scan_screen.dart';
import 'package:near_social_mobile/features/feed/presentation/ui/home_page.dart';
import 'package:near_social_mobile/features/feed/presentation/ui/posts_feed_page.dart';
import 'package:near_social_mobile/features/feed/presentation/ui/post_page.dart';
import 'package:near_social_mobile/features/feed/presentation/ui/smart_feed_page.dart';
import 'package:near_social_mobile/features/feed/presentation/providers/posts_controller.dart';
import 'package:near_social_mobile/features/people/presentation/ui/people_list_page.dart';
import 'package:near_social_mobile/features/people/presentation/ui/user_page.dart';
import 'package:near_social_mobile/features/notifications/presentation/ui/notifications_page.dart';
import 'package:near_social_mobile/features/settings/presentation/ui/home_menu_page.dart';
import 'package:near_social_mobile/features/settings/presentation/ui/settings_page.dart';
import 'package:near_social_mobile/features/settings/presentation/ui/blocked_users_page.dart';
import 'package:near_social_mobile/features/settings/presentation/ui/hidden_posts_users_page.dart';
import 'package:near_social_mobile/features/chat/presentation/ui/chat_room_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.auth,
    redirect: (context, state) {
      final isAuthenticated = authState.accountId.isNotEmpty;
      final isAuthRoute = state.matchedLocation.startsWith(AppRoutes.auth);

      if (!isAuthenticated && !isAuthRoute) {
        return AppRoutes.auth;
      }
      if (isAuthenticated && isAuthRoute) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) => const StartSplashPage(),
        routes: [
          GoRoute(
            path: 'qr-reader',
            builder: (context, state) => const QRReaderScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
        routes: [
          GoRoute(
            path: 'posts-feed',
            builder: (context, state) => const PostsFeedPage(),
          ),
          GoRoute(
            path: 'post',
            builder: (context, state) {
              final postsViewMode = state.extra as PostsViewMode? ?? PostsViewMode.main;
              return PostPage(
                accountId: state.uri.queryParameters['accountId'] ?? '',
                blockHeight: int.tryParse(state.uri.queryParameters['blockHeight'] ?? '') ?? 0,
                postsViewMode: postsViewMode,
                postsOfAccountId: state.uri.queryParameters['postsOfAccountId'],
              );
            },
          ),
          GoRoute(
            path: 'smart-feed',
            builder: (context, state) => const SmartFeedPage(),
          ),
          GoRoute(
            path: 'people',
            builder: (context, state) => const PeopleListPage(),
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => UserPage(
              accountId: state.uri.queryParameters['accountId'] ?? '',
            ),
          ),
          GoRoute(
            path: 'notifications',
            builder: (context, state) => const NotificationsPage(),
          ),
          GoRoute(
            path: 'menu',
            builder: (context, state) => const HomeMenuPage(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: 'blocked-users',
            builder: (context, state) => const BlockedUsersPage(),
          ),
          GoRoute(
            path: 'hidden-posts',
            builder: (context, state) => const HiddenPostsUsersPage(),
          ),
          GoRoute(
            path: 'chat-room',
            builder: (context, state) => ChatRoomPage(
              targetAccountId: state.uri.queryParameters['targetAccountId'] ?? '',
            ),
          ),
        ],
      ),
    ],
  );
});
