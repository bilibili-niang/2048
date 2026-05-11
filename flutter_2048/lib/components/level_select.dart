import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:game2048/providers/game_provider.dart';

class LevelSelect extends StatelessWidget {
  const LevelSelect({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '选择网格大小',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            childAspectRatio: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _LevelButton(size: 3, label: '3×3 简单'),
              _LevelButton(size: 4, label: '4×4 普通'),
              _LevelButton(size: 5, label: '5×5 困难'),
              _LevelButton(size: 6, label: '6×6 专家'),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            '自定义大小',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              return Column(
                children: [
                  Slider(
                    value: gameProvider.gridSize.toDouble(),
                    min: 3,
                    max: 10,
                    divisions: 7,
                    label: '${gameProvider.gridSize}×${gameProvider.gridSize}',
                    onChanged: (value) {
                      gameProvider.setGridSize(value.toInt());
                    },
                  ),
                  Text('当前: ${gameProvider.gridSize}×${gameProvider.gridSize}'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LevelButton extends StatelessWidget {
  final int size;
  final String label;

  const _LevelButton({required this.size, required this.label});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Provider.of<GameProvider>(context, listen: false).setGridSize(size);
        Navigator.pop(context);
      },
      child: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff8f7a66),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}