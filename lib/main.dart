import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_social_mobile/assets/localizations/localizations_strings.dart';
import 'package:near_social_mobile/config/theme.dart';
import 'package:near_social_mobile/exceptions/exceptions.dart';
import 'package:near_social_mobile/modules/app_module.dart';

import 'config/setup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initOfApp();
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

  // for debug purposes don't catch exceptions
  if (kDebugMode) {
    runApp(app);
  } else {
    runZonedGuarded(() async {
      FlutterError.onError = (FlutterErrorDetails details) {
        final catcher = Modular.get<Catcher>();
        catcher.exceptionsHandler.add(AppExceptions(
          messageForUser: "Something went wrong. Please try again later.",
          messageForDev: details.exception.toString(),
        ));
      };

      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]).then((_) {
        runApp(app);
      });
    }, (error, stack) {
      final catcher = Modular.get<Catcher>();
      catcher.exceptionsHandler.add(
        error is AppExceptions
            ? error
            : AppExceptions(
                messageForUser: 'Something went wrong. Please try again later.',
                messageForDev: error.toString(),
              ),
      );
    });
  }
}

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Modular.setInitialRoute(Routes.home.getModule());
    // ScreenUtil.init(context);
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
