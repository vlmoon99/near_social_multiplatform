import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await initOfApp();

    if (kDebugMode) {
      try {
        FirebaseFirestore.instance.useFirestoreEmulator('localhost', 1111);
        FirebaseFunctions.instance.useFunctionsEmulator('localhost', 2222);
        await FirebaseAuth.instance.useAuthEmulator('localhost', 3333);
      } catch (e) {
        print(e);
      }
    }

    // FlutterError.onError = (FlutterErrorDetails details) {
    //   final catcher = Modular.get<Catcher>();
    //   catcher.exceptionsHandler.add(AppExceptions(
    //     messageForUser: details.exceptionAsString(),
    //     messageForDev: details.exception.runtimeType.toString(),
    //     statusCode: AppErrorCodes.errorFromFlutter,
    //   ));
    // };
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]).then((_) {
      runApp(
        EasyLocalization(
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
        ),
      );
    });
  }, (error, stack) {
    final catcher = Modular.get<Catcher>();
    if (error is AppExceptions) {
      catcher.exceptionsHandler.add(
        error,
      );
    } else {
      final appException = AppExceptions(
        messageForUser:
            ErrorMessageHandler.getErrorMessageForNotFlutterExceptions(error),
        messageForDev: error.toString(),
      );
      catcher.exceptionsHandler.add(
        appException,
      );
    }
  });
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
          title: 'Near Social Mobile',
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
