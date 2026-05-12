import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:game2048/utils/spawn_tile_helper.dart';
import 'package:game2048/utils/target_tile_helper.dart';

void main() {
  test('target tile matches grid size mapping', () {
    expect(getTargetTile(3), 256);
    expect(getTargetTile(4), 2048);
    expect(getTargetTile(5), 4096);
    expect(getTargetTile(10), 131072);
  });

  test('spawn tile distribution stays near 90/10', () {
    final random = Random(2048);
    var countTwo = 0;
    var countFour = 0;

    for (var index = 0; index < 1000; index++) {
      final value = generateSpawnTileValue(random);
      if (value == 2) {
        countTwo += 1;
      } else if (value == 4) {
        countFour += 1;
      }
    }

    expect(countTwo, inInclusiveRange(850, 950));
    expect(countFour, inInclusiveRange(50, 150));
  });
}
