import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:game2048/providers/theme_provider.dart';
import 'package:game2048/models/tile.dart';

class TileWidget extends StatelessWidget {
  final Tile tile;
  final double size;

  const TileWidget({super.key, required this.tile, required this.size});

  Color _getTileColor(int value, bool isDark) {
    switch (value) {
      case 0:
        return isDark ? const Color(0xff0f3460) : const Color(0xffcdc1b4);
      case 2:
        return isDark ? const Color(0xff2d5a87) : const Color(0xffeee4da);
      case 4:
        return isDark ? const Color(0xff1e6f8f) : const Color(0xffede0c8);
      case 8:
        return isDark ? const Color(0xff0096c7) : const Color(0xfff2b179);
      case 16:
        return isDark ? const Color(0xff00b4d8) : const Color(0xfff59563);
      case 32:
        return isDark ? const Color(0xff48cae4) : const Color(0xfff67c5f);
      case 64:
        return isDark ? const Color(0xff90e0ef) : const Color(0xfff65e3b);
      case 128:
        return isDark ? const Color(0xffcae9ff) : const Color(0xffedcf72);
      case 256:
        return isDark ? const Color(0xffffd60a) : const Color(0xffedcc61);
      case 512:
        return isDark ? const Color(0xffffb703) : const Color(0xffedc850);
      case 1024:
        return isDark ? const Color(0xffff9500) : const Color(0xffedc53f);
      case 2048:
        return isDark ? const Color(0xffff6b35) : const Color(0xffedc22e);
      default:
        return isDark ? const Color(0xffff006e) : const Color(0xff3c3a32);
    }
  }

  Color _getTextColor(int value, bool isDark) {
    if (value <= 4) {
      return isDark ? Colors.white : const Color(0xff776e65);
    }
    return Colors.white;
  }

  double _getFontSize(int value) {
    if (value >= 1000) return size * 0.35;
    if (value >= 100) return size * 0.42;
    return size * 0.5;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final animationKey = ValueKey('${tile.row}-${tile.col}-${tile.value}-${tile.isNew}-${tile.isMerged}');
    final startScale = tile.isNew
        ? 0.72
        : tile.isMerged
            ? 1.18
            : 1.0;
    final animationDuration = tile.isNew
        ? const Duration(milliseconds: 220)
        : tile.isMerged
            ? const Duration(milliseconds: 170)
            : const Duration(milliseconds: 120);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getTileColor(tile.value, isDark),
        borderRadius: BorderRadius.circular(6),
      ),
      child: tile.value != 0
          ? TweenAnimationBuilder<double>(
              key: animationKey,
              tween: Tween<double>(begin: startScale, end: 1.0),
              duration: animationDuration,
              curve: Curves.easeOutBack,
              child: Center(
                child: Text(
                  tile.value.toString(),
                  style: TextStyle(
                    fontSize: _getFontSize(tile.value),
                    fontWeight: FontWeight.bold,
                    color: _getTextColor(tile.value, isDark),
                  ),
                ),
              ),
              builder: (context, scale, child) {
                return Transform.scale(scale: scale, child: child);
              },
            )
          : null,
    );
  }
}
