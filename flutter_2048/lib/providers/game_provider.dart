import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:game2048/models/tile.dart';

class GameProvider extends ChangeNotifier {
  int _gridSize = 4;
  List<List<Tile>> _grid = [];
  int _score = 0;
  int _bestScore = 0;
  bool _isGameOver = false;
  bool _isWin = false;
  bool _vibrationEnabled = true;

  int get gridSize => _gridSize;
  List<List<Tile>> get grid => _grid;
  int get score => _score;
  int get bestScore => _bestScore;
  bool get isGameOver => _isGameOver;
  bool get isWin => _isWin;
  bool get vibrationEnabled => _vibrationEnabled;

  GameProvider() {
    _loadGame();
  }

  Future<void> _loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    _gridSize = prefs.getInt('grid_size') ?? 4;
    _bestScore = prefs.getInt('best_score_$_gridSize') ?? 0;
    _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
    initGame();
  }

  void initGame() {
    _grid = List.generate(_gridSize, (_) => List.generate(_gridSize, (_) => Tile.empty()));
    _score = 0;
    _isGameOver = false;
    _isWin = false;
    addRandomTile();
    addRandomTile();
    notifyListeners();
  }

  void setGridSize(int size) {
    _gridSize = size;
    _bestScore = 0;
    _saveBestScore();
    initGame();
  }

  void addRandomTile() {
    List<Tile> emptyTiles = [];
    for (int i = 0; i < _gridSize; i++) {
      for (int j = 0; j < _gridSize; j++) {
        if (_grid[i][j].value == 0) {
          emptyTiles.add(Tile(i, j, 0));
        }
      }
    }
    if (emptyTiles.isNotEmpty) {
      final randomTile = emptyTiles[DateTime.now().millisecond % emptyTiles.length];
      _grid[randomTile.row][randomTile.col] = Tile(
        randomTile.row,
        randomTile.col,
        DateTime.now().millisecond % 10 == 0 ? 4 : 2,
        isNew: true,
      );
    }
  }

  bool moveLeft() {
    bool moved = false;
    for (int i = 0; i < _gridSize; i++) {
      List<int> row = _grid[i].map((t) => t.value).toList();
      List<int> merged = _merge(row);
      if (!listEquals(row, merged)) {
        moved = true;
        for (int j = 0; j < _gridSize; j++) {
          _grid[i][j] = Tile(i, j, merged[j], isNew: merged[j] != row[j] && row[j] == 0);
        }
      }
    }
    return moved;
  }

  bool moveRight() {
    bool moved = false;
    for (int i = 0; i < _gridSize; i++) {
      List<int> row = _grid[i].map((t) => t.value).toList().reversed.toList();
      List<int> merged = _merge(row).reversed.toList();
      List<int> original = _grid[i].map((t) => t.value).toList();
      if (!listEquals(original, merged)) {
        moved = true;
        for (int j = 0; j < _gridSize; j++) {
          _grid[i][j] = Tile(i, j, merged[j], isNew: merged[j] != original[j] && original[j] == 0);
        }
      }
    }
    return moved;
  }

  bool moveUp() {
    bool moved = false;
    for (int j = 0; j < _gridSize; j++) {
      List<int> col = [];
      for (int i = 0; i < _gridSize; i++) {
        col.add(_grid[i][j].value);
      }
      List<int> merged = _merge(col);
      for (int i = 0; i < _gridSize; i++) {
        if (merged[i] != _grid[i][j].value) {
          moved = true;
          _grid[i][j] = Tile(i, j, merged[i], isNew: _grid[i][j].value == 0);
        }
      }
    }
    return moved;
  }

  bool moveDown() {
    bool moved = false;
    for (int j = 0; j < _gridSize; j++) {
      List<int> col = [];
      for (int i = _gridSize - 1; i >= 0; i--) {
        col.add(_grid[i][j].value);
      }
      List<int> merged = _merge(col).reversed.toList();
      for (int i = 0; i < _gridSize; i++) {
        if (merged[i] != _grid[i][j].value) {
          moved = true;
          _grid[i][j] = Tile(i, j, merged[i], isNew: _grid[i][j].value == 0);
        }
      }
    }
    return moved;
  }

  List<int> _merge(List<int> list) {
    list = list.where((v) => v != 0).toList();
    for (int i = 0; i < list.length - 1; i++) {
      if (list[i] == list[i + 1]) {
        list[i] *= 2;
        _score += list[i];
        if (list[i] == 2048) {
          _isWin = true;
          _vibrateLong();
        } else {
          _vibrateShort();
        }
        list.removeAt(i + 1);
      }
    }
    while (list.length < _gridSize) {
      list.add(0);
    }
    return list;
  }

  void handleMove(Direction direction) {
    if (_isGameOver) return;
    
    bool moved = false;
    switch (direction) {
      case Direction.left:
        moved = moveLeft();
        break;
      case Direction.right:
        moved = moveRight();
        break;
      case Direction.up:
        moved = moveUp();
        break;
      case Direction.down:
        moved = moveDown();
        break;
    }

    if (moved) {
      addRandomTile();
      if (_score > _bestScore) {
        _bestScore = _score;
        _saveBestScore();
      }
      checkGameOver();
    }
    notifyListeners();
  }

  void checkGameOver() {
    for (int i = 0; i < _gridSize; i++) {
      for (int j = 0; j < _gridSize; j++) {
        if (_grid[i][j].value == 0) return;
        if (i < _gridSize - 1 && _grid[i][j].value == _grid[i + 1][j].value) return;
        if (j < _gridSize - 1 && _grid[i][j].value == _grid[i][j + 1].value) return;
      }
    }
    _isGameOver = true;
    _vibrateLong();
  }

  void _vibrateShort() async {
    if (_vibrationEnabled) {
      try {
        await Vibration.vibrate(duration: 50);
      } catch (_) {}
    }
  }

  void _vibrateLong() async {
    if (_vibrationEnabled) {
      try {
        await Vibration.vibrate(duration: 200);
      } catch (_) {}
    }
  }

  Future<void> _saveBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('best_score_$_gridSize', _bestScore);
    await prefs.setInt('grid_size', _gridSize);
  }

  Future<void> toggleVibration() async {
    _vibrationEnabled = !_vibrationEnabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vibration_enabled', _vibrationEnabled);
  }

  void continueGame() {
    _isWin = false;
    notifyListeners();
  }
}

enum Direction { left, right, up, down }

bool listEquals(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}