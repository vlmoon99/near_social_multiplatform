import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_social_mobile/assets/localizations/localizations_strings.dart';
import 'package:near_social_mobile/config/constants.dart';
import 'package:near_social_mobile/config/theme.dart';
import 'package:near_social_mobile/exceptions/exceptions.dart';
import 'package:near_social_mobile/modules/app_module.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/setup.dart';

void main() async {
  await Supabase.initialize(
    url: SystemsManagmentConstans.secondarySystemLink,
    anonKey: SystemsManagmentConstans.secondarySystemAnonKey,
  );

  WidgetsFlutterBinding.ensureInitialized();
  final app = EasyLocalization(
    supportedLocales: const [
      Locale('en'),
    ],
    path: LocalizationsStrings.localizationPath,
    fallbackLocale: const Locale('en'),
    saveLocale: false,
    child: ModularApp(
      module: AppModule(),
      child: const AppWidget(),
    ),
  );

  if (kDebugMode) {
    WidgetsFlutterBinding.ensureInitialized();
    await initOfApp();
    runApp(app);
  } else {
    runZonedGuarded(() async {
      WidgetsFlutterBinding.ensureInitialized();
      await initOfApp();
      FlutterError.onError = (FlutterErrorDetails details) {
        final catcher = Catcher();
        catcher.showDialogForError(details.exception);
      };

      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]).then((_) {
        runApp(app);
      });
    }, (error, stack) {
      final catcher = Catcher();
      catcher.showDialogForError(error);
    });
  }
}

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (_, __) {
        return MaterialApp.router(
          title: 'Near Social Multiplatform',
          debugShowCheckedModeBanner: false,
          routerConfig: Modular.routerConfig,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          theme: appTheme,
        );
      },
    );
  }
}
