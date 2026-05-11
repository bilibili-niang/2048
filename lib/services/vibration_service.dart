import 'package:vibration/vibration.dart';

class VibrationService {
  bool _enabled = true;

  Future<void> vibrateShort() async {
    if (_enabled) {
      try {
        await Vibration.vibrate(duration: 10);
      } catch (e) {
      }
    }
  }

  Future<void> vibrateMedium() async {
    if (_enabled) {
      try {
        await Vibration.vibrate(duration: 50);
      } catch (e) {
      }
    }
  }

  Future<void> vibrateLong() async {
    if (_enabled) {
      try {
        await Vibration.vibrate(duration: 200);
      } catch (e) {
      }
    }
  }

  Future<bool> canVibrate() async {
    try {
      return await Vibration.hasVibrator() ?? false;
    } catch (e) {
      return false;
    }
  }

  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  bool isEnabled() {
    return _enabled;
  }
}