import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { system, light, dark }

class ThemeProvider extends ChangeNotifier {
  AppThemeMode _themeMode = AppThemeMode.system;

  AppThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    switch (_themeMode) {
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.light:
        return false;
      case AppThemeMode.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
    }
  }

  ThemeProvider() {
    _loadTheme();
    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged =
        () {
      if (_themeMode == AppThemeMode.system) {
        notifyListeners();
      }
    };
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = prefs.getString('theme_mode');
    if (modeString != null) {
      try {
        _themeMode = AppThemeMode.values.byName(modeString);
      } catch (_) {
        _themeMode = AppThemeMode.system;
      }
    } else {
      final darkMode = prefs.getBool('dark_mode') ?? false;
      _themeMode = darkMode ? AppThemeMode.dark : AppThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.name);
  }

  @Deprecated('Use setThemeMode instead')
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == AppThemeMode.dark
        ? AppThemeMode.light
        : AppThemeMode.dark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', _themeMode.name);
  }

  @Deprecated('Use setThemeMode instead')
  Future<void> setDarkMode(bool value) async {
    _themeMode = value ? AppThemeMode.dark : AppThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', _themeMode.name);
  }
}
