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

  Future<void> play(String name) async {
    if (!_enabled) return;
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
