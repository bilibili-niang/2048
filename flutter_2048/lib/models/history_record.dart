class HistoryRecord {
  final String id;
  final String startAt;
  final String? endAt;
  final int gridSize;
  final int targetTile;
  final int finalScore;
  final int maxTile;
  final bool isTargetReached;
  final String result;
  final int steps;
  final String updatedAt;

  const HistoryRecord({
    required this.id,
    required this.startAt,
    required this.endAt,
    required this.gridSize,
    required this.targetTile,
    required this.finalScore,
    required this.maxTile,
    required this.isTargetReached,
    required this.result,
    required this.steps,
    required this.updatedAt,
  });

  HistoryRecord copyWith({
    String? id,
    String? startAt,
    String? endAt,
    bool clearEndAt = false,
    int? gridSize,
    int? targetTile,
    int? finalScore,
    int? maxTile,
    bool? isTargetReached,
    String? result,
    int? steps,
    String? updatedAt,
  }) {
    return HistoryRecord(
      id: id ?? this.id,
      startAt: startAt ?? this.startAt,
      endAt: clearEndAt ? null : (endAt ?? this.endAt),
      gridSize: gridSize ?? this.gridSize,
      targetTile: targetTile ?? this.targetTile,
      finalScore: finalScore ?? this.finalScore,
      maxTile: maxTile ?? this.maxTile,
      isTargetReached: isTargetReached ?? this.isTargetReached,
      result: result ?? this.result,
      steps: steps ?? this.steps,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startAt': startAt,
      'endAt': endAt,
      'gridSize': gridSize,
      'targetTile': targetTile,
      'finalScore': finalScore,
      'maxTile': maxTile,
      'isTargetReached': isTargetReached,
      'result': result,
      'steps': steps,
      'updatedAt': updatedAt,
    };
  }

  factory HistoryRecord.fromJson(Map<String, dynamic> json) {
    return HistoryRecord(
      id: json['id'] as String? ?? '',
      startAt: json['startAt'] as String? ?? DateTime.now().toIso8601String(),
      endAt: json['endAt'] as String?,
      gridSize: json['gridSize'] as int? ?? 4,
      targetTile: json['targetTile'] as int? ?? 2048,
      finalScore: json['finalScore'] as int? ?? 0,
      maxTile: json['maxTile'] as int? ?? 0,
      isTargetReached: json['isTargetReached'] as bool? ?? false,
      result: json['result'] as String? ?? 'running',
      steps: json['steps'] as int? ?? 0,
      updatedAt: json['updatedAt'] as String? ?? DateTime.now().toIso8601String(),
    );
  }
}
