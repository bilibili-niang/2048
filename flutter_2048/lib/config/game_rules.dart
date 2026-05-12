class GameRules {
  static const int ruleProfileVersion = 1;
  static const int historyLimit = 100;
  static const int tileTwoWeight = 90;
  static const int tileFourWeight = 10;

  static const Map<int, int> targetTileByGridSize = {
    3: 256,
    4: 2048,
    5: 4096,
    6: 8192,
    7: 16384,
    8: 32768,
    9: 65536,
    10: 131072,
  };
}
