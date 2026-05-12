import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:game2048/providers/game_provider.dart';
import 'package:game2048/providers/theme_provider.dart';
import 'package:game2048/components/game_board.dart';
import 'package:game2048/components/confirm_dialog.dart';
import 'package:game2048/components/score_board.dart';
import 'package:game2048/components/settings_panel.dart';
import 'package:game2048/services/sound_service.dart';
import 'package:vibration/vibration.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FocusNode _focusNode = FocusNode();
  bool _showingWinDialog = false;
  bool _showingOverDialog = false;
  bool _showWinPulse = false;
  bool _showWinFlash = false;
  bool _showGameOverMask = false;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          await Provider.of<GameProvider>(context, listen: false).saveCurrentProgress();
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('2048'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                SoundService().play('click');
                Vibration.vibrate(duration: 10);
                _showSettings();
              },
            ),
          ],
        ),
        body: Consumer2<GameProvider, ThemeProvider>(
          builder: (context, gameProvider, themeProvider, child) {
            _handleDialogs(gameProvider);
            return Focus(
              focusNode: _focusNode,
              autofocus: true,
              child: KeyboardListener(
                focusNode: _focusNode,
                onKeyEvent: (event) {
                  if (event is! KeyDownEvent) {
                    return;
                  }
                  if (event.logicalKey == LogicalKeyboardKey.arrowLeft || event.logicalKey == LogicalKeyboardKey.keyA) {
                    gameProvider.handleMove(Direction.left);
                  } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
                      event.logicalKey == LogicalKeyboardKey.keyD) {
                    gameProvider.handleMove(Direction.right);
                  } else if (event.logicalKey == LogicalKeyboardKey.arrowUp || event.logicalKey == LogicalKeyboardKey.keyW) {
                    gameProvider.handleMove(Direction.up);
                  } else if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
                      event.logicalKey == LogicalKeyboardKey.keyS) {
                    gameProvider.handleMove(Direction.down);
                  }
                },
                child: GestureDetector(
                  onTap: () => _focusNode.requestFocus(),
                  onPanEnd: (details) => _handleSwipe(details.velocity.pixelsPerSecond),
                  child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode ? const Color(0xff1a1a2e) : const Color(0xfffaf8ef),
                  ),
                  child: Column(
                    children: [
                      ScoreBoard(
                        score: gameProvider.score,
                        bestScore: gameProvider.bestScore,
                        targetTile: gameProvider.targetTile,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '步数 ${gameProvider.steps}  ·  当前网格 ${gameProvider.gridSize}x${gameProvider.gridSize} · 键盘: WASD / 方向键',
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Stack(
                          children: [
                            AnimatedScale(
                              scale: _showWinPulse ? 1.02 : 1.0,
                              duration: const Duration(milliseconds: 260),
                              curve: Curves.easeOutCubic,
                              child: GameBoard(
                                grid: gameProvider.grid,
                                gridSize: gameProvider.gridSize,
                              ),
                            ),
                            IgnorePointer(
                              child: AnimatedOpacity(
                                opacity: _showGameOverMask ? 0.42 : 0.0,
                                duration: const Duration(milliseconds: 360),
                                curve: Curves.easeInOut,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: IgnorePointer(
                                child: AnimatedOpacity(
                                  opacity: _showWinPulse ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 380),
                                  curve: Curves.easeOut,
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        '目标达成 ${gameProvider.targetTile}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: IgnorePointer(
                                child: AnimatedOpacity(
                                  opacity: _showWinFlash ? 0.18 : 0.0,
                                  duration: const Duration(milliseconds: 240),
                                  curve: Curves.easeOut,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFFFFF3B0),
                                          Color(0x00FFF3B0),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: IgnorePointer(
                                child: AnimatedOpacity(
                                  opacity: _showGameOverMask ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 260),
                                  curve: Curves.easeInOut,
                                  child: const Center(
                                    child: Text(
                                      '游戏结束',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              SoundService().play('click');
                              Vibration.vibrate(duration: 10);
                              _confirmRestart(context, gameProvider);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              backgroundColor: const Color(0xff8f7a66),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('重新开始'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleDialogs(GameProvider gameProvider) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (gameProvider.isWin && !_showingWinDialog) {
        _triggerWinPulse();
        _showWinDialog(gameProvider);
      }
      if (gameProvider.isGameOver && !_showingOverDialog) {
        setState(() {
          _showGameOverMask = true;
        });
        _showGameOverDialog(gameProvider);
      } else if (!gameProvider.isGameOver && _showGameOverMask) {
        setState(() {
          _showGameOverMask = false;
        });
      }
    });
  }

  void _triggerWinPulse() {
    setState(() {
      _showWinPulse = true;
      _showWinFlash = true;
    });
    Future<void>.delayed(const Duration(milliseconds: 260), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _showWinFlash = false;
      });
    });
    Future<void>.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _showWinPulse = false;
      });
    });
  }

  Future<void> _showWinDialog(GameProvider gameProvider) async {
    _showingWinDialog = true;
    final navigator = Navigator.of(context);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('达成目标'),
          content: Text('你达成了 ${gameProvider.targetTile}！是否继续游玩？'),
          actions: [
            TextButton(
              onPressed: () async {
                await gameProvider.saveCurrentProgress();
                if (!mounted) {
                  return;
                }
                navigator.pop();
                navigator.pop();
              },
              child: const Text('回首页'),
            ),
            FilledButton(
              onPressed: () async {
                await gameProvider.continueAfterWin();
                if (!mounted) {
                  return;
                }
                navigator.pop();
              },
              child: const Text('继续'),
            ),
          ],
        );
      },
    );
    _showingWinDialog = false;
  }

  Future<void> _showGameOverDialog(GameProvider gameProvider) async {
    _showingOverDialog = true;
    final navigator = Navigator.of(context);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('游戏结束'),
          content: Text('最终分数 ${gameProvider.score}，最高方块 ${gameProvider.maxTile}。'),
          actions: [
            TextButton(
              onPressed: () {
                navigator.pop();
                navigator.pop();
              },
              child: const Text('回首页'),
            ),
            FilledButton(
              onPressed: () async {
                await gameProvider.restartCurrentGame();
                if (!mounted) {
                  return;
                }
                navigator.pop();
              },
              child: const Text('再来一局'),
            ),
          ],
        );
      },
    );
    _showingOverDialog = false;
  }

  Future<void> _handleSwipe(Offset velocity) async {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);

    if (velocity.dx.abs() > velocity.dy.abs()) {
      if (velocity.dx > 0) {
        await gameProvider.handleMove(Direction.right);
      } else {
        await gameProvider.handleMove(Direction.left);
      }
    } else {
      if (velocity.dy > 0) {
        await gameProvider.handleMove(Direction.down);
      } else {
        await gameProvider.handleMove(Direction.up);
      }
    }
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const SettingsPanel(),
    );
  }

  Future<void> _confirmRestart(BuildContext context, GameProvider gameProvider) async {
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return ConfirmDialog(
          title: '重新开始本局',
          message:
              '确认后将以当前 ${gameProvider.gridSize}x${gameProvider.gridSize} 网格重新开一局，当前布局不会保留。',
          confirmLabel: '确认重开',
          onConfirm: () async {
            await gameProvider.restartCurrentGame();
          },
        );
      },
    );
  }
}
