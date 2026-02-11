import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_social_mobile/core/config/theme.dart';
import 'package:near_social_mobile/core/exceptions/exceptions.dart';
import 'package:near_social_mobile/core/l10n/localizations_strings.dart';
import 'package:near_social_mobile/core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  if (kDebugMode) {
    runApp(
      EasyLocalization(
        supportedLocales: const [Locale('en')],
        path: LocalizationsStrings.localizationPath,
        fallbackLocale: const Locale('en'),
        saveLocale: false,
        child: const ProviderScope(child: NearSocialApp()),
      ),
    );
  } else {
    runZonedGuarded(() {
      FlutterError.onError = (FlutterErrorDetails details) {
        final catcher = Catcher();
        catcher.showDialogForError(details.exception);
      };

      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]).then((_) {
        runApp(
          EasyLocalization(
            supportedLocales: const [Locale('en')],
            path: LocalizationsStrings.localizationPath,
            fallbackLocale: const Locale('en'),
            saveLocale: false,
            child: const ProviderScope(child: NearSocialApp()),
          ),
        );
      });
    }, (error, stack) {
      final catcher = Catcher();
      catcher.showDialogForError(error);
    });
  }
}

class NearSocialApp extends ConsumerWidget {
  const NearSocialApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return ScreenUtilInit(
      builder: (_, __) {
        return MaterialApp.router(
          title: 'Near Social',
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          theme: appTheme,
        );
      },
    );
  }
}
