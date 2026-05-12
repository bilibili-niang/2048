import 'package:game2048/config/game_rules.dart';

int getTargetTile(int gridSize) {
  return GameRules.targetTileByGridSize[gridSize] ?? 2048;
}
