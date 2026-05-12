import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final Map<String, AudioPlayer> _players = {};
  bool _enabled = true;
  bool _initialized = false;

  bool get enabled => _enabled;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
  }

  void play(String name) {
    if (!_enabled) return;
    unawaited(_playAsync(name));
  }

  Future<void> _playAsync(String name) async {
    try {
      var player = _players[name];
      if (player == null) {
        player = AudioPlayer();
        _players[name] = player;
      }
      await player.stop();
      await player.play(AssetSource('sounds/$name.wav'), volume: 0.5);
    } catch (_) {}
  }

  void dispose() {
    for (final player in _players.values) {
      player.dispose();
    }
    _players.clear();
  }
}
