import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:game2048/config/game_rules.dart';
import 'package:game2048/models/active_game_snapshot.dart';
import 'package:game2048/models/history_record.dart';
import 'package:game2048/models/tile.dart';
import 'package:game2048/utils/spawn_tile_helper.dart';
import 'package:game2048/utils/target_tile_helper.dart';

class GameProvider extends ChangeNotifier {
  static const String _activeGameStateKey = 'active_game_state';
  static const String _activeGameExistsKey = 'active_game_exists';
  static const String _historyRecordsKey = 'history_records';
  static const String _gridSizeKey = 'grid_size';
  static const String _vibrationEnabledKey = 'vibration_enabled';
  static const String _ruleProfileVersionKey = 'rule_profile_version';

  final Random _random = Random();

  int _gridSize = 4;
  List<List<Tile>> _grid = [];
  int _score = 0;
  int _bestScore = 0;
  int _steps = 0;
  bool _isGameOver = false;
  bool _isWin = false;
  bool _hasWon = false;
  bool _vibrationEnabled = true;
  bool _isLoading = true;
  bool _hasResumableGame = false;
  String? _currentHistoryId;
  String? _currentStartAt;
  ActiveGameSnapshot? _resumeSnapshot;
  List<HistoryRecord> _historyRecords = [];

  int get gridSize => _gridSize;
  List<List<Tile>> get grid => _grid;
  int get score => _score;
  int get bestScore => _bestScore;
  int get steps => _steps;
  bool get isGameOver => _isGameOver;
  bool get isWin => _isWin;
  bool get hasWon => _hasWon;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get isLoading => _isLoading;
  bool get hasResumableGame => _hasResumableGame;
  int get targetTile => getTargetTile(_gridSize);
  List<HistoryRecord> get historyRecords => List.unmodifiable(_historyRecords);
  ActiveGameSnapshot? get resumableSnapshot => _resumeSnapshot;
  int? get resumableGridSize => _resumeSnapshot?.gridSize;
  int? get resumableScore => _resumeSnapshot?.score;
  int? get resumableSteps => _resumeSnapshot?.steps;
  String? get resumableUpdatedAt => _resumeSnapshot?.updatedAt;
  int get globalBestScore {
    final historyBest = _historyRecords.fold<int>(0, (current, record) {
      return max(current, record.finalScore);
    });
    return max(historyBest, _bestScore);
  }

  GameProvider() {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    _gridSize = prefs.getInt(_gridSizeKey) ?? 4;
    _bestScore = prefs.getInt(_bestScoreKey(_gridSize)) ?? 0;
    _vibrationEnabled = prefs.getBool(_vibrationEnabledKey) ?? true;
    _historyRecords = _loadHistoryRecords(prefs);
    _resumeSnapshot = _loadSnapshot(prefs);
    _hasResumableGame = prefs.getBool(_activeGameExistsKey) ?? false;

    if (_resumeSnapshot != null) {
      _gridSize = _resumeSnapshot!.gridSize;
      _bestScore = _resumeSnapshot!.bestScore;
    } else {
      _grid = _createEmptyGrid(_gridSize);
    }

    await prefs.setInt(_ruleProfileVersionKey, GameRules.ruleProfileVersion);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> startNewGame(int size) async {
    if (_currentHistoryId != null && !_isGameOver && _grid.isNotEmpty) {
      await _archiveCurrentGame('abandoned');
    } else if (_resumeSnapshot != null && _hasResumableGame) {
      await _archiveSnapshot(_resumeSnapshot!, 'abandoned');
    }

    _gridSize = size;
    _bestScore = await _readBestScore(size);
    _currentHistoryId = _newId();
    _currentStartAt = DateTime.now().toIso8601String();
    _resetBoard();
    _createHistoryRecord();
    await _saveBestScore();
    await _saveRunningState();
    notifyListeners();
  }

  Future<bool> resumeSavedGame() async {
    if (_resumeSnapshot == null) {
      return false;
    }

    try {
      _applySnapshot(_resumeSnapshot!);
      _resumeSnapshot = _buildSnapshot();
      _hasResumableGame = !_isGameOver;
      notifyListeners();
      return true;
    } catch (_) {
      await _clearActiveSnapshot();
      _resumeSnapshot = null;
      _hasResumableGame = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> restartCurrentGame() async {
    if (_currentHistoryId != null && _grid.isNotEmpty && !_isGameOver) {
      await _archiveCurrentGame('abandoned');
    }
    _currentHistoryId = _newId();
    _currentStartAt = DateTime.now().toIso8601String();
    _bestScore = await _readBestScore(_gridSize);
    _resetBoard();
    _createHistoryRecord();
    await _saveRunningState();
    notifyListeners();
  }

  bool moveLeft() {
    var moved = false;
    for (var i = 0; i < _gridSize; i++) {
      final row = _grid[i].map((tile) => tile.value).toList();
      final mergeResult = _merge(row);
      final merged = mergeResult.values;
      if (!listEquals(row, merged)) {
        moved = true;
        for (var j = 0; j < _gridSize; j++) {
          _grid[i][j] = Tile(
            i,
            j,
            merged[j],
            isNew: merged[j] != 0 && row[j] == 0,
            isMerged: mergeResult.mergedIndices.contains(j),
          );
        }
      }
    }
    return moved;
  }

  bool moveRight() {
    var moved = false;
    for (var i = 0; i < _gridSize; i++) {
      final row = _grid[i].map((tile) => tile.value).toList().reversed.toList();
      final mergeResult = _merge(row);
      final merged = mergeResult.values.reversed.toList();
      final original = _grid[i].map((tile) => tile.value).toList();
      if (!listEquals(original, merged)) {
        moved = true;
        for (var j = 0; j < _gridSize; j++) {
          final reversedIndex = _gridSize - 1 - j;
          _grid[i][j] = Tile(
            i,
            j,
            merged[j],
            isNew: merged[j] != 0 && original[j] == 0,
            isMerged: mergeResult.mergedIndices.contains(reversedIndex),
          );
        }
      }
    }
    return moved;
  }

  bool moveUp() {
    var moved = false;
    for (var j = 0; j < _gridSize; j++) {
      final col = <int>[];
      for (var i = 0; i < _gridSize; i++) {
        col.add(_grid[i][j].value);
      }
      final mergeResult = _merge(col);
      final merged = mergeResult.values;
      for (var i = 0; i < _gridSize; i++) {
        if (merged[i] != _grid[i][j].value) {
          moved = true;
          _grid[i][j] = Tile(
            i,
            j,
            merged[i],
            isNew: merged[i] != 0 && _grid[i][j].value == 0,
            isMerged: mergeResult.mergedIndices.contains(i),
          );
        }
      }
    }
    return moved;
  }

  bool moveDown() {
    var moved = false;
    for (var j = 0; j < _gridSize; j++) {
      final col = <int>[];
      for (var i = _gridSize - 1; i >= 0; i--) {
        col.add(_grid[i][j].value);
      }
      final mergeResult = _merge(col);
      final merged = mergeResult.values.reversed.toList();
      for (var i = 0; i < _gridSize; i++) {
        if (merged[i] != _grid[i][j].value) {
          moved = true;
          final reversedIndex = _gridSize - 1 - i;
          _grid[i][j] = Tile(
            i,
            j,
            merged[i],
            isNew: merged[i] != 0 && _grid[i][j].value == 0,
            isMerged: mergeResult.mergedIndices.contains(reversedIndex),
          );
        }
      }
    }
    return moved;
  }

  _MergeResult _merge(List<int> values) {
    final compacted = <_CompactedTile>[];
    for (var index = 0; index < values.length; index++) {
      final value = values[index];
      if (value != 0) {
        compacted.add(_CompactedTile(value: value));
      }
    }

    final mergedValues = <int>[];
    final mergedIndices = <int>{};

    var writeIndex = 0;
    var readIndex = 0;
    while (readIndex < compacted.length) {
      var value = compacted[readIndex].value;
      final canMergeNext = readIndex + 1 < compacted.length && compacted[readIndex + 1].value == value;
      if (canMergeNext) {
        value *= 2;
        _score += value;
        mergedIndices.add(writeIndex);
        if (value >= targetTile && !_hasWon) {
          _hasWon = true;
          _isWin = true;
          _vibrateLong();
        } else {
          _vibrateShort();
        }
        readIndex += 2;
      } else {
        readIndex += 1;
      }
      mergedValues.add(value);
      writeIndex += 1;
    }

    while (mergedValues.length < _gridSize) {
      mergedValues.add(0);
    }

    return _MergeResult(values: mergedValues, mergedIndices: mergedIndices);
  }

  Future<void> handleMove(Direction direction) async {
    if (_isGameOver || _grid.isEmpty) {
      return;
    }

    _clearTransientTileFlags();

    var moved = false;
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

    if (!moved) {
      notifyListeners();
      return;
    }

    _steps += 1;
    addRandomTile();
    if (_score > _bestScore) {
      _bestScore = _score;
      await _saveBestScore();
    }
    await _checkGameOver();
    if (!_isGameOver) {
      await _saveRunningState();
    }
    notifyListeners();
  }

  void _clearTransientTileFlags() {
    for (var row = 0; row < _grid.length; row++) {
      for (var col = 0; col < _grid[row].length; col++) {
        final tile = _grid[row][col];
        if (tile.isNew || tile.isMerged) {
          _grid[row][col] = tile.copyWith(isNew: false, isMerged: false);
        }
      }
    }
  }

  Future<void> continueAfterWin() async {
    _isWin = false;
    await _saveRunningState(resultOverride: 'won_continued');
    notifyListeners();
  }

  Future<void> saveCurrentProgress() async {
    if (_grid.isEmpty || _isGameOver) {
      return;
    }
    await _saveRunningState(resultOverride: _hasWon ? 'won_continued' : 'running');
  }

  Future<void> toggleVibration() async {
    _vibrationEnabled = !_vibrationEnabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vibrationEnabledKey, _vibrationEnabled);
  }

  void addRandomTile() {
    final emptyTiles = <Tile>[];
    for (var i = 0; i < _gridSize; i++) {
      for (var j = 0; j < _gridSize; j++) {
        if (_grid[i][j].value == 0) {
          emptyTiles.add(Tile(i, j, 0));
        }
      }
    }

    if (emptyTiles.isEmpty) {
      return;
    }

    final randomTile = emptyTiles[_random.nextInt(emptyTiles.length)];
    final value = generateSpawnTileValue(_random);
    _grid[randomTile.row][randomTile.col] = Tile(
      randomTile.row,
      randomTile.col,
      value,
      isNew: true,
    );
  }

  Future<void> _saveRunningState({String? resultOverride}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_gridSizeKey, _gridSize);

    final snapshot = _buildSnapshot();
    _resumeSnapshot = snapshot;
    _hasResumableGame = !_isGameOver;

    await prefs.setString(_activeGameStateKey, jsonEncode(snapshot.toJson()));
    await prefs.setBool(_activeGameExistsKey, !_isGameOver);

    if (_currentHistoryId != null) {
      _upsertHistoryRecord(
        resultOverride ?? (_hasWon ? 'won_continued' : 'running'),
        isFinal: false,
      );
      await _saveHistoryRecords();
    }
  }

  Future<void> _archiveCurrentGame(String result) async {
    if (_currentHistoryId == null || _grid.isEmpty) {
      return;
    }
    _upsertHistoryRecord(result, isFinal: true);
    await _saveHistoryRecords();
    await _clearActiveSnapshot();
  }

  Future<void> _archiveSnapshot(ActiveGameSnapshot snapshot, String result) async {
    final index = _historyRecords.indexWhere((record) => record.id == snapshot.historyId);
    if (index == -1) {
      return;
    }

    final updatedAt = DateTime.now().toIso8601String();
    _historyRecords[index] = _historyRecords[index].copyWith(
      endAt: updatedAt,
      finalScore: snapshot.score,
      maxTile: _maxTileFromValues(snapshot.grid),
      isTargetReached: snapshot.hasWon,
      result: result,
      steps: snapshot.steps,
      updatedAt: updatedAt,
    );
    _sortAndTrimHistory();
    await _saveHistoryRecords();
    await _clearActiveSnapshot();
  }

  Future<void> _clearActiveSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeGameStateKey);
    await prefs.setBool(_activeGameExistsKey, false);
    _resumeSnapshot = null;
    _hasResumableGame = false;
  }

  void _resetBoard() {
    _grid = _createEmptyGrid(_gridSize);
    _score = 0;
    _steps = 0;
    _isGameOver = false;
    _isWin = false;
    _hasWon = false;
    addRandomTile();
    addRandomTile();
  }

  Future<void> _checkGameOver() async {
    for (var i = 0; i < _gridSize; i++) {
      for (var j = 0; j < _gridSize; j++) {
        if (_grid[i][j].value == 0) {
          return;
        }
        if (i < _gridSize - 1 && _grid[i][j].value == _grid[i + 1][j].value) {
          return;
        }
        if (j < _gridSize - 1 && _grid[i][j].value == _grid[i][j + 1].value) {
          return;
        }
      }
    }

    _isGameOver = true;
    _vibrateLong();
    await _archiveCurrentGame('over');
  }

  void _createHistoryRecord() {
    final now = DateTime.now().toIso8601String();
    final record = HistoryRecord(
      id: _currentHistoryId!,
      startAt: _currentStartAt ?? now,
      endAt: null,
      gridSize: _gridSize,
      targetTile: targetTile,
      finalScore: _score,
      maxTile: maxTile,
      isTargetReached: _hasWon,
      result: 'running',
      steps: _steps,
      updatedAt: now,
    );
    _historyRecords.removeWhere((item) => item.id == record.id);
    _historyRecords.add(record);
    _sortAndTrimHistory();
  }

  void _upsertHistoryRecord(String result, {required bool isFinal}) {
    if (_currentHistoryId == null) {
      return;
    }

    final now = DateTime.now().toIso8601String();
    final index = _historyRecords.indexWhere((record) => record.id == _currentHistoryId);
    if (index == -1) {
      _createHistoryRecord();
      return;
    }

    _historyRecords[index] = _historyRecords[index].copyWith(
      endAt: isFinal ? now : null,
      clearEndAt: !isFinal,
      gridSize: _gridSize,
      targetTile: targetTile,
      finalScore: _score,
      maxTile: maxTile,
      isTargetReached: _hasWon,
      result: result,
      steps: _steps,
      updatedAt: now,
    );
    _sortAndTrimHistory();
  }

  List<HistoryRecord> _loadHistoryRecords(SharedPreferences prefs) {
    final raw = prefs.getString(_historyRecordsKey);
    if (raw == null || raw.isEmpty) {
      return <HistoryRecord>[];
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => HistoryRecord.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return <HistoryRecord>[];
    }
  }

  ActiveGameSnapshot? _loadSnapshot(SharedPreferences prefs) {
    final raw = prefs.getString(_activeGameStateKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      return ActiveGameSnapshot.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveHistoryRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _historyRecords.map((record) => record.toJson()).toList();
    await prefs.setString(_historyRecordsKey, jsonEncode(jsonList));
  }

  Future<int> _readBestScore(int size) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_bestScoreKey(size)) ?? 0;
  }

  Future<void> _saveBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_bestScoreKey(_gridSize), _bestScore);
    await prefs.setInt(_gridSizeKey, _gridSize);
  }

  ActiveGameSnapshot _buildSnapshot() {
    return ActiveGameSnapshot(
      historyId: _currentHistoryId ?? _newId(),
      startAt: _currentStartAt ?? DateTime.now().toIso8601String(),
      gridSize: _gridSize,
      targetTile: targetTile,
      score: _score,
      bestScore: _bestScore,
      hasWon: _hasWon,
      isGameOver: _isGameOver,
      steps: _steps,
      updatedAt: DateTime.now().toIso8601String(),
      grid: _grid.map((row) => row.map((tile) => tile.value).toList()).toList(),
    );
  }

  void _applySnapshot(ActiveGameSnapshot snapshot) {
    _currentHistoryId = snapshot.historyId;
    _currentStartAt = snapshot.startAt;
    _gridSize = snapshot.gridSize;
    _score = snapshot.score;
    _bestScore = snapshot.bestScore;
    _steps = snapshot.steps;
    _hasWon = snapshot.hasWon;
    _isWin = false;
    _isGameOver = snapshot.isGameOver;
    _grid = List.generate(
      snapshot.grid.length,
      (row) => List.generate(
        snapshot.grid[row].length,
        (col) => Tile(row, col, snapshot.grid[row][col]),
      ),
    );
  }

  List<List<Tile>> _createEmptyGrid(int size) {
    return List.generate(size, (row) {
      return List.generate(size, (col) => Tile(row, col, 0));
    });
  }

  void _sortAndTrimHistory() {
    _historyRecords.sort((left, right) {
      final leftValue = left.endAt ?? left.updatedAt;
      final rightValue = right.endAt ?? right.updatedAt;
      return rightValue.compareTo(leftValue);
    });
    if (_historyRecords.length > GameRules.historyLimit) {
      _historyRecords = _historyRecords.take(GameRules.historyLimit).toList();
    }
  }

  int get maxTile {
    var currentMax = 0;
    for (final row in _grid) {
      for (final tile in row) {
        currentMax = max(currentMax, tile.value);
      }
    }
    return currentMax;
  }

  int _maxTileFromValues(List<List<int>> values) {
    var currentMax = 0;
    for (final row in values) {
      for (final value in row) {
        currentMax = max(currentMax, value);
      }
    }
    return currentMax;
  }

  String _bestScoreKey(int size) => 'best_score_$size';

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

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
}

class _MergeResult {
  final List<int> values;
  final Set<int> mergedIndices;

  const _MergeResult({
    required this.values,
    required this.mergedIndices,
  });
}

class _CompactedTile {
  final int value;

  const _CompactedTile({
    required this.value,
  });
}

enum Direction { left, right, up, down }

bool listEquals(List<int> a, List<int> b) {
  if (a.length != b.length) {
    return false;
  }
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}
