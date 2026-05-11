class Level {
  int gridSize;
  String name;
  int bestScore;
  bool isCustom;

  Level({
    required this.gridSize,
    required this.name,
    this.bestScore = 0,
    this.isCustom = false,
  });

  Level copyWith({
    int? gridSize,
    String? name,
    int? bestScore,
    bool? isCustom,
  }) {
    return Level(
      gridSize: gridSize ?? this.gridSize,
      name: name ?? this.name,
      bestScore: bestScore ?? this.bestScore,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  static List<Level> defaultLevels = [
    Level(gridSize: 3, name: '3x3 (简单)'),
    Level(gridSize: 4, name: '4x4 (普通)'),
    Level(gridSize: 5, name: '5x5 (困难)'),
    Level(gridSize: 6, name: '6x6 (专家)'),
  ];
}