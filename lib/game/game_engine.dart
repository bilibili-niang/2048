import 'dart:math';
import '../models/tile.dart';
import '../models/game_state.dart';

enum Direction { up, down, left, right }

class GameEngine {
  late List<List<Tile?>> grid;
  late int gridSize;
  int score = 0;
  int bestScore = 0;
  bool isGameOver = false;
  bool isWin = false;
  bool hasWon = false;

  GameEngine(int gridSize) {
    this.gridSize = gridSize;
    initGrid();
  }

  void initGrid() {
    grid = List.generate(gridSize, (_) => List.filled(gridSize, null));
    score = 0;
    isGameOver = false;
    isWin = false;
    hasWon = false;
    addRandomTile();
    addRandomTile();
  }

  void addRandomTile() {
    List<List<int>> emptyCells = [];
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j] == null) {
          emptyCells.add([i, j]);
        }
      }
    }
    if (emptyCells.isNotEmpty) {
      var random = Random();
      var cell = emptyCells[random.nextInt(emptyCells.length)];
      grid[cell[0]][cell[1]] = Tile(
        value: random.nextDouble() < 0.9 ? 2 : 4,
        row: cell[0],
        col: cell[1],
        isNew: true,
      );
    }
  }

  bool move(Direction direction) {
    resetTileFlags();
    
    bool moved = false;
    switch (direction) {
      case Direction.up:
        moved = moveUp();
        break;
      case Direction.down:
        moved = moveDown();
        break;
      case Direction.left:
        moved = moveLeft();
        break;
      case Direction.right:
        moved = moveRight();
        break;
    }

    if (moved) {
      addRandomTile();
      checkWin();
      checkGameOver();
    }

    return moved;
  }

  void resetTileFlags() {
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j] != null) {
          grid[i][j]!.isNew = false;
          grid[i][j]!.isMerged = false;
        }
      }
    }
  }

  bool moveLeft() {
    bool moved = false;
    for (int i = 0; i < gridSize; i++) {
      List<Tile> row = grid[i].whereType<Tile>().toList();
      List<Tile> merged = [];
      
      int j = 0;
      while (j < row.length) {
        if (j + 1 < row.length && row[j].value == row[j + 1].value) {
          int newValue = row[j].value * 2;
          merged.add(Tile(
            value: newValue,
            row: i,
            col: merged.length,
            isMerged: true,
          ));
          score += newValue;
          j += 2;
        } else {
          merged.add(Tile(
            value: row[j].value,
            row: i,
            col: merged.length,
          ));
          j++;
        }
      }

      for (int k = 0; k < gridSize; k++) {
        Tile? oldTile = grid[i][k];
        Tile? newTile = k < merged.length ? merged[k] : null;
        
        if (oldTile == null && newTile != null) {
          moved = true;
        } else if (oldTile != null && newTile != null) {
          if (oldTile.value != newTile.value || oldTile.col != newTile.col) {
            moved = true;
          }
        }
        
        grid[i][k] = newTile;
      }
    }
    return moved;
  }

  bool moveRight() {
    bool moved = false;
    for (int i = 0; i < gridSize; i++) {
      List<Tile> row = grid[i].whereType<Tile>().toList().reversed.toList();
      List<Tile> merged = [];
      
      int j = 0;
      while (j < row.length) {
        if (j + 1 < row.length && row[j].value == row[j + 1].value) {
          int newValue = row[j].value * 2;
          merged.add(Tile(
            value: newValue,
            row: i,
            col: gridSize - 1 - merged.length,
            isMerged: true,
          ));
          score += newValue;
          j += 2;
        } else {
          merged.add(Tile(
            value: row[j].value,
            row: i,
            col: gridSize - 1 - merged.length,
          ));
          j++;
        }
      }

      for (int k = gridSize - 1; k >= 0; k--) {
        int mergedIndex = gridSize - 1 - k;
        Tile? oldTile = grid[i][k];
        Tile? newTile = mergedIndex < merged.length ? merged[mergedIndex] : null;
        
        if (oldTile == null && newTile != null) {
          moved = true;
        } else if (oldTile != null && newTile != null) {
          if (oldTile.value != newTile.value || oldTile.col != newTile.col) {
            moved = true;
          }
        }
        
        grid[i][k] = newTile;
      }
    }
    return moved;
  }

  bool moveUp() {
    bool moved = false;
    for (int j = 0; j < gridSize; j++) {
      List<Tile> col = [];
      for (int i = 0; i < gridSize; i++) {
        if (grid[i][j] != null) {
          col.add(grid[i][j]!);
        }
      }
      
      List<Tile> merged = [];
      int i = 0;
      while (i < col.length) {
        if (i + 1 < col.length && col[i].value == col[i + 1].value) {
          int newValue = col[i].value * 2;
          merged.add(Tile(
            value: newValue,
            row: merged.length,
            col: j,
            isMerged: true,
          ));
          score += newValue;
          i += 2;
        } else {
          merged.add(Tile(
            value: col[i].value,
            row: merged.length,
            col: j,
          ));
          i++;
        }
      }

      for (int k = 0; k < gridSize; k++) {
        Tile? oldTile = grid[k][j];
        Tile? newTile = k < merged.length ? merged[k] : null;
        
        if (oldTile == null && newTile != null) {
          moved = true;
        } else if (oldTile != null && newTile != null) {
          if (oldTile.value != newTile.value || oldTile.row != newTile.row) {
            moved = true;
          }
        }
        
        grid[k][j] = newTile;
      }
    }
    return moved;
  }

  bool moveDown() {
    bool moved = false;
    for (int j = 0; j < gridSize; j++) {
      List<Tile> col = [];
      for (int i = gridSize - 1; i >= 0; i--) {
        if (grid[i][j] != null) {
          col.add(grid[i][j]!);
        }
      }
      
      List<Tile> merged = [];
      int i = 0;
      while (i < col.length) {
        if (i + 1 < col.length && col[i].value == col[i + 1].value) {
          int newValue = col[i].value * 2;
          merged.add(Tile(
            value: newValue,
            row: gridSize - 1 - merged.length,
            col: j,
            isMerged: true,
          ));
          score += newValue;
          i += 2;
        } else {
          merged.add(Tile(
            value: col[i].value,
            row: gridSize - 1 - merged.length,
            col: j,
          ));
          i++;
        }
      }

      for (int k = gridSize - 1; k >= 0; k--) {
        int mergedIndex = gridSize - 1 - k;
        Tile? oldTile = grid[k][j];
        Tile? newTile = mergedIndex < merged.length ? merged[mergedIndex] : null;
        
        if (oldTile == null && newTile != null) {
          moved = true;
        } else if (oldTile != null && newTile != null) {
          if (oldTile.value != newTile.value || oldTile.row != newTile.row) {
            moved = true;
          }
        }
        
        grid[k][j] = newTile;
      }
    }
    return moved;
  }

  void checkWin() {
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j]?.value == 2048) {
          isWin = true;
          hasWon = true;
          return;
        }
      }
    }
  }

  void checkGameOver() {
    if (hasEmptyCells()) {
      isGameOver = false;
      return;
    }

    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        int value = grid[i][j]!.value;
        if (j < gridSize - 1 && grid[i][j + 1]?.value == value) {
          isGameOver = false;
          return;
        }
        if (i < gridSize - 1 && grid[i + 1][j]?.value == value) {
          isGameOver = false;
          return;
        }
      }
    }

    isGameOver = true;
  }

  bool hasEmptyCells() {
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j] == null) {
          return true;
        }
      }
    }
    return false;
  }

  void reset() {
    initGrid();
  }

  void setGridSize(int size) {
    gridSize = size;
    initGrid();
  }

  GameState toGameState() {
    return GameState(
      grid: grid.map((row) => List.from(row)).toList(),
      score: score,
      bestScore: bestScore,
      gridSize: gridSize,
      isGameOver: isGameOver,
      isWin: isWin,
      hasWon: hasWon,
    );
  }

  void fromGameState(GameState state) {
    grid = state.grid.map((row) => List.from(row)).toList();
    score = state.score;
    bestScore = state.bestScore;
    gridSize = state.gridSize;
    isGameOver = state.isGameOver;
    isWin = state.isWin;
    hasWon = state.hasWon;
  }
}