import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_state.dart';
import 'dart:convert';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  late SharedPreferences _prefs;

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveBestScore(int gridSize, int score) async {
    String key = 'best_score_$gridSize';
    int currentBest = await getBestScore(gridSize);
    if (score > currentBest) {
      await _prefs.setInt(key, score);
    }
  }

  Future<int> getBestScore(int gridSize) async {
    String key = 'best_score_$gridSize';
    return _prefs.getInt(key) ?? 0;
  }

  Future<void> saveGameState(GameState state) async {
    String key = 'game_state_${state.gridSize}';
    String jsonStr = jsonEncode(state.toJson());
    await _prefs.setString(key, jsonStr);
  }

  Future<GameState?> loadGameState(int gridSize) async {
    String key = 'game_state_$gridSize';
    String? jsonStr = _prefs.getString(key);
    if (jsonStr != null) {
      try {
        Map<String, dynamic> jsonMap = jsonDecode(jsonStr);
        return GameState.fromJson(jsonMap);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> deleteGameState(int gridSize) async {
    String key = 'game_state_$gridSize';
    await _prefs.remove(key);
  }

  Future<void> saveThemeMode(String mode) async {
    await _prefs.setString('theme_mode', mode);
  }

  Future<String> getThemeMode() async {
    return _prefs.getString('theme_mode') ?? 'system';
  }

  Future<void> saveVibrationEnabled(bool enabled) async {
    await _prefs.setBool('vibration_enabled', enabled);
  }

  Future<bool> getVibrationEnabled() async {
    return _prefs.getBool('vibration_enabled') ?? true;
  }
}