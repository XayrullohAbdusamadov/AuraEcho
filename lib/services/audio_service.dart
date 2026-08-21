import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/sound_channel.dart';
import 'js_interop.dart';
import 'pcm_audio_generator.dart';

class AudioService extends ChangeNotifier {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;

  AudioService._internal() {
    _initChannels();
  }

  double _masterVolume = 0.85;
  double get masterVolume => _masterVolume;

  final List<SoundChannel> _channels = [];
  List<SoundChannel> get channels => List.unmodifiable(_channels);

  bool _isCustomSoundPlaying = false;
  bool get isCustomSoundPlaying => _isCustomSoundPlaying;

  // Native player map for Android / iOS / Desktop
  final Map<String, AudioPlayer> _nativePlayers = {};
  AudioPlayer? _customSynthPlayer;

  void _initChannels() {
    _channels.addAll([
      SoundChannel(
        id: 'rain',
        name: "Yomg'ir & Tomchilar",
        subtitle: "Oq/pushti shovqin va tomchilar",
        icon: CupertinoIcons.cloud_rain_fill,
        color: const Color(0xFF007AFF),
        volume: 0.6,
      ),
      SoundChannel(
        id: 'forest',
        name: "O'rmon & Mayin Shamol",
        subtitle: "Rezonansli shamol va qushlar",
        icon: CupertinoIcons.tree,
        color: const Color(0xFF34C759),
        volume: 0.5,
      ),
      SoundChannel(
        id: 'binaural',
        name: "Binaural To'lqinlar (6Hz)",
        subtitle: "Theta sokinlik to'lqinlari",
        icon: CupertinoIcons.waveform_path_ecg,
        color: const Color(0xFFAF52DE),
        volume: 0.5,
      ),
      SoundChannel(
        id: 'ocean',
        name: "Okean To'lqinlari",
        subtitle: "LFO modulyatsiyali to'lqin",
        icon: CupertinoIcons.drop_fill,
        color: const Color(0xFF5AC8FA),
        volume: 0.6,
      ),
      SoundChannel(
        id: 'thunder',
        name: "Momaqaldiroq & Guldurak",
        subtitle: "Chuqur sub-bass chaqmoq",
        icon: CupertinoIcons.bolt_fill,
        color: const Color(0xFF5856D6),
        volume: 0.5,
      ),
      SoundChannel(
        id: 'campfire',
        name: "Tungi Gulxan & Olov",
        subtitle: "Yog'och chirsillashi va olov",
        icon: CupertinoIcons.flame_fill,
        color: const Color(0xFFFF9500),
        volume: 0.55,
      ),
      SoundChannel(
        id: 'coffeeshop',
        name: "Shovqinli Qahvaxona",
        subtitle: "Shinam kafe va chashkalar",
        icon: CupertinoIcons.cart_fill,
        color: const Color(0xFFFFCC00),
        volume: 0.5,
      ),
      SoundChannel(
        id: 'cosmic',
        name: "Kosmik Dron (432Hz)",
        subtitle: "Chuqur fazoviy garmonika",
        icon: CupertinoIcons.circle_grid_hex_fill,
        color: const Color(0xFFAF52DE),
        volume: 0.45,
      ),
      SoundChannel(
        id: 'tibetan',
        name: "Tibet Kosalari",
        subtitle: "Rezonansli kristall sado",
        icon: CupertinoIcons.bell_fill,
        color: const Color(0xFFFF2D55),
        volume: 0.5,
      ),
      SoundChannel(
        id: 'stream',
        name: "Tog' Buloqlari & Suv",
        subtitle: "Oqar suv shildirashi",
        icon: CupertinoIcons.drop,
        color: const Color(0xFF5AC8FA),
        volume: 0.5,
      ),
      SoundChannel(
        id: 'nightcity',
        name: "Tungi Shahar Shabadasi",
        subtitle: "Uzoq shahar sokinligi",
        icon: CupertinoIcons.building_2_fill,
        color: const Color(0xFF8E8E93),
        volume: 0.5,
      ),
      SoundChannel(
        id: 'noises',
        name: "Pushti & Jigarrang Shovqin",
        subtitle: "Chuqur diqqat foni",
        icon: CupertinoIcons.radiowaves_right,
        color: const Color(0xFFFF3B30),
        volume: 0.5,
      ),
      SoundChannel(
        id: 'leaves',
        name: "Kuzgi Barglar & Shamol",
        subtitle: "Barglar shitirlashi va epkin",
        icon: CupertinoIcons.wind,
        color: const Color(0xFFFF9500),
        volume: 0.5,
      ),
      SoundChannel(
        id: 'train',
        name: "Tungi Poyezd Relslari",
        subtitle: "Gipnotik ritmli tebranish",
        icon: CupertinoIcons.car_detailed,
        color: const Color(0xFF5856D6),
        volume: 0.5,
      ),
      SoundChannel(
        id: 'clock',
        name: "Qadimiy Soat Tik-Taki",
        subtitle: "Vaqt mayatnigi sokinligi",
        icon: CupertinoIcons.clock_fill,
        color: const Color(0xFFFFCC00),
        volume: 0.5,
      ),
      SoundChannel(
        id: 'piano',
        name: "Ambient Pianino",
        subtitle: "Neoklassik pentatonik kuylar",
        icon: CupertinoIcons.music_note_2,
        color: const Color(0xFFFF2D55),
        volume: 0.55,
      ),
    ]);
  }

  void _callJs(String method, List<dynamic> args) {
    if (kIsWeb) {
      callJsMethod(method, args);
    }
  }

  void playTaptic([String type = 'light']) {
    _callJs('playTaptic', [type]);
  }

  Future<void> toggleChannel(String id, bool active) async {
    final ch = _channels.firstWhere((c) => c.id == id, orElse: () => _channels[0]);
    ch.isActive = active;

    if (kIsWeb) {
      _callJs('toggleChannel', [id, active]);
    } else {
      // Native Mobile (Android/iOS) & Desktop Audio Player
      if (active) {
        AudioPlayer player = _nativePlayers[id] ?? AudioPlayer();
        _nativePlayers[id] = player;
        await player.setReleaseMode(ReleaseMode.loop);
        await player.setVolume((ch.volume * _masterVolume).clamp(0.0, 1.0));
        final bytes = PcmAudioGenerator.generateWavBuffer(id, durationSeconds: 3.0);
        await player.play(BytesSource(bytes));
      } else {
        final player = _nativePlayers[id];
        if (player != null) {
          await player.stop();
        }
      }
    }

    playTaptic('light');
    notifyListeners();
  }

  Future<void> setVolume(String id, double volume) async {
    final ch = _channels.firstWhere((c) => c.id == id, orElse: () => _channels[0]);
    ch.volume = volume;

    if (kIsWeb) {
      _callJs('setVolume', [id, volume]);
    } else {
      final player = _nativePlayers[id];
      if (player != null) {
        await player.setVolume((volume * _masterVolume).clamp(0.0, 1.0));
      }
    }
    notifyListeners();
  }

  Future<void> setPan(String id, double pan) async {
    final ch = _channels.firstWhere((c) => c.id == id, orElse: () => _channels[0]);
    ch.pan = pan;
    if (kIsWeb) {
      _callJs('setPan', [id, pan]);
    }
    notifyListeners();
  }

  Future<void> setMasterVolume(double volume) async {
    _masterVolume = volume;
    if (kIsWeb) {
      _callJs('setMasterVolume', [volume]);
    } else {
      for (var entry in _nativePlayers.entries) {
        final ch = _channels.firstWhere((c) => c.id == entry.key, orElse: () => _channels[0]);
        if (ch.isActive) {
          await entry.value.setVolume((ch.volume * _masterVolume).clamp(0.0, 1.0));
        }
      }
    }
    notifyListeners();
  }

  Future<void> stopAll() async {
    for (var ch in _channels) {
      ch.isActive = false;
    }
    _isCustomSoundPlaying = false;

    if (kIsWeb) {
      _callJs('stopAll', []);
    } else {
      for (var player in _nativePlayers.values) {
        await player.stop();
      }
      if (_customSynthPlayer != null) {
        await _customSynthPlayer!.stop();
      }
    }

    playTaptic('medium');
    notifyListeners();
  }

  Future<void> applyPreset(String presetName) async {
    await stopAll();
    switch (presetName) {
      case 'focus':
        await _setChannelActive('rain', 0.6);
        await _setChannelActive('binaural', 0.5);
        break;
      case 'calm':
        await _setChannelActive('forest', 0.6);
        await _setChannelActive('ocean', 0.5);
        await _setChannelActive('stream', 0.4);
        break;
      case 'meditation':
        await _setChannelActive('tibetan', 0.7);
        await _setChannelActive('cosmic', 0.5);
        await _setChannelActive('binaural', 0.5);
        break;
      case 'campfire':
        await _setChannelActive('campfire', 0.7);
        await _setChannelActive('forest', 0.4);
        await _setChannelActive('nightcity', 0.3);
        break;
      case 'storm':
        await _setChannelActive('rain', 0.7);
        await _setChannelActive('thunder', 0.7);
        await _setChannelActive('forest', 0.3);
        break;
      case 'cafe':
        await _setChannelActive('coffeeshop', 0.65);
        await _setChannelActive('rain', 0.45);
        break;
      case 'creative':
        await _setChannelActive('piano', 0.65);
        await _setChannelActive('leaves', 0.5);
        await _setChannelActive('rain', 0.4);
        break;
      case 'train':
        await _setChannelActive('train', 0.7);
        await _setChannelActive('rain', 0.5);
        break;
    }
    playTaptic('medium');
    notifyListeners();
  }

  Future<void> _setChannelActive(String id, double vol) async {
    try {
      final ch = _channels.firstWhere((c) => c.id == id);
      ch.isActive = true;
      ch.volume = vol;
      await toggleChannel(id, true);
    } catch (_) {}
  }

  Future<void> startCustomSound({
    String waveType = 'sine',
    double freq = 220,
    String filterType = 'lowpass',
    double filterFreq = 800,
    double lfoFreq = 2.0,
    double lfoDepth = 50,
  }) async {
    _isCustomSoundPlaying = true;
    if (kIsWeb) {
      _callJs('startCustomSound', [waveType, freq, filterType, filterFreq, lfoFreq, lfoDepth]);
    } else {
      _customSynthPlayer ??= AudioPlayer();
      await _customSynthPlayer!.setReleaseMode(ReleaseMode.loop);
      await _customSynthPlayer!.setVolume((0.7 * _masterVolume).clamp(0.0, 1.0));
      final bytes = PcmAudioGenerator.generateCustomSynthBuffer(
        waveType: waveType,
        freq: freq,
        filterType: filterType,
        filterFreq: filterFreq,
        lfoFreq: lfoFreq,
      );
      await _customSynthPlayer!.play(BytesSource(bytes));
    }
    playTaptic('medium');
    notifyListeners();
  }

  Future<void> stopCustomSound() async {
    _isCustomSoundPlaying = false;
    if (kIsWeb) {
      _callJs('stopCustomSound', []);
    } else {
      if (_customSynthPlayer != null) {
        await _customSynthPlayer!.stop();
      }
    }
    playTaptic('light');
    notifyListeners();
  }

  void exportAudioToFile({String target = 'active_mix', int duration = 15, String? fileName}) {
    playTaptic('medium');
    final name = fileName ?? (target == 'active_mix' ? 'AuraEcho_Miks.wav' : 'AuraEcho_$target.wav');
    _callJs('exportAudio', [target, duration, name]);
  }
}
