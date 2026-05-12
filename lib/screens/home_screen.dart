import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:game2048/components/confirm_dialog.dart';
import 'package:game2048/components/level_select.dart';
import 'package:game2048/components/settings_panel.dart';
import 'package:game2048/providers/game_provider.dart';
import 'package:game2048/providers/theme_provider.dart';
import 'package:game2048/screens/game_screen.dart';
import 'package:game2048/screens/history_screen.dart';
import 'package:game2048/services/sound_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<GameProvider, ThemeProvider>(
      builder: (context, gameProvider, themeProvider, child) {
        if (gameProvider.isLoading) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('2048'),
              centerTitle: true,
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('2048'),
            centerTitle: true,
          ),
          body: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode ? const Color(0xff1a1a2e) : const Color(0xfffaf8ef),
            ),
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '2048',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '最近最佳分：${gameProvider.globalBestScore}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 24),
                        _ResumeCard(gameProvider: gameProvider),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            SoundService().play('click');
                            _startNewGame(context, gameProvider);
                          },
                          style: _buttonStyle(),
                          child: const Text('新游戏'),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: gameProvider.hasResumableGame
                              ? () async {
                                  final restored = await gameProvider.resumeSavedGame();
                                  if (!context.mounted) {
                                    return;
                                  }
                                  if (!restored) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('恢复存档失败，请重新开始新游戏。')),
                                    );
                                    return;
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const GameScreen()),
                                  );
                                }
                              : null,
                          style: _buttonStyle(),
                          child: Text(gameProvider.hasResumableGame ? '继续游戏' : '暂无可继续对局'),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            SoundService().play('click');
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const HistoryScreen()),
                            );
                          },
                          style: _buttonStyle(),
                          child: const Text('历史记录'),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            SoundService().play('click');
                            _showSettings(context);
                          },
                          style: _buttonStyle(),
                          child: const Text('设置'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xff8f7a66),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 18),
      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Future<void> _startNewGame(BuildContext context, GameProvider gameProvider) async {
    final selectedSize = await showModalBottomSheet<int>(
      context: context,
      builder: (context) {
        return LevelSelect(initialSize: gameProvider.gridSize);
      },
    );

    if (!context.mounted || selectedSize == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return ConfirmDialog(
          title: '开始新游戏',
          message: '你选择了 ${selectedSize}x$selectedSize 网格。确认后将开始一局新游戏，当前布局不会延续。',
          confirmLabel: '确认开始',
          onConfirm: () async {
            await gameProvider.startNewGame(selectedSize);
          },
        );
      },
    );

    if (!context.mounted || confirmed != true) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => const SettingsPanel(),
    );
  }
}

class _ResumeCard extends StatelessWidget {
  final GameProvider gameProvider;

  const _ResumeCard({required this.gameProvider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasResume = gameProvider.hasResumableGame && gameProvider.resumableSnapshot != null;
    final backgroundColor = theme.brightness == Brightness.dark
        ? const Color(0xff16213e)
        : Colors.white.withValues(alpha: 0.72);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: hasResume
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '上次对局',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('网格：${gameProvider.resumableGridSize}x${gameProvider.resumableGridSize}'),
                Text('分数：${gameProvider.resumableScore}'),
                Text('步数：${gameProvider.resumableSteps}'),
                if (gameProvider.resumableUpdatedAt != null)
                  Text('最近保存：${_formatTime(gameProvider.resumableUpdatedAt!)}'),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '继续游玩',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '当前没有可恢复的对局。开始一局新游戏后，系统会在每次有效移动后自动保存进度。',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
    );
  }

  static String _formatTime(String raw) {
    final time = DateTime.tryParse(raw);
    if (time == null) {
      return raw;
    }
    final month = time.month.toString().padLeft(2, '0');
    final day = time.day.toString().padLeft(2, '0');
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$month-$day $hour:$minute';
  }
}
