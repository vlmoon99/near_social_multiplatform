import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:near_social_mobile/modules/core_module.dart';
// Chat functionality temporarily disabled for decentralization
// import 'package:near_social_mobile/modules/home/pages/chat/user_chats_page.dart';
// Mintbase removed
import 'package:near_social_mobile/modules/home/pages/settings/sub_pages/blocked_users/blocked_users_page.dart';
import 'package:near_social_mobile/modules/home/pages/settings/sub_pages/hided_posts_users/hidden_posts_users_page.dart';
import 'package:near_social_mobile/modules/home/pages/home_page.dart';
import 'package:near_social_mobile/modules/home/pages/home_menu/subpages/key_manager/key_manager_page.dart';
import 'package:near_social_mobile/modules/home/pages/near_widgets/widget_app_page.dart';
import 'package:near_social_mobile/modules/home/pages/people/user_page.dart';
import 'package:near_social_mobile/modules/home/pages/settings/settings_page.dart';
import 'package:near_social_mobile/modules/home/pages/settings/sub_pages/system_managment/system_managment_page.dart';
// SmartFeed removed
import 'package:near_social_mobile/modules/home/pages/modern_design_test/modern_design_test_page.dart';
// Chat controllers temporarily disabled for decentralization
// import 'package:near_social_mobile/modules/home/vms/chats/chat_page_controller.dart';
// import 'package:near_social_mobile/modules/home/vms/chats/user_chats_page_controller.dart';
import 'package:near_social_mobile/modules/home/vms/blockchain/operation_queue_controller.dart';
import 'package:near_social_mobile/modules/home/vms/near_widgets/near_widgets_controller.dart';
import 'package:near_social_mobile/modules/home/vms/notifications/notifications_controller.dart';
import 'package:near_social_mobile/modules/home/pages/p2p_call/p2p_call_page.dart';
import 'package:near_social_mobile/modules/home/vms/p2p_call/p2p_call_controller.dart';
import 'package:near_social_mobile/modules/home/vms/posts/posts_controller.dart';
import 'package:near_social_mobile/modules/home/vms/users/user_list_controller.dart';
import 'package:near_social_mobile/modules/vms/core/filter_controller.dart';
import 'package:near_social_mobile/routes/routes.dart';

import 'pages/posts_page/post_page.dart';

/// Parses query parameters from web URL fragment for deep linking support.
/// Falls back to provided queryParams if not on web or fragment is missing.
Map<String, String> _parseWebQueryParams(Map<String, String> queryParams) {
  if (!kIsWeb) return queryParams;

  final fragment = Uri.base.fragment;
  if (!fragment.contains('?')) return queryParams;

  final rawQueryParams = fragment.split('?').last;
  final webParams = Uri.splitQueryString(rawQueryParams);

  // Merge web params with route params, preferring route params
  return {...webParams, ...queryParams};
}

class HomeModule extends Module {
  @override
  List<Module> get imports => [
        CoreModule(),
      ];

  @override
  void binds(Injector i) {
    i.addSingleton(PostsController.new);
    i.addSingleton(NearWidgetsController.new);
    i.addSingleton(UserListController.new);
    i.addSingleton(NotificationsController.new);
    i.addSingleton(FilterController.new);
    i.addSingleton(P2PCallController.new);
    i.addSingleton(OperationQueueController.new);
    // Mintbase controller removed
    // Chat controllers temporarily disabled for decentralization
    // i.addSingleton(UserChatsPageController.new);
    // i.addSingleton(ChatPageController.new);
  }

  @override
  void routes(RouteManager r) {
    // Chat route temporarily disabled for decentralization
    // r.child(
    //   Routes.home.chatsPage,
    //   child: (context) => const UserChatsPage(),
    // );
    r.child(
      Routes.home.startPage,
      child: (context) => const HomePage(),
      transition: TransitionType.fadeIn,
    );
    r.child(
      Routes.home.postPage,
      child: (context) {
        final params = _parseWebQueryParams(r.args.queryParams);
        final accountId = params['accountId'];
        final blockHeightStr = params['blockHeight'];
        final postsViewModeStr = params['postsViewMode'];

        // Validate required parameters
        if (accountId == null ||
            accountId.isEmpty ||
            blockHeightStr == null ||
            int.tryParse(blockHeightStr) == null) {
          // Invalid deep link - redirect to home
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Modular.to.navigate(Routes.home.startPage);
          });
          return const SizedBox.shrink();
        }

        final blockHeight = int.parse(blockHeightStr);
        final postsViewModeIndex = int.tryParse(postsViewModeStr ?? '0') ?? 0;
        final postsViewMode = postsViewModeIndex < PostsViewMode.values.length
            ? PostsViewMode.values[postsViewModeIndex]
            : PostsViewMode.temporary;

        return PostPage(
          accountId: accountId,
          blockHeight: blockHeight,
          postsViewMode: postsViewMode,
          postsOfAccountId: params['postsOfAccountId'] ?? '',
          allowToNavigateToPostAuthorPage:
              bool.tryParse(params['allowToNavigateToPostAuthorPage'] ?? '') ??
                  true,
        );
      },
    );
    r.child(
      Routes.home.widgetPage,
      child: (context) {
        // Widget page requires credentials passed via navigation arguments
        // Deep links without data redirect to home (widgets contain sensitive private keys)
        final credentials = r.args.data;
        if (credentials == null || credentials is! NearWidgetSetupCredentials) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Modular.to.navigate(Routes.home.startPage);
          });
          return const SizedBox.shrink();
        }
        return NearWidget(nearWidgetSetupCredentials: credentials);
      },
    );
    // Chat route temporarily disabled for decentralization
    // r.child(Routes.home.chatsPage, child: (context) => const UserChatsPage());
    r.child(
      Routes.home.userPage,
      child: (context) {
        final params = _parseWebQueryParams(r.args.queryParams);
        final accountId = params['accountId'];

        if (accountId == null || accountId.isEmpty) {
          // Invalid deep link - redirect to home
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Modular.to.navigate(Routes.home.startPage);
          });
          return const SizedBox.shrink();
        }
        return UserPage(
          accountId: accountId,
        );
      },
    );
    r.child(Routes.home.keyManagerPage,
        child: (context) => const KeyManagerPage());
    r.child(Routes.home.settingsPage, child: (context) => const SettingsPage());
    r.child(Routes.home.blockedUsersPage,
        child: (context) => const BlockedUsersPage());
    r.child(Routes.home.hiddenPostsPage,
        child: (context) => const HiddenPostsUsersPage());
    // Mintbase and SmartFeed routes removed
    r.child(Routes.home.systemsManagmentPage,
        child: (context) => const SystemsManagmentPage());
    r.child(Routes.home.modernDesignTestPage,
        child: (context) => const ModernDesignTestPage());
    r.child(
      Routes.home.p2pCallPage,
      child: (context) {
        final params = _parseWebQueryParams(r.args.queryParams);
        return P2PCallPage(
          targetAccountId: params['targetAccountId'],
        );
      },
    );
  }
}
