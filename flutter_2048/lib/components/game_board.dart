import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:game2048/providers/theme_provider.dart';
import 'package:game2048/components/tile.dart';
import 'package:game2048/models/tile.dart' as model;

class GameBoard extends StatelessWidget {
  final List<List<model.Tile>> grid;
  final int gridSize;

  const GameBoard({super.key, required this.grid, required this.gridSize});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final double boardPadding = 12;
    final double tilePadding = 8;
    final double boardWidth = MediaQuery.of(context).size.width - 32;
    final double tileSize = (boardWidth - boardPadding * 2 - tilePadding * (gridSize - 1)) / gridSize;

    return Container(
      padding: EdgeInsets.all(boardPadding),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? const Color(0xff16213e) : const Color(0xffbbada0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridSize,
          crossAxisSpacing: tilePadding,
          mainAxisSpacing: tilePadding,
        ),
        itemCount: gridSize * gridSize,
        itemBuilder: (context, index) {
          int row = index ~/ gridSize;
          int col = index % gridSize;
          model.Tile tile = grid[row][col];
          return TileWidget(
            tile: tile,
            size: tileSize,
          );
        },
      ),
    );
  }
}