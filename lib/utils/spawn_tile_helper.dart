import 'dart:math';

import 'package:game2048/config/game_rules.dart';

int generateSpawnTileValue(Random random) {
  return random.nextInt(100) < GameRules.tileTwoWeight ? 2 : 4;
}
