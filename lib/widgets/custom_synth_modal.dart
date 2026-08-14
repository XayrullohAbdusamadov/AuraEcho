import 'package:flutter/cupertino.dart';
import '../services/audio_service.dart';
import '../theme/cupertino_theme.dart';

class CustomSynthModal extends StatefulWidget {
  const CustomSynthModal({super.key});

  @override
  State<CustomSynthModal> createState() => _CustomSynthModalState();
}

class _CustomSynthModalState extends State<CustomSynthModal> {
  String _waveType = 'sine';
  double _freq = 220.0;
  String _filterType = 'lowpass';
  double _filterFreq = 800.0;
  double _lfoFreq = 2.0;
  final double _lfoDepth = 50.0;

  void _triggerLiveUpdate() {
    if (AudioService().isCustomSoundPlaying) {
      AudioService().startCustomSound(
        waveType: _waveType,
        freq: _freq,
        filterType: _filterType,
        filterFreq: _filterFreq,
        lfoFreq: _lfoFreq,
        lfoDepth: _lfoDepth,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppCupertinoTheme.darkCard : AppCupertinoTheme.lightCard;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppCupertinoTheme.darkBg : AppCupertinoTheme.lightBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sheet Handle
              Center(
                child: Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF48484A) : const Color(0xFFC7C7CC),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      AudioService().stopCustomSound();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "Yopish",
                      style: TextStyle(
                        color: isDark ? AppCupertinoTheme.darkSubtext : AppCupertinoTheme.lightSubtext,
                      ),
                    ),
                  ),
                  Text(
                    "Shaxsiy Tovush Studiyasi",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppCupertinoTheme.darkText : AppCupertinoTheme.lightText,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      AudioService().playTaptic('success');
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      "Saqlash",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppCupertinoTheme.iosBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // To'lqin Shakli Tanlash
              _buildSectionTitle("GENERATOR TURI (WAVEFORM)", isDark),
              SizedBox(
                width: double.infinity,
                child: CupertinoSegmentedControl<String>(
                  groupValue: _waveType,
                  children: const {
                    'sine': Padding(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6), child: Text("Sinus", style: TextStyle(fontSize: 12))),
                    'triangle': Padding(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6), child: Text("Uchburchak", style: TextStyle(fontSize: 12))),
                    'sawtooth': Padding(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6), child: Text("Arrasimon", style: TextStyle(fontSize: 12))),
                    'pink': Padding(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6), child: Text("Pushti", style: TextStyle(fontSize: 12))),
                  },
                  onValueChanged: (val) {
                    setState(() => _waveType = val);
                    _triggerLiveUpdate();
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Asosiy Chastota (Pitch Hz)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Asosiy Chastota (Hz)", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDark ? AppCupertinoTheme.darkText : AppCupertinoTheme.lightText)),
                        Text("${_freq.round()} Hz", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppCupertinoTheme.iosBlue)),
                      ],
                    ),
                    CupertinoSlider(
                      value: _freq,
                      min: 40.0,
                      max: 1200.0,
                      activeColor: AppCupertinoTheme.iosBlue,
                      onChanged: (val) {
                        setState(() => _freq = val);
                        _triggerLiveUpdate();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Rezonansli Filtr Turi
              _buildSectionTitle("REZONANSLI FILTR TURI", isDark),
              SizedBox(
                width: double.infinity,
                child: CupertinoSegmentedControl<String>(
                  groupValue: _filterType,
                  children: const {
                    'lowpass': Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6), child: Text("Lowpass", style: TextStyle(fontSize: 12))),
                    'bandpass': Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6), child: Text("Bandpass", style: TextStyle(fontSize: 12))),
                    'highpass': Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6), child: Text("Highpass", style: TextStyle(fontSize: 12))),
                  },
                  onValueChanged: (val) {
                    setState(() => _filterType = val);
                    _triggerLiveUpdate();
                  },
                ),
              ),
              const SizedBox(height: 14),

              // Filtr Kesish Chastotasi
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Filtr Kesish Chastotasi (Cutoff)", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDark ? AppCupertinoTheme.darkText : AppCupertinoTheme.lightText)),
                        Text("${_filterFreq.round()} Hz", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppCupertinoTheme.iosGreen)),
                      ],
                    ),
                    CupertinoSlider(
                      value: _filterFreq,
                      min: 100.0,
                      max: 4000.0,
                      activeColor: AppCupertinoTheme.iosGreen,
                      onChanged: (val) {
                        setState(() => _filterFreq = val);
                        _triggerLiveUpdate();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // LFO Tebranish Tezligi
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("LFO Modulyatsiya Tezligi", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDark ? AppCupertinoTheme.darkText : AppCupertinoTheme.lightText)),
                        Text("${_lfoFreq.toStringAsFixed(1)} Hz", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppCupertinoTheme.iosPurple)),
                      ],
                    ),
                    CupertinoSlider(
                      value: _lfoFreq,
                      min: 0.1,
                      max: 15.0,
                      activeColor: AppCupertinoTheme.iosPurple,
                      onChanged: (val) {
                        setState(() => _lfoFreq = val);
                        _triggerLiveUpdate();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Tugmalar: Sinash & Audio Yuklab Olish
              ListenableBuilder(
                listenable: AudioService(),
                builder: (context, _) {
                  final isPlaying = AudioService().isCustomSoundPlaying;

                  return Row(
                    children: [
                      Expanded(
                        child: CupertinoButton(
                          color: isPlaying ? AppCupertinoTheme.iosRed : AppCupertinoTheme.iosBlue,
                          borderRadius: BorderRadius.circular(14),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          onPressed: () {
                            if (isPlaying) {
                              AudioService().stopCustomSound();
                            } else {
                              AudioService().startCustomSound(
                                waveType: _waveType,
                                freq: _freq,
                                filterType: _filterType,
                                filterFreq: _filterFreq,
                                lfoFreq: _lfoFreq,
                                lfoDepth: _lfoDepth,
                              );
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(isPlaying ? CupertinoIcons.stop_fill : CupertinoIcons.play_fill, size: 16, color: const Color(0xFFFFFFFF)),
                              const SizedBox(width: 6),
                              Text(
                                isPlaying ? "To'xtatish" : "Tovushni Sinash",
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFFFFFFF)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CupertinoButton(
                          color: isDark ? AppCupertinoTheme.darkSecondaryBg : AppCupertinoTheme.lightSecondaryBg,
                          borderRadius: BorderRadius.circular(14),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          onPressed: () {
                            AudioService().exportAudioToFile(
                              target: 'custom',
                              duration: 15,
                              fileName: "AuraEcho_Shaxsiy_Tovush.wav",
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.cloud_download, size: 16, color: isDark ? AppCupertinoTheme.darkText : AppCupertinoTheme.lightText),
                              const SizedBox(width: 6),
                              Text(
                                "Yuklab Olish",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppCupertinoTheme.darkText : AppCupertinoTheme.lightText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDark ? AppCupertinoTheme.darkSubtext : AppCupertinoTheme.lightSubtext,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
