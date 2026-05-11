import 'package:flutter/material.dart';
import '../models/tile.dart';

class TileWidget extends StatelessWidget {
  final Tile tile;
  final double size;
  final bool isDarkMode;

  const TileWidget({
    super.key,
    required this.tile,
    required this.size,
    required this.isDarkMode,
  });

  Color _getBackgroundColor(int value) {
    if (isDarkMode) {
      switch (value) {
        case 2: return const Color(0xff3d3d5c);
        case 4: return const Color(0xff4a4a6a);
        case 8: return const Color(0xffff6b35);
        case 16: return const Color(0xfff7931e);
        case 32: return const Color(0xffffcc00);
        case 64: return const Color(0xffff3d3d);
        case 128: return const Color(0xff9d4edd);
        case 256: return const Color(0xff7b2cbf);
        case 512: return const Color(0xff5a189a);
        case 1024: return const Color(0xff00b4d8);
        case 2048: return const Color(0xff0077b6);
        default: return const Color(0xff023e8a);
      }
    } else {
      switch (value) {
        case 2: return const Color(0xffeee4da);
        case 4: return const Color(0xffede0c8);
        case 8: return const Color(0xfff2b179);
        case 16: return const Color(0xfff59563);
        case 32: return const Color(0xfff67c5f);
        case 64: return const Color(0xfff65e3b);
        case 128: return const Color(0xffedcf72);
        case 256: return const Color(0xffedcc61);
        case 512: return const Color(0xffedc850);
        case 1024: return const Color(0xffedc53f);
        case 2048: return const Color(0xffedc22e);
        default: return const Color(0xff3c3a32);
      }
    }
  }

  Color _getTextColor(int value) {
    if (isDarkMode) {
      if (value == 2 || value == 4) {
        return const Color(0xffeaeaea);
      } else if (value == 32) {
        return const Color(0xff1a1a2e);
      }
      return Colors.white;
    } else {
      if (value <= 4) {
        return const Color(0xff776e65);
      }
      return const Color(0xfff9f6f2);
    }
  }

  double _getFontSize(int value) {
    if (value >= 1000) return size * 0.35;
    if (value >= 100) return size * 0.45;
    return size * 0.55;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: tile.isNew ? const Duration(milliseconds: 200) : const Duration(milliseconds: 150),
      curve: tile.isNew ? Curves.bounceOut : Curves.easeOut,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getBackgroundColor(tile.value),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: const Offset(2, 2),
            blurRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: AnimatedScale(
          scale: tile.isMerged ? 1.2 : 1.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: Text(
            tile.value.toString(),
            style: TextStyle(
              fontSize: _getFontSize(tile.value),
              fontWeight: FontWeight.bold,
              color: _getTextColor(tile.value),
            ),
          ),
        ),
      ),
    );
  }
}