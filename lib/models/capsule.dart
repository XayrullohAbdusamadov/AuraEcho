import 'package:flutter/cupertino.dart';

class TelemetryData {
  final int decibels;
  final int lux;
  final int tiltX;
  final int tiltY;
  final int sensoryIndex;

  TelemetryData({
    required this.decibels,
    required this.lux,
    required this.tiltX,
    required this.tiltY,
    required this.sensoryIndex,
  });

  Map<String, dynamic> toJson() => {
    'decibels': decibels,
    'lux': lux,
    'tiltX': tiltX,
    'tiltY': tiltY,
    'sensoryIndex': sensoryIndex,
  };

  factory TelemetryData.fromJson(Map<String, dynamic> json) => TelemetryData(
    decibels: json['decibels'] ?? 38,
    lux: json['lux'] ?? 420,
    tiltX: json['tiltX'] ?? 0,
    tiltY: json['tiltY'] ?? 0,
    sensoryIndex: json['sensoryIndex'] ?? 86,
  );
}

class MemoryCapsule {
  final String id;
  final String title;
  final String mood;
  final Color moodColor;
  final String location;
  final String notes;
  final List<String> tags;
  final TelemetryData telemetry;
  final String soundPreset;
  final DateTime createdAt;

  MemoryCapsule({
    required this.id,
    required this.title,
    required this.mood,
    required this.moodColor,
    required this.location,
    required this.notes,
    required this.tags,
    required this.telemetry,
    required this.soundPreset,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'mood': mood,
    'moodColor': moodColor.toARGB32().toRadixString(16),
    'location': location,
    'notes': notes,
    'tags': tags,
    'telemetry': telemetry.toJson(),
    'soundPreset': soundPreset,
    'createdAt': createdAt.toIso8601String(),
  };

  factory MemoryCapsule.fromJson(Map<String, dynamic> json) {
    Color color = const Color(0xFF007AFF);
    if (json['moodColor'] != null) {
      try {
        final colorHex = json['moodColor'].toString().replaceAll('#', '');
        color = Color(int.parse(colorHex.length == 6 ? 'FF$colorHex' : colorHex, radix: 16));
      } catch (_) {}
    }

    return MemoryCapsule(
      id: json['id'] ?? 'cap_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] ?? 'Xotira',
      mood: json['mood'] ?? 'Xotirjamlik',
      moodColor: color,
      location: json['location'] ?? "Noma'lum",
      notes: json['notes'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      telemetry: TelemetryData.fromJson(json['telemetry'] ?? {}),
      soundPreset: json['soundPreset'] ?? 'calm',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String get formattedDate {
    const months = ["Yan", "Fev", "Mar", "Apr", "May", "Iyun", "Iyul", "Avg", "Sen", "Okt", "Noy", "Dek"];
    return "${createdAt.day} ${months[createdAt.month - 1]}, ${createdAt.year}";
  }
}
