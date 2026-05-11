import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  final StorageService _storageService;

  ThemeProvider(this._storageService);

  Future<void> init() async {
    String mode = await _storageService.getThemeMode();
    switch (mode) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  ThemeMode get themeMode => _themeMode;

  ThemeData get themeData {
    return _themeMode == ThemeMode.dark ? _darkTheme : _lightTheme;
  }

  void toggleTheme() {
    switch (_themeMode) {
      case ThemeMode.light:
        _themeMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        _themeMode = ThemeMode.system;
        break;
      case ThemeMode.system:
        _themeMode = ThemeMode.light;
        break;
    }
    _storageService.saveThemeMode(_themeMode.name);
    notifyListeners();
  }

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    _storageService.saveThemeMode(mode.name);
    notifyListeners();
  }

  static final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xfff2b179),
    scaffoldBackgroundColor: const Color(0xfffaf8ef),
    cardColor: const Color(0xffbbada0),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: Color(0xff776e65), fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: Color(0xff776e65), fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: Color(0xff776e65), fontWeight: FontWeight.bold),
    ),
  );

  static final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xff00b4d8),
    scaffoldBackgroundColor: const Color(0xff1a1a2e),
    cardColor: const Color(0xff16213e),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: Color(0xffeaeaea), fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: Color(0xffeaeaea), fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: Color(0xffeaeaea), fontWeight: FontWeight.bold),
    ),
  );
}