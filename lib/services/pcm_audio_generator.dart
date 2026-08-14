import 'dart:math';
import 'dart:typed_data';

class PcmAudioGenerator {
  static const int sampleRate = 44100;

  static Uint8List generateWavBuffer(String soundId, {double durationSeconds = 3.0}) {
    final int numSamples = (sampleRate * durationSeconds).round();
    final int dataSize = numSamples * 4; // 2 channels x 2 bytes
    final int fileSize = 44 + dataSize;

    final ByteData bytes = ByteData(fileSize);

    // RIFF Header
    _writeString(bytes, 0, 'RIFF');
    bytes.setUint32(4, fileSize - 8, Endian.little);
    _writeString(bytes, 8, 'WAVE');

    // fmt chunk
    _writeString(bytes, 12, 'fmt ');
    bytes.setUint32(16, 16, Endian.little); // Chunk size
    bytes.setUint16(20, 1, Endian.little);  // PCM format
    bytes.setUint16(22, 2, Endian.little);  // Stereo (2 channels)
    bytes.setUint32(24, sampleRate, Endian.little);
    bytes.setUint32(28, sampleRate * 4, Endian.little); // Byte rate
    bytes.setUint16(32, 4, Endian.little);  // Block align
    bytes.setUint16(34, 16, Endian.little); // Bits per sample

    // data chunk
    _writeString(bytes, 36, 'data');
    bytes.setUint32(40, dataSize, Endian.little);

    final Random random = Random(soundId.hashCode);
    int offset = 44;

    for (int i = 0; i < numSamples; i++) {
      final double t = i / sampleRate;
      double leftSample = 0.0;
      double rightSample = 0.0;

      switch (soundId) {
        case 'binaural':
          leftSample = sin(2 * pi * 200 * t) * 0.5;
          rightSample = sin(2 * pi * 206 * t) * 0.5;
          break;

        case 'rain':
          final noise = (random.nextDouble() * 2 - 1) * 0.4;
          final droplet = (random.nextDouble() > 0.996) ? (random.nextDouble() * 0.6) : 0.0;
          leftSample = noise + droplet;
          rightSample = noise * 0.9 + droplet * 0.8;
          break;

        case 'forest':
          final wind = sin(2 * pi * 0.3 * t) * (random.nextDouble() * 0.3);
          final chirp = (sin(t * 12) > 0.95) ? sin(2 * pi * 2400 * t) * 0.2 : 0.0;
          leftSample = wind + chirp;
          rightSample = wind * 0.8 + chirp * 1.1;
          break;

        case 'ocean':
          final waveMod = (sin(2 * pi * 0.15 * t) + 1) / 2;
          final noise = (random.nextDouble() * 2 - 1) * 0.35 * waveMod;
          leftSample = noise;
          rightSample = noise * 0.95;
          break;

        case 'thunder':
          final rumble = sin(2 * pi * 45 * t) * 0.4 + sin(2 * pi * 70 * t) * 0.3;
          final strike = (i < sampleRate * 0.3) ? (random.nextDouble() * 0.5) : 0.0;
          leftSample = (rumble + strike).clamp(-1.0, 1.0);
          rightSample = (rumble * 0.95 + strike * 0.9).clamp(-1.0, 1.0);
          break;

        case 'campfire':
          final crackle = (random.nextDouble() > 0.985) ? (random.nextDouble() * 0.7 - 0.35) : 0.0;
          final hum = sin(2 * pi * 80 * t) * 0.25;
          leftSample = hum + crackle;
          rightSample = hum * 0.9 + crackle * 1.1;
          break;

        case 'coffeeshop':
          final murmur = (random.nextDouble() * 2 - 1) * 0.25;
          final clink = (random.nextDouble() > 0.994) ? sin(2 * pi * 3200 * t) * 0.3 : 0.0;
          leftSample = murmur + clink;
          rightSample = murmur * 0.95 + clink * 0.85;
          break;

        case 'cosmic':
          leftSample = (sin(2 * pi * 108 * t) * 0.4 + sin(2 * pi * 216 * t) * 0.3);
          rightSample = (sin(2 * pi * 108.5 * t) * 0.4 + sin(2 * pi * 216.5 * t) * 0.3);
          break;

        case 'tibetan':
          final decay = exp(-3.0 * (t % 1.5));
          leftSample = sin(2 * pi * 432 * t) * 0.5 * decay;
          rightSample = sin(2 * pi * 434 * t) * 0.5 * decay;
          break;

        case 'stream':
          final bubble = sin(2 * pi * (600 + sin(t * 8) * 200) * t) * 0.25;
          final noise = (random.nextDouble() * 2 - 1) * 0.2;
          leftSample = bubble + noise;
          rightSample = bubble * 0.9 + noise * 0.95;
          break;

        case 'nightcity':
          final hum = sin(2 * pi * 90 * t) * 0.3 + sin(2 * pi * 180 * t) * 0.15;
          final breeze = (random.nextDouble() * 2 - 1) * 0.15;
          leftSample = hum + breeze;
          rightSample = hum * 0.95 + breeze * 0.9;
          break;

        case 'noises':
          final pink = (random.nextDouble() * 2 - 1) * 0.35;
          leftSample = pink;
          rightSample = pink * 0.95;
          break;

        case 'leaves':
          final rustle = (sin(t * 3) > 0) ? (random.nextDouble() * 2 - 1) * 0.3 : 0.05;
          leftSample = rustle;
          rightSample = rustle * 0.9;
          break;

        case 'train':
          final rhythm = (sin(2 * pi * 4 * t) > 0.7) ? 0.4 : 0.05;
          final clack = (random.nextDouble() * 2 - 1) * rhythm;
          leftSample = clack;
          rightSample = clack * 0.85;
          break;

        case 'clock':
          final tick = (i % (sampleRate / 2).round() < 800)
              ? sin(2 * pi * 1800 * t) * exp(-20.0 * (t % 0.5)) * 0.6
              : 0.0;
          leftSample = tick;
          rightSample = tick * 0.9;
          break;

        case 'piano':
          final notes = [261.63, 293.66, 329.63, 392.00, 440.00, 523.25];
          final noteIdx = (t * 1.5).floor() % notes.length;
          final noteFreq = notes[noteIdx];
          final tNote = t % (1.0 / 1.5);
          final pDecay = exp(-4.0 * tNote);
          final tone = sin(2 * pi * noteFreq * t) * 0.4 * pDecay;
          leftSample = tone;
          rightSample = tone * 0.95;
          break;

        default:
          final defaultNoise = (random.nextDouble() * 2 - 1) * 0.3;
          leftSample = defaultNoise;
          rightSample = defaultNoise;
          break;
      }

      // Convert -1.0..1.0 float to 16-bit signed integer
      final int intLeft = (leftSample.clamp(-1.0, 1.0) * 32767).round();
      final int intRight = (rightSample.clamp(-1.0, 1.0) * 32767).round();

      bytes.setInt16(offset, intLeft, Endian.little);
      bytes.setInt16(offset + 2, intRight, Endian.little);
      offset += 4;
    }

    return bytes.buffer.asUint8List();
  }

  static Uint8List generateCustomSynthBuffer({
    required String waveType,
    required double freq,
    required String filterType,
    required double filterFreq,
    required double lfoFreq,
    double durationSeconds = 3.0,
  }) {
    final int numSamples = (sampleRate * durationSeconds).round();
    final int dataSize = numSamples * 4;
    final int fileSize = 44 + dataSize;
    final ByteData bytes = ByteData(fileSize);

    _writeString(bytes, 0, 'RIFF');
    bytes.setUint32(4, fileSize - 8, Endian.little);
    _writeString(bytes, 8, 'WAVE');
    _writeString(bytes, 12, 'fmt ');
    bytes.setUint32(16, 16, Endian.little);
    bytes.setUint16(20, 1, Endian.little);
    bytes.setUint16(22, 2, Endian.little);
    bytes.setUint32(24, sampleRate, Endian.little);
    bytes.setUint32(28, sampleRate * 4, Endian.little);
    bytes.setUint16(32, 4, Endian.little);
    bytes.setUint16(34, 16, Endian.little);
    _writeString(bytes, 36, 'data');
    bytes.setUint32(40, dataSize, Endian.little);

    final Random random = Random();
    int offset = 44;

    for (int i = 0; i < numSamples; i++) {
      final double t = i / sampleRate;
      final double lfo = sin(2 * pi * lfoFreq * t) * 0.3;

      double raw = 0.0;
      if (waveType == 'triangle') {
        raw = (asin(sin(2 * pi * freq * t)) * 2 / pi) * 0.5;
      } else if (waveType == 'sawtooth') {
        raw = ((t * freq) % 1.0 * 2 - 1) * 0.4;
      } else if (waveType == 'pink' || waveType == 'brown') {
        raw = (random.nextDouble() * 2 - 1) * 0.4;
      } else {
        // sine
        raw = sin(2 * pi * (freq + lfo * 20) * t) * 0.5;
      }

      final int sampleVal = ((raw + lfo * 0.1).clamp(-1.0, 1.0) * 32767).round();
      bytes.setInt16(offset, sampleVal, Endian.little);
      bytes.setInt16(offset + 2, sampleVal, Endian.little);
      offset += 4;
    }

    return bytes.buffer.asUint8List();
  }

  static void _writeString(ByteData data, int offset, String str) {
    for (int i = 0; i < str.length; i++) {
      data.setUint8(offset + i, str.codeUnitAt(i));
    }
  }
}
