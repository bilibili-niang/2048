import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/game_engine.dart';
import '../providers/game_provider.dart';
import '../providers/theme_provider.dart';
import '../components/game_board.dart';
import '../components/score_board.dart';
import '../components/settings_panel.dart';
import '../services/vibration_service.dart';
import '../services/storage_service.dart';

class GameScreen extends StatefulWidget {
  final int gridSize;

  const GameScreen({super.key, required this.gridSize});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameProvider _gameProvider;
  late ThemeProvider _themeProvider;
  final VibrationService _vibrationService = VibrationService();
  bool _vibrationEnabled = true;
  Offset _startTouch = Offset.zero;
  Offset _endTouch = Offset.zero;

  @override
  void initState() {
    super.initState();
    _loadVibrationSetting();
  }

  Future<void> _loadVibrationSetting() async {
    _vibrationEnabled = await StorageService().getVibrationEnabled();
  }

  @override
  Widget build(BuildContext context) {
    _gameProvider = Provider.of<GameProvider>(context);
    _themeProvider = Provider.of<ThemeProvider>(context);
    
    bool isDarkMode = _themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xff1a1a2e) : const Color(0xfffaf8ef),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDarkMode),
            const SizedBox(height: 16),
            ScoreBoard(
              score: _gameProvider.score,
              bestScore: _gameProvider.bestScore,
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: GestureDetector(
                  onPanStart: (details) => _startTouch = details.globalPosition,
                  onPanEnd: (details) {
                    _endTouch = details.velocity.pixelsPerSecond;
                    _handleSwipe();
                  },
                  child: GameBoard(
                    grid: _gameProvider.grid,
                    gridSize: _gameProvider.gridSize,
                    isDarkMode: isDarkMode,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildButtons(isDarkMode),
            const SizedBox(height: 16),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingButtons(isDarkMode),
      onKeyEvent: (event) => _handleKeyEvent(event),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : const Color(0xff776e65),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        Text(
          '${_gameProvider.gridSize}x${_gameProvider.gridSize}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : const Color(0xff776e65),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.settings,
            color: isDarkMode ? Colors.white : const Color(0xff776e65),
          ),
          onPressed: () => _showSettings(isDarkMode),
        ),
      ],
    );
  }

  Widget _buildButtons(bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      gap: 16,
      children: [
        ElevatedButton(
          onPressed: () => _gameProvider.reset(),
          style: ElevatedButton.styleFrom(
            backgroundColor: isDarkMode ? const Color(0xff00b4d8) : const Color(0xfff65e3b),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          child: const Text(
            '新游戏',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingButtons(bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          onPressed: () => _showSettings(isDarkMode),
          backgroundColor: isDarkMode ? const Color(0xff0f3460) : const Color(0xffbbada0),
          child: Icon(Icons.settings, color: Colors.white),
        ),
      ],
    );
  }

  void _showSettings(bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => SettingsPanel(
        isDarkMode: isDarkMode,
        vibrationEnabled: _vibrationEnabled,
        onThemeChanged: (value) {
          _themeProvider.setTheme(value ? ThemeMode.dark : ThemeMode.light);
        },
        onVibrationChanged: (value) {
          _vibrationEnabled = value;
          _vibrationService.setEnabled(value);
        },
      ),
    );
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowUp:
        case LogicalKeyboardKey.keyW:
          _gameProvider.move(Direction.up);
          break;
        case LogicalKeyboardKey.arrowDown:
        case LogicalKeyboardKey.keyS:
          _gameProvider.move(Direction.down);
          break;
        case LogicalKeyboardKey.arrowLeft:
        case LogicalKeyboardKey.keyA:
          _gameProvider.move(Direction.left);
          break;
        case LogicalKeyboardKey.arrowRight:
        case LogicalKeyboardKey.keyD:
          _gameProvider.move(Direction.right);
          break;
      }
    }
  }

  void _handleSwipe() {
    double dx = _endTouch.dx;
    double dy = _endTouch.dy;
    double minSwipeDistance = 50;

    if (dx.abs() > dy.abs()) {
      if (dx.abs() > minSwipeDistance) {
        if (dx > 0) {
          _gameProvider.move(Direction.right);
        } else {
          _gameProvider.move(Direction.left);
        }
      }
    } else {
      if (dy.abs() > minSwipeDistance) {
        if (dy > 0) {
          _gameProvider.move(Direction.down);
        } else {
          _gameProvider.move(Direction.up);
        }
      }
    }
  }
}