class Tile {
  final int row;
  final int col;
  final int value;
  final bool isNew;
  final bool isMerged;

  Tile(this.row, this.col, this.value, {this.isNew = false, this.isMerged = false});

  Tile.empty() : this(0, 0, 0);

  Tile copyWith({int? row, int? col, int? value, bool? isNew, bool? isMerged}) {
    return Tile(
      row ?? this.row,
      col ?? this.col,
      value ?? this.value,
      isNew: isNew ?? this.isNew,
      isMerged: isMerged ?? this.isMerged,
    );
  }

  bool get isEmpty => value == 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tile &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col &&
          value == other.value;

  @override
  int get hashCode => row.hashCode ^ col.hashCode ^ value.hashCode;
}