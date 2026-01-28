import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:near_social_mobile/modules/home/pages/smart_home/smart_home_page.dart';
import 'package:near_social_mobile/modules/vms/core/auth_controller.dart';
import 'package:near_social_mobile/modules/vms/core/models/auth_info.dart';
import 'package:near_social_mobile/utils/check_for_jailbreak.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // User ban monitoring removed - was dependent on Supabase
  // In decentralized mode, ban logic should be handled differently
  // (e.g., through smart contract or community moderation)

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (!kIsWeb) {
      checkForJailbreak();
    }
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
