import 'package:flutter/material.dart';
import '../models/tile.dart';
import 'tile.dart';

class GameBoard extends StatelessWidget {
  final List<List<Tile?>> grid;
  final int gridSize;
  final bool isDarkMode;

  const GameBoard({
    super.key,
    required this.grid,
    required this.gridSize,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    double boardSize = MediaQuery.of(context).size.width * 0.9;
    if (boardSize > 400) boardSize = 400;
    
    double tileSize = (boardSize - (gridSize + 1) * 8) / gridSize;
    
    return Container(
      width: boardSize,
      height: boardSize,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xff16213e) : const Color(0xffbbada0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridSize,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: gridSize * gridSize,
        itemBuilder: (context, index) {
          int row = index ~/ gridSize;
          int col = index % gridSize;
          Tile? tile = grid[row][col];
          
          return tile != null
              ? TileWidget(
                  tile: tile,
                  size: tileSize,
                  isDarkMode: isDarkMode,
                )
              : Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xff0f3460) : const Color(0xffcdc1b4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                );
        },
      ),
    );
  }
}