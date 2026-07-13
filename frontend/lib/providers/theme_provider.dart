import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { system, light, dark }

class ThemeNotifier extends Notifier<AppThemeMode> {
  static const _key = 'theme_mode';

  @override
  AppThemeMode build() {
    Future.microtask(_load);
    return AppThemeMode.system;
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_key);
      if (stored != null) {
        state = AppThemeMode.values.firstWhere(
          (m) => m.name == stored,
          orElse: () => AppThemeMode.system,
        );
      }
    } catch (_) {
      // Si falla la carga de preferencias, usar modo sistema
    }
  }

  Future<void> setMode(AppThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, mode.name);
    } catch (_) {
      // Si falla la persistencia del tema, el cambio igual aplica en sesión
    }
  }

  void toggle(BuildContext context) {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final current = state == AppThemeMode.system
        ? (isDark ? AppThemeMode.dark : AppThemeMode.light)
        : state;
    setMode(current == AppThemeMode.dark ? AppThemeMode.light : AppThemeMode.dark);
  }
}

final themeProvider =
    NotifierProvider<ThemeNotifier, AppThemeMode>(ThemeNotifier.new);

ThemeMode resolveThemeMode(AppThemeMode mode, Brightness platform) {
  return switch (mode) {
    AppThemeMode.system =>
      platform == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };
}
