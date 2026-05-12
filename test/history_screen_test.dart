import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:game2048/providers/game_provider.dart';
import 'package:game2048/providers/theme_provider.dart';
import 'package:game2048/screens/history_screen.dart';

void main() {
  testWidgets('history screen shows summary and filter options', (tester) async {
    SharedPreferences.setMockInitialValues({
      'history_records': '''
[
  {
    "id": "r1",
    "startAt": "2026-05-12T10:00:00+08:00",
    "endAt": "2026-05-12T10:10:00+08:00",
    "gridSize": 4,
    "targetTile": 2048,
    "finalScore": 1200,
    "maxTile": 256,
    "isTargetReached": false,
    "result": "over",
    "steps": 100,
    "updatedAt": "2026-05-12T10:10:00+08:00"
  },
  {
    "id": "r2",
    "startAt": "2026-05-12T11:00:00+08:00",
    "endAt": null,
    "gridSize": 5,
    "targetTile": 4096,
    "finalScore": 900,
    "maxTile": 128,
    "isTargetReached": false,
    "result": "running",
    "steps": 70,
    "updatedAt": "2026-05-12T11:20:00+08:00"
  }
]
''',
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => GameProvider()),
        ],
        child: const MaterialApp(home: HistoryScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('总记录 2'), findsOneWidget);
    expect(find.text('进行中 1'), findsOneWidget);
    expect(find.text('已结束 1'), findsOneWidget);
    expect(find.text('达成目标 0'), findsOneWidget);

    expect(find.text('全部'), findsOneWidget);
    expect(find.text('进行中'), findsOneWidget);
    expect(find.text('已结束'), findsOneWidget);
    expect(find.text('达成目标'), findsOneWidget);
  });
}
