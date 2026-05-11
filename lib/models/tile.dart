class Tile {
  int value;
  int row;
  int col;
  bool isNew;
  bool isMerged;

  Tile({
    required this.value,
    required this.row,
    required this.col,
    this.isNew = false,
    this.isMerged = false,
  });

  Tile copyWith({
    int? value,
    int? row,
    int? col,
    bool? isNew,
    bool? isMerged,
  }) {
    return Tile(
      value: value ?? this.value,
      row: row ?? this.row,
      col: col ?? this.col,
      isNew: isNew ?? this.isNew,
      isMerged: isMerged ?? this.isMerged,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'row': row,
      'col': col,
      'isNew': isNew,
      'isMerged': isMerged,
    };
  }

  factory Tile.fromJson(Map<String, dynamic> json) {
    return Tile(
      value: json['value'],
      row: json['row'],
      col: json['col'],
      isNew: json['isNew'],
      isMerged: json['isMerged'],
    );
  }
}