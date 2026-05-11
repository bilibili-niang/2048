import 'tile.dart';

class GameState {
  List<List<Tile?>> grid;
  int score;
  int bestScore;
  int gridSize;
  bool isGameOver;
  bool isWin;
  bool hasWon;

  GameState({
    required this.grid,
    required this.score,
    required this.bestScore,
    required this.gridSize,
    this.isGameOver = false,
    this.isWin = false,
    this.hasWon = false,
  });

  GameState copyWith({
    List<List<Tile?>>? grid,
    int? score,
    int? bestScore,
    int? gridSize,
    bool? isGameOver,
    bool? isWin,
    bool? hasWon,
  }) {
    return GameState(
      grid: grid ?? this.grid,
      score: score ?? this.score,
      bestScore: bestScore ?? this.bestScore,
      gridSize: gridSize ?? this.gridSize,
      isGameOver: isGameOver ?? this.isGameOver,
      isWin: isWin ?? this.isWin,
      hasWon: hasWon ?? this.hasWon,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'grid': grid.map((row) => row.map((tile) => tile?.toJson()).toList()).toList(),
      'score': score,
      'bestScore': bestScore,
      'gridSize': gridSize,
      'isGameOver': isGameOver,
      'isWin': isWin,
      'hasWon': hasWon,
    };
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      grid: (json['grid'] as List).map((row) => (row as List).map((tile) => tile != null ? Tile.fromJson(tile) : null).toList()).toList(),
      score: json['score'],
      bestScore: json['bestScore'],
      gridSize: json['gridSize'],
      isGameOver: json['isGameOver'],
      isWin: json['isWin'],
      hasWon: json['hasWon'],
    );
  }
}