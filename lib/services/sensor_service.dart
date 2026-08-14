import 'dart:async';
import 'dart:math';
import '../models/capsule.dart';

class SensorService {
  static final SensorService _instance = SensorService._internal();
  factory SensorService() => _instance;

  SensorService._internal() {
    _startTelemetryLoop();
  }

  int _decibels = 38;
  int _lux = 420;
  int _tiltX = 0;
  int _tiltY = 0;
  int _sensoryIndex = 86;

  final StreamController<TelemetryData> _telemetryController = StreamController<TelemetryData>.broadcast();
  Stream<TelemetryData> get telemetryStream => _telemetryController.stream;

  TelemetryData get currentSnapshot => TelemetryData(
    decibels: _decibels,
    lux: _lux,
    tiltX: _tiltX,
    tiltY: _tiltY,
    sensoryIndex: _sensoryIndex,
  );

  void updateTilt(int x, int y) {
    _tiltX = x.clamp(-30, 30);
    _tiltY = y.clamp(-30, 30);
    _emit();
  }

  Timer? _telemetryTimer;

  void _startTelemetryLoop() {
    double tick = 0;
    _telemetryTimer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      tick += 0.06;

      // Dinamik tabiiy akustik shovqin
      final noise = sin(tick * 1.5) * 6 + cos(tick * 2.7) * 4;
      _decibels = (38 + noise).round().clamp(25, 95);

      // Yorug'lik darajasi
      final hour = DateTime.now().hour;
      final baseLux = (hour >= 7 && hour <= 19) ? 680 : 160;
      _lux = (baseLux + sin(tick * 0.8) * 40).round().clamp(50, 1000);

      // Uyg'unlik indeksi
      final harmony = 100 - (_decibels - 40).abs() * 0.8 - _tiltX.abs() * 0.3;
      _sensoryIndex = harmony.round().clamp(40, 99);

      _emit();
    });
  }

  void stopTelemetry() {
    _telemetryTimer?.cancel();
    _telemetryTimer = null;
  }

  void _emit() {
    if (!_telemetryController.isClosed) {
      _telemetryController.add(currentSnapshot);
    }
  }

  void dispose() {
    stopTelemetry();
    _telemetryController.close();
  }
}
