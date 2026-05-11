import 'package:flutter/material.dart';
import '../models/level.dart';
import '../services/storage_service.dart';

class LevelSelect extends StatefulWidget {
  final Function(int) onLevelSelected;
  final bool isDarkMode;

  const LevelSelect({
    super.key,
    required this.onLevelSelected,
    required this.isDarkMode,
  });

  @override
  State<LevelSelect> createState() => _LevelSelectState();
}

class _LevelSelectState extends State<LevelSelect> {
  List<Level> levels = [];
  int customSize = 4;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLevels();
  }

  Future<void> _loadLevels() async {
    levels = List.from(Level.defaultLevels);
    for (var level in levels) {
      level.bestScore = await StorageService().getBestScore(level.gridSize);
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择关卡'),
        backgroundColor: widget.isDarkMode ? const Color(0xff1a1a2e) : const Color(0xfffaf8ef),
        foregroundColor: widget.isDarkMode ? Colors.white : const Color(0xff776e65),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: levels.length,
                      itemBuilder: (context, index) {
                        Level level = levels[index];
                        return _buildLevelCard(level);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCustomLevelSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildLevelCard(Level level) {
    return Card(
      color: widget.isDarkMode ? const Color(0xff16213e) : const Color(0xffbbada0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () => widget.onLevelSelected(level.gridSize),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${level.gridSize}x${level.gridSize}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                level.name.split('(').last.replaceAll(')', ''),
                style: TextStyle(
                  fontSize: 14,
                  color: widget.isDarkMode ? const Color(0xffeaeaea) : const Color(0xffeee4da),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '最高分: ${level.bestScore}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomLevelSection() {
    return Card(
      color: widget.isDarkMode ? const Color(0xff16213e) : const Color(0xfff2b179),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              '自定义尺寸',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Slider(
              value: customSize.toDouble(),
              min: 3,
              max: 10,
              divisions: 7,
              label: '$customSize x $customSize',
              activeColor: Colors.white,
              inactiveColor: Colors.white38,
              onChanged: (value) {
                setState(() => customSize = value.toInt());
              },
            ),
            const SizedBox(height: 8),
            Text(
              '当前选择: ${customSize}x$customSize',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: widget.isDarkMode ? Colors.white : const Color(0xff776e65),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => widget.onLevelSelected(customSize),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isDarkMode ? const Color(0xff00b4d8) : const Color(0xfff65e3b),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: const Text(
                '开始游戏',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}