import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:game2048/providers/theme_provider.dart';
import 'package:game2048/providers/game_provider.dart';

class SettingsPanel extends StatelessWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '设置',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return ListTile(
                title: const Text('深色模式'),
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) => themeProvider.setDarkMode(value),
                ),
              );
            },
          ),
          Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              return ListTile(
                title: const Text('震动反馈'),
                trailing: Switch(
                  value: gameProvider.vibrationEnabled,
                  onChanged: (value) => gameProvider.toggleVibration(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff8f7a66),
              foregroundColor: Colors.white,
            ),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
