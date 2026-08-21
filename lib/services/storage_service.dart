import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/capsule.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String _keyCapsules = 'aura_echo_capsules_v2';
  static const String _keyTheme = 'aura_echo_dark_mode';

  static final List<MemoryCapsule> _defaultCapsules = [
    MemoryCapsule(
      id: 'cap_1',
      title: "Chorvoq tog'lari shabadasi",
      mood: "Xotirjamlik",
      moodColor: const Color(0xFF34C759),
      location: "Burchmulla, Chorvoq suv ombori",
      notes: "Tog' cho'qqilaridan esayotgan mayin shabada va archalar hidi. Fikrlarim butunlay tiniqlashgan lahza.",
      tags: ["Tabiat", "Salqin shabada", "Xotirjamlik", "Tog' havosi"],
      telemetry: TelemetryData(decibels: 34, lux: 780, tiltX: -2, tiltY: 6, sensoryIndex: 94),
      soundPreset: "calm",
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    MemoryCapsule(
      id: 'cap_2',
      title: "Toshkentdagi tungi yomg'ir",
      mood: "Chuqur Diqqat",
      moodColor: const Color(0xFF007AFF),
      location: "Navoiy ko'chasi, Qahvaxona",
      notes: "Derazaga urilayotgan yomg'ir tomchilari va issiq qahva ifori. Yangi loyihalar ustida ishlash uchun ajoyib sokinlik.",
      tags: ["Yomg'ir", "Tungi shahar", "Ijodkorlik", "Qahva"],
      telemetry: TelemetryData(decibels: 41, lux: 210, tiltX: 4, tiltY: -3, sensoryIndex: 91),
      soundPreset: "focus",
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    MemoryCapsule(
      id: 'cap_3',
      title: "Samarqand Registon maydoni sukunati",
      mood: "Ilhom va Hayrat",
      moodColor: const Color(0xFFAF52DE),
      location: "Registon ansambli, Samarqand",
      notes: "Moviy gumbazlar ostidagi cheksiz sokinlik va ulug'vorlik. Asrlar nafasi va fazoviy qulaylik hissi.",
      tags: ["Tarixiy muhit", "Quyosh nuri", "Fazoviy kenglik", "Me'morchilik"],
      telemetry: TelemetryData(decibels: 29, lux: 920, tiltX: 0, tiltY: 2, sensoryIndex: 97),
      soundPreset: "meditation",
      createdAt: DateTime.now(),
    ),
  ];

  List<MemoryCapsule> _capsules = [];
  bool _isDarkMode = false;

  List<MemoryCapsule> get capsules => List.unmodifiable(_capsules);
  bool get isDarkMode => _isDarkMode;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_keyTheme) ?? false;

    final data = prefs.getString(_keyCapsules);
    if (data != null) {
      try {
        final List list = jsonDecode(data);
        _capsules = list.map((item) => MemoryCapsule.fromJson(item)).toList();
      } catch (_) {
        _capsules = List.from(_defaultCapsules);
      }
    } else {
      _capsules = List.from(_defaultCapsules);
      await _saveCapsules();
    }
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTheme, value);
  }

  Future<void> addCapsule(MemoryCapsule capsule) async {
    _capsules.insert(0, capsule);
    await _saveCapsules();
  }

  Future<void> deleteCapsule(String id) async {
    _capsules.removeWhere((c) => c.id == id);
    await _saveCapsules();
  }

  List<MemoryCapsule> filterCapsules({String query = '', String mood = 'all'}) {
    final q = query.toLowerCase().trim();
    return _capsules.filter((c) {
      final matchQuery = q.isEmpty ||
          c.title.toLowerCase().contains(q) ||
          c.notes.toLowerCase().contains(q) ||
          c.location.toLowerCase().contains(q) ||
          c.tags.any((t) => t.toLowerCase().contains(q));

      final matchMood = (mood == 'all') || (c.mood == mood);
      return matchQuery && matchMood;
    }).toList();
  }

  Future<void> resetToDefaults() async {
    _capsules = List.from(_defaultCapsules);
    await _saveCapsules();
  }

  String exportJson() {
    final list = _capsules.map((c) => c.toJson()).toList();
    return const JsonEncoder.withIndent('  ').convert(list);
  }

  Future<bool> importJson(String jsonString) async {
    try {
      final List list = jsonDecode(jsonString);
      final imported = list.map((item) => MemoryCapsule.fromJson(item)).toList();
      _capsules = imported;
      await _saveCapsules();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _saveCapsules() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_capsules.map((c) => c.toJson()).toList());
    await prefs.setString(_keyCapsules, jsonStr);
  }
}

extension IterableExt<T> on Iterable<T> {
  Iterable<T> filter(bool Function(T element) test) sync* {
    for (final element in this) {
      if (test(element)) yield element;
    }
  }
}
