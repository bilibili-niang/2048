import 'package:flutter/foundation.dart';
import '../game/game_engine.dart';
import '../models/game_state.dart';
import '../services/storage_service.dart';
import '../services/vibration_service.dart';

class GameProvider with ChangeNotifier {
  late GameEngine _engine;
  final StorageService _storageService;
  final VibrationService _vibrationService;
  bool _isWinShown = false;

  GameProvider(this._storageService, this._vibrationService, {int gridSize = 4}) {
    _engine = GameEngine(gridSize);
    _loadBestScore();
  }

  Future<void> _loadBestScore() async {
    _engine.bestScore = await _storageService.getBestScore(_engine.gridSize);
    notifyListeners();
  }

  List<List<Tile?>> get grid => _engine.grid;
  int get score => _engine.score;
  int get bestScore => _engine.bestScore;
  int get gridSize => _engine.gridSize;
  bool get isGameOver => _engine.isGameOver;
  bool get isWin => _engine.isWin;
  bool get hasWon => _engine.hasWon;
  bool get isWinShown => _isWinShown;

  Future<void> move(Direction direction) async {
    bool moved = _engine.move(direction);
    if (moved) {
      if (_engine.isWin && !_isWinShown) {
        _isWinShown = true;
        await _vibrationService.vibrateLong();
      } else if (_engine.isGameOver) {
        await _vibrationService.vibrateLong();
      } else {
        await _vibrationService.vibrateShort();
      }
      
      if (_engine.score > _engine.bestScore) {
        _engine.bestScore = _engine.score;
        await _storageService.saveBestScore(_engine.gridSize, _engine.score);
      }
      
      await _storageService.saveGameState(_engine.toGameState());
      notifyListeners();
    }
  }

  void reset() {
    _engine.reset();
    _isWinShown = false;
    notifyListeners();
  }

  void setGridSize(int size) {
    _engine.setGridSize(size);
    _isWinShown = false;
    _loadBestScore();
  }

  void continueGame() {
    _engine.isWin = false;
    _isWinShown = false;
    notifyListeners();
  }

  Future<void> loadSavedGame() async {
    GameState? state = await _storageService.loadGameState(_engine.gridSize);
    if (state != null) {
      _engine.fromGameState(state);
      _isWinShown = state.isWin;
      notifyListeners();
    }
  }
}