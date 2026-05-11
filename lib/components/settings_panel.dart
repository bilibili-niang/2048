import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SettingsPanel extends StatefulWidget {
  final bool isDarkMode;
  final bool vibrationEnabled;
  final Function(bool) onThemeChanged;
  final Function(bool) onVibrationChanged;

  const SettingsPanel({
    super.key,
    required this.isDarkMode,
    required this.vibrationEnabled,
    required this.onThemeChanged,
    required this.onVibrationChanged,
  });

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  bool? _darkMode;
  bool? _vibrationEnabled;

  @override
  void initState() {
    super.initState();
    _darkMode = widget.isDarkMode;
    _vibrationEnabled = widget.vibrationEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.isDarkMode ? const Color(0xff1a1a2e) : const Color(0xfffaf8ef),
      title: Text(
        '设置',
        style: TextStyle(
          color: widget.isDarkMode ? Colors.white : const Color(0xff776e65),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSettingRow(
            '深色模式',
            _darkMode ?? false,
            (value) {
              setState(() => _darkMode = value);
              widget.onThemeChanged(value);
            },
          ),
          _buildSettingRow(
            '震动反馈',
            _vibrationEnabled ?? true,
            (value) {
              setState(() => _vibrationEnabled = value);
              widget.onVibrationChanged(value);
              StorageService().saveVibrationEnabled(value);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            '确定',
            style: TextStyle(
              color: widget.isDarkMode ? const Color(0xff00b4d8) : const Color(0xfff65e3b),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingRow(String title, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white : const Color(0xff776e65),
            fontSize: 16,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: widget.isDarkMode ? const Color(0xff00b4d8) : const Color(0xfff65e3b),
          activeTrackColor: widget.isDarkMode ? const Color(0xff0f3460) : const Color(0xfff2b179),
        ),
      ],
    );
  }
}