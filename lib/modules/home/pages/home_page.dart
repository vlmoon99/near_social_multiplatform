import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:near_social_mobile/modules/home/pages/smart_home/smart_home_page.dart';
import 'package:near_social_mobile/modules/home/vms/notifications/notifications_controller.dart';
import 'package:near_social_mobile/modules/home/vms/posts/posts_controller.dart';
import 'package:near_social_mobile/modules/vms/core/auth_controller.dart';
import 'package:near_social_mobile/modules/vms/core/filter_controller.dart';
import 'package:near_social_mobile/modules/vms/core/models/auth_info.dart';
import 'package:near_social_mobile/utils/check_for_jailbreak.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final StreamSubscription<List<Map<String, dynamic>>>? userAccountState;

  @override
  void initState() {
    super.initState();
    final supabase = Supabase.instance.client;
    final accountId = Modular.get<AuthController>().state.accountId;

    userAccountState = supabase
        .from('User')
        .stream(primaryKey: ['id'])
        .eq('id', accountId)
        .limit(1)
        .listen((user) async {
          if (user.isNotEmpty) {
            final currentUser = user.first;
            final isUserBanned = currentUser['is_banned'] as bool;
            if (isUserBanned) {
              final authController = Modular.get<AuthController>();
              authController.logout();
              await supabase.auth.signOut();
              Modular.get<NotificationsController>().clear();
              Modular.get<FilterController>().clear();
              Modular.get<PostsController>().clear();
              await Modular.get<FlutterSecureStorage>().deleteAll();
              Modular.to.navigate("/");
            }
          } else {}
        });
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (!kIsWeb) {
      checkForJailbreak();
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
        return SmartHomePage();
      },
    );
  }
}
