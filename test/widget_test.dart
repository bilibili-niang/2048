import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:game2048/main.dart';

void main() {
  testWidgets('home screen disables continue without snapshot', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('2048'), findsAtLeastNWidgets(1));
    expect(find.text('新游戏'), findsOneWidget);
    expect(find.text('暂无可继续对局'), findsOneWidget);
    expect(find.text('历史记录'), findsOneWidget);
  });

  testWidgets('home screen enables continue with snapshot', (tester) async {
    SharedPreferences.setMockInitialValues({
      'active_game_exists': true,
      'active_game_state': '''
{
  "historyId": "t-1",
  "startAt": "2026-05-12T10:00:00+08:00",
  "gridSize": 5,
  "targetTile": 4096,
  "score": 320,
  "bestScore": 640,
  "hasWon": false,
  "isGameOver": false,
  "steps": 27,
  "updatedAt": "2026-05-12T10:05:00+08:00",
  "grid": [[0,2,0,0,0],[0,0,4,0,0],[0,0,0,8,0],[0,0,0,0,0],[0,0,0,0,0]]
}
''',
    });

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('继续游戏'), findsOneWidget);
    expect(find.textContaining('上次对局'), findsOneWidget);
    expect(find.textContaining('网格：5x5'), findsOneWidget);
  });
}
