import 'package:flutter/material.dart';

class LevelSelect extends StatefulWidget {
  final int initialSize;

  const LevelSelect({super.key, required this.initialSize});

  @override
  State<LevelSelect> createState() => _LevelSelectState();
}

class _LevelSelectState extends State<LevelSelect> {
  late int _selectedSize;

  @override
  void initState() {
    super.initState();
    _selectedSize = widget.initialSize;
  }

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
              _LevelButton(size: 3, label: '3×3 简单', selectedSize: _selectedSize, onSelected: _select),
              _LevelButton(size: 4, label: '4×4 普通', selectedSize: _selectedSize, onSelected: _select),
              _LevelButton(size: 5, label: '5×5 困难', selectedSize: _selectedSize, onSelected: _select),
              _LevelButton(size: 6, label: '6×6 专家', selectedSize: _selectedSize, onSelected: _select),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            '自定义大小',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              Slider(
                value: _selectedSize.toDouble(),
                min: 3,
                max: 10,
                divisions: 7,
                label: '$_selectedSize×$_selectedSize',
                onChanged: (value) {
                  setState(() {
                    _selectedSize = value.toInt();
                  });
                },
              ),
              Text('当前: $_selectedSize×$_selectedSize'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, _selectedSize),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff8f7a66),
                  foregroundColor: Colors.white,
                ),
                child: const Text('下一步'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _select(int size) {
    setState(() {
      _selectedSize = size;
    });
    Navigator.pop(context, size);
  }
}

class _LevelButton extends StatelessWidget {
  final int size;
  final String label;
  final int selectedSize;
  final ValueChanged<int> onSelected;

  const _LevelButton({
    required this.size,
    required this.label,
    required this.selectedSize,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onSelected(size),
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedSize == size ? const Color(0xff5c4b3a) : const Color(0xff8f7a66),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(label),
    );
  }
}
