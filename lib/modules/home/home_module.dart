import 'package:flutter/foundation.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:near_social_mobile/modules/core_module.dart';
import 'package:near_social_mobile/modules/home/pages/chat/user_chats_page.dart';
import 'package:near_social_mobile/modules/home/pages/home_menu/home_menu_page.dart';
import 'package:near_social_mobile/modules/home/pages/home_menu/subpages/mint_manager/mintbase_module.dart';
import 'package:near_social_mobile/modules/home/pages/home_menu/subpages/mint_manager/vm/mintbase_controller.dart';
import 'package:near_social_mobile/modules/home/pages/settings/sub_pages/blocked_users/blocked_users_page.dart';
import 'package:near_social_mobile/modules/home/pages/settings/sub_pages/hided_posts_users/hidden_posts_users_page.dart';
import 'package:near_social_mobile/modules/home/pages/home_page.dart';
import 'package:near_social_mobile/modules/home/pages/home_menu/subpages/key_manager/key_manager_page.dart';
import 'package:near_social_mobile/modules/home/pages/near_widgets/widget_app_page.dart';
import 'package:near_social_mobile/modules/home/pages/near_widgets/widget_list_page.dart';
import 'package:near_social_mobile/modules/home/pages/notifications/notifications_page.dart';
import 'package:near_social_mobile/modules/home/pages/people/people_list_page.dart';
import 'package:near_social_mobile/modules/home/pages/people/user_page.dart';
import 'package:near_social_mobile/modules/home/pages/posts_page/posts_feed_page.dart';
import 'package:near_social_mobile/modules/home/pages/settings/settings_page.dart';
import 'package:near_social_mobile/modules/home/pages/settings/sub_pages/system_managment/system_managment_page.dart';
import 'package:near_social_mobile/modules/home/pages/smart_feed_page.dart';
import 'package:near_social_mobile/modules/home/vms/chats/chat_page_controller.dart';
import 'package:near_social_mobile/modules/home/vms/chats/user_chats_page_controller.dart';
import 'package:near_social_mobile/modules/home/vms/near_widgets/near_widgets_controller.dart';
import 'package:near_social_mobile/modules/home/vms/notifications/notifications_controller.dart';
import 'package:near_social_mobile/modules/home/vms/posts/posts_controller.dart';
import 'package:near_social_mobile/modules/home/vms/users/user_list_controller.dart';
import 'package:near_social_mobile/modules/vms/core/filter_controller.dart';
import 'package:near_social_mobile/routes/routes.dart';

import 'pages/posts_page/post_page.dart';

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
    i.addSingleton(MintbaseController.new);
    i.addSingleton(UserChatsPageController.new);
    i.addSingleton(ChatPageController.new);
  }

  @override
  void routes(RouteManager r) {
    r.child(
      Routes.home.chatsPage,
      child: (context) => const UserChatsPage(),
    );
    r.child(
      Routes.home.startPage,
      child: (context) => const HomePage(),
      transition: TransitionType.fadeIn,
      children: [
        ChildRoute(
          Routes.home.postsFeed,
          child: (context) => const PostsFeedPage(),
        ),
        ChildRoute(
          Routes.home.widgetsListPage,
          child: (context) => const NearWidgetListPage(),
        ),
        ChildRoute(
          Routes.home.peopleListPage,
          child: (context) => const PeopleListPage(),
        ),
        ChildRoute(
          Routes.home.notificationsPage,
          child: (context) => const NotificationsPage(),
        ),
        ChildRoute(
          Routes.home.homeMenu,
          child: (context) => const HomeMenuPage(),
        )
      ],
    );
    r.child(
      Routes.home.postPage,
      child: (context) => PostPage(
        accountId: r.args.queryParams['accountId'] as String,
        blockHeight: int.parse(r.args.queryParams['blockHeight'] as String),
        postsViewMode: PostsViewMode
            .values[int.parse(r.args.queryParams['postsViewMode'] as String)],
        postsOfAccountId: r.args.queryParams['postsOfAccountId'] ?? "",
        allowToNavigateToPostAuthorPage: bool.tryParse(
                r.args.queryParams['allowToNavigateToPostAuthorPage'] ?? "") ??
            true,
      ),
    );
    r.child(
      Routes.home.widgetPage,
      child: (context) => NearWidget(nearWidgetSetupCredentials: r.args.data),
    );
    r.child(Routes.home.chatsPage, child: (context) => const UserChatsPage());
    r.child(
      Routes.home.userPage,
      child: (context) {
        String accountId = '';
        if (r.args.queryParams['accountId'] == null && kIsWeb) {
          final rawQueryParams = Uri.base.fragment.split('?').last;
          final queryParams = Uri.splitQueryString(rawQueryParams);
          accountId = queryParams['accountId'].toString();
        } else {
          accountId = r.args.queryParams['accountId'].toString();
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
    r.module(Routes.home.mintManager, module: MintbaseModule());
    r.child(Routes.home.smartFeedPage,
        child: (context) => const SmartFeedPage());
    r.child(Routes.home.systemsManagmentPage,
        child: (context) => const SystemsManagmentPage());
  }
}
