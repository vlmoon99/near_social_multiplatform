import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:near_social_mobile/modules/home/pages/chat/user_chats_page.dart';
import 'package:near_social_mobile/modules/home/vms/notifications/notifications_controller.dart';
import 'package:near_social_mobile/modules/home/vms/posts/posts_controller.dart';
import 'package:near_social_mobile/modules/vms/core/auth_controller.dart';
import 'package:near_social_mobile/modules/vms/core/filter_controller.dart';
import 'package:near_social_mobile/modules/vms/core/models/auth_info.dart';
import 'package:near_social_mobile/routes/routes.dart';
import 'package:near_social_mobile/services/notification_subscription_service.dart';
import 'package:near_social_mobile/utils/check_for_jailbreak.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final StreamSubscription<List<Map<String, dynamic>>>? userAccountState;

  @override
  void initState() {
    super.initState();
    Modular.to.navigate(".${Routes.home.postsFeed}");
    final supabase = Supabase.instance.client;
    final accountId = Modular.get<AuthController>().state.accountId;
    print("accountId $accountId");

    userAccountState = supabase
        .from('User')
        .stream(primaryKey: ['id'])
        .eq('id', accountId)
        .limit(1)
        .listen((user) async {
          if (user.isNotEmpty) {
            final currentUser = user.first;
            final isUserBanned = currentUser['is_banned'] as bool;
            print("Current user  $currentUser");
            print("is_banned  $isUserBanned");
            if (isUserBanned) {
              final authController = Modular.get<AuthController>();
              if (!kIsWeb) {
                Modular.get<NotificationSubscriptionService>()
                    .unsubscribeFromNotifications(
                        authController.state.accountId);
              }
              authController.logout();
              await FirebaseAuth.instance.signOut();
              await supabase.auth.signOut();
              Modular.get<NotificationsController>().clear();
              Modular.get<FilterController>().clear();
              Modular.get<PostsController>().clear();
              await Modular.get<FlutterSecureStorage>().deleteAll();
              Modular.to.navigate("/");
            }
          } else {
            print("No DATA");
          }
        });
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (!kIsWeb) {
      checkForJailbreak();
    }
  }

  int currentIndex(String currentRoute) {
    if (currentRoute.contains(Routes.home.postsFeed)) {
      return 0;
    } else if (currentRoute.contains(Routes.home.widgetsListPage)) {
      return 1;
    } else if (currentRoute.contains(Routes.home.peopleListPage)) {
      return 2;
    } else if (currentRoute.contains(Routes.home.notificationsPage)) {
      return 3;
    } else if (currentRoute.contains(Routes.home.homeMenu)) {
      return 4;
    } else {
      return 0;
    }
  }

  @override
  void dispose() {
    super.dispose();
    userAccountState?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Modular.get<AuthController>();
    return StreamBuilder<AuthInfo>(
      stream: authController.stream,
      builder: (context, _) {
        return Scaffold(
          // appBar: AppBar(
          //   title: SvgPicture.asset(NearAssets.logoIcon),
          //   centerTitle: true,
          // ),

          body: UserChatsPage(),

          // bottomNavigationBar: NavigationListener(builder: (_, __) {
          //   return BottomNavigationBar(
          //     backgroundColor: NEARColors.black,
          //     selectedItemColor: Theme.of(context).primaryColor,
          //     unselectedItemColor: NEARColors.white,
          //     type: BottomNavigationBarType.fixed,
          //     currentIndex: currentIndex(Modular.to.path),
          //     landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
          //     items: const [
          //       BottomNavigationBarItem(
          //         backgroundColor: NEARColors.black,
          //         icon: Icon(Icons.feed),
          //         label: "Feed",
          //       ),
          //       BottomNavigationBarItem(
          //         icon: Icon(Icons.widgets),
          //         label: "Widgets",
          //       ),
          //       BottomNavigationBarItem(
          //         icon: Icon(Icons.people),
          //         label: "Users",
          //       ),
          //       BottomNavigationBarItem(
          //         icon: Icon(Icons.notifications),
          //         label: "Alerts",
          //       ),
          //       BottomNavigationBarItem(
          //         icon: Icon(Icons.menu),
          //         label: "Menu",
          //       ),
          //     ],
          //     onTap: (value) {
          //       HapticFeedback.lightImpact();
          //       switch (value) {
          //         case 0:
          //           Modular.to.navigate(".${Routes.home.postsFeed}");
          //           break;
          //         case 1:
          //           Modular.to.navigate(".${Routes.home.widgetsListPage}");
          //           break;
          //         case 2:
          //           Modular.to.navigate(".${Routes.home.peopleListPage}");
          //           break;
          //         case 3:
          //           Modular.to.navigate(".${Routes.home.notificationsPage}");
          //           break;
          //         case 4:
          //           Modular.to.navigate(".${Routes.home.homeMenu}");
          //           break;
          //         default:
          //           Modular.to.navigate(".${Routes.home.postsFeed}");
          //           break;
          //       }
          //     },
          //   );
          // }),
        );
      },
    );
  }
}
