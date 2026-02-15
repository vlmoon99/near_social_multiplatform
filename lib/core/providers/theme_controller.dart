import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_controller.g.dart';

const _themeKey = 'app_theme_mode';

@Riverpod(keepAlive: true)
class ThemeController extends _$ThemeController {
  @override
  ThemeMode build() {
    _loadSaved();
    return ThemeMode.system;
  }

  Future<void> _loadSaved() async {
    const storage = FlutterSecureStorage();
    final saved = await storage.read(key: _themeKey);
    if (saved != null) {
      state = ThemeMode.values.firstWhere(
        (m) => m.name == saved,
        orElse: () => ThemeMode.system,
      );
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    const storage = FlutterSecureStorage();
    await storage.write(key: _themeKey, value: mode.name);
  }
}
