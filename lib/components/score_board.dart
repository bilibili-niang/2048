import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:game2048/providers/theme_provider.dart';

class ScoreBoard extends StatelessWidget {
  final int score;
  final int bestScore;
  final int targetTile;

  const ScoreBoard({
    super.key,
    required this.score,
    required this.bestScore,
    required this.targetTile,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ScoreCard(
          title: '分数',
          value: score,
          color: const Color(0xff8f7a66),
          isDark: themeProvider.isDarkMode,
        ),
        const SizedBox(width: 16),
        _ScoreCard(
          title: '最高分',
          value: bestScore,
          color: const Color(0xffbbada0),
          isDark: themeProvider.isDarkMode,
        ),
        const SizedBox(width: 16),
        _ScoreCard(
          title: '目标',
          value: targetTile,
          color: const Color(0xffc97b63),
          isDark: themeProvider.isDarkMode,
        ),
      ],
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final String title;
  final int value;
  final Color color;
  final bool isDark;

  const _ScoreCard({
    required this.title,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff16213e) : color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[400] : Colors.white.withValues(alpha: 0.8),
            ),
          ),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
