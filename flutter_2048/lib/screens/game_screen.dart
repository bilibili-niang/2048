import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:game2048/providers/game_provider.dart';
import 'package:game2048/providers/theme_provider.dart';
import 'package:game2048/components/game_board.dart';
import 'package:game2048/components/score_board.dart';
import 'package:game2048/components/level_select.dart';
import 'package:game2048/components/settings_panel.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('2048'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff667eea), Color(0xff764ba2)],
                ),
              ),
              child: Text(
                '2048 Game',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.grid_on),
              title: const Text('选择关卡'),
              onTap: () {
                Navigator.pop(context);
                _showLevelSelect();
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('新游戏'),
              onTap: () {
                Navigator.pop(context);
                Provider.of<GameProvider>(context, listen: false).initGame();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('设置'),
              onTap: () {
                Navigator.pop(context);
                _showSettings();
              },
            ),
          ],
        ),
      ),
      body: Consumer2<GameProvider, ThemeProvider>(
        builder: (context, gameProvider, themeProvider, child) {
          return GestureDetector(
            onPanStart: (details) => _startPos = details.globalPosition,
            onPanEnd: (details) => _handleSwipe(details.velocity.pixelsPerSecond),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode ? const Color(0xff1a1a2e) : const Color(0xfffaf8ef),
              ),
              child: Column(
                children: [
                  ScoreBoard(score: gameProvider.score, bestScore: gameProvider.bestScore),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GameBoard(
                      grid: gameProvider.grid,
                      gridSize: gameProvider.gridSize,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => gameProvider.initGame(),
                        child: const Text('新游戏'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          backgroundColor: const Color(0xff8f7a66),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Offset _startPos = Offset.zero;

  void _handleSwipe(Offset velocity) {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    
    if (velocity.dx.abs() > velocity.dy.abs()) {
      if (velocity.dx > 0) {
        gameProvider.handleMove(Direction.right);
      } else {
        gameProvider.handleMove(Direction.left);
      }
    } else {
      if (velocity.dy > 0) {
        gameProvider.handleMove(Direction.down);
      } else {
        gameProvider.handleMove(Direction.up);
      }
    }
  }

  void _showLevelSelect() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const LevelSelect(),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const SettingsPanel(),
    );
  }
}