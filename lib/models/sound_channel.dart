import 'package:flutter/cupertino.dart';

class SoundChannel {
  final String id;
  final String name;
  final String subtitle;
  final IconData icon;
  final Color color;
  bool isActive;
  double volume;
  double pan; // -1.0 (Chap) to +1.0 (O'ng)

  SoundChannel({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.isActive = false,
    this.volume = 0.5,
    this.pan = 0.0,
  });

  String get panLabel {
    if (pan == 0) return 'Markaz';
    if (pan < 0) return 'Chap ${(pan.abs() * 100).round()}%';
    return "O'ng ${(pan * 100).round()}%";
  }

  String get volumeLabel => "${(volume * 100).round()}%";
}
