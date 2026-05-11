import 'package:flutter/material.dart';

class ScoreBoard extends StatelessWidget {
  final int score;
  final int bestScore;
  final bool isDarkMode;

  const ScoreBoard({
    super.key,
    required this.score,
    required this.bestScore,
    required this.isDarkMode,
  });

  Widget _buildScoreBox(String title, int value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xff0f3460) : const Color(0xffbbada0),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? const Color(0xffeaeaea) : const Color(0xffeee4da),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      gap: 16,
      children: [
        _buildScoreBox('分数', score),
        _buildScoreBox('最高分', bestScore),
      ],
    );
  }
}