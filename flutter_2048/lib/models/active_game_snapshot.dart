class ActiveGameSnapshot {
  final String historyId;
  final String startAt;
  final int gridSize;
  final int targetTile;
  final int score;
  final int bestScore;
  final bool hasWon;
  final bool isGameOver;
  final int steps;
  final String updatedAt;
  final List<List<int>> grid;

  const ActiveGameSnapshot({
    required this.historyId,
    required this.startAt,
    required this.gridSize,
    required this.targetTile,
    required this.score,
    required this.bestScore,
    required this.hasWon,
    required this.isGameOver,
    required this.steps,
    required this.updatedAt,
    required this.grid,
  });

  Map<String, dynamic> toJson() {
    return {
      'historyId': historyId,
      'startAt': startAt,
      'gridSize': gridSize,
      'targetTile': targetTile,
      'score': score,
      'bestScore': bestScore,
      'hasWon': hasWon,
      'isGameOver': isGameOver,
      'steps': steps,
      'updatedAt': updatedAt,
      'grid': grid,
    };
  }

  factory ActiveGameSnapshot.fromJson(Map<String, dynamic> json) {
    return ActiveGameSnapshot(
      historyId: json['historyId'] as String? ?? '',
      startAt: json['startAt'] as String? ?? DateTime.now().toIso8601String(),
      gridSize: json['gridSize'] as int? ?? 4,
      targetTile: json['targetTile'] as int? ?? 2048,
      score: json['score'] as int? ?? 0,
      bestScore: json['bestScore'] as int? ?? 0,
      hasWon: json['hasWon'] as bool? ?? false,
      isGameOver: json['isGameOver'] as bool? ?? false,
      steps: json['steps'] as int? ?? 0,
      updatedAt: json['updatedAt'] as String? ?? DateTime.now().toIso8601String(),
      grid: (json['grid'] as List<dynamic>? ?? <dynamic>[])
          .map(
            (row) => (row as List<dynamic>).map((value) => value as int).toList(),
          )
          .toList(),
    );
  }
}
