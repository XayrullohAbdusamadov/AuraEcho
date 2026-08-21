import 'dart:math';
import 'package:flutter/cupertino.dart';
import '../services/audio_service.dart';
import '../theme/cupertino_theme.dart';
import '../widgets/sound_card_widget.dart';
import '../widgets/custom_synth_modal.dart';

class AudioStudioScreen extends StatefulWidget {
  const AudioStudioScreen({super.key});

  @override
  State<AudioStudioScreen> createState() => _AudioStudioScreenState();
}

class _AudioStudioScreenState extends State<AudioStudioScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _openCustomSynthModal() {
    AudioService().playTaptic('light');
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => const CustomSynthModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppCupertinoTheme.darkCard : AppCupertinoTheme.lightCard;
    final borderColor = isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          "Fazoviy Tovushlar Studiyasi (16)",
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _openCustomSynthModal,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.add_circled_solid, size: 18),
              SizedBox(width: 4),
              Text("Sintezator", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
      child: SafeArea(
        child: ListenableBuilder(
          listenable: AudioService(),
          builder: (context, _) {
            final channels = AudioService().channels;
            final masterVol = AudioService().masterVolume;
            final activeChannelsCount = channels.where((c) => c.isActive).length;

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // 1. Spektr Vizualizatori & Master Eksport (Fully Overflow-Protected)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Wrappable Header Row for Narrow Mobile Screens
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppCupertinoTheme.iosBlue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(CupertinoIcons.waveform_path, color: Color(0xFFFFFFFF), size: 16),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Real Vaqtli Fazoviy Spektr",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppCupertinoTheme.darkText : AppCupertinoTheme.lightText,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CupertinoButton(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                color: AppCupertinoTheme.iosBlue,
                                borderRadius: BorderRadius.circular(10),
                                onPressed: () {
                                  AudioService().exportAudioToFile(
                                    target: 'active_mix',
                                    duration: 18,
                                    fileName: "AuraEcho_Fazoviy_Miks.wav",
                                  );
                                },
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(CupertinoIcons.cloud_download, size: 13, color: Color(0xFFFFFFFF)),
                                    SizedBox(width: 4),
                                    Text(
                                      "Miksni Yuklab Olish",
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFFFFFFF)),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              CupertinoButton(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                color: isDark ? AppCupertinoTheme.darkSecondaryBg : AppCupertinoTheme.lightSecondaryBg,
                                borderRadius: BorderRadius.circular(10),
                                onPressed: () => AudioService().stopAll(),
                                child: const Text(
                                  "To'xtatish",
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppCupertinoTheme.iosRed),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Canvas Spektr Vizualizatori
                      AnimatedBuilder(
                        animation: _animController,
                        builder: (context, _) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              height: 65,
                              width: double.infinity,
                              color: isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7),
                              child: CustomPaint(
                                painter: SpectrumPainter(
                                  progress: _animController.value,
                                  activeCount: activeChannelsCount,
                                  barColor: isDark ? const Color(0xFF0A84FF) : const Color(0xFF007AFF),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("20 Hz (Sub-Bass)", style: TextStyle(fontSize: 10, color: isDark ? AppCupertinoTheme.darkSubtext : AppCupertinoTheme.lightSubtext)),
                          Text("16 Qatlamli Garmonik Spektr", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isDark ? AppCupertinoTheme.darkSubtext : AppCupertinoTheme.lightSubtext)),
                          Text("20 kHz (Ultra-High)", style: TextStyle(fontSize: 10, color: isDark ? AppCupertinoTheme.darkSubtext : AppCupertinoTheme.lightSubtext)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // 2. Master Ovoz Boshqaruvi
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Umumiy Ovoz Balandligi (Master Volume)",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppCupertinoTheme.darkText : AppCupertinoTheme.lightText,
                            ),
                          ),
                          Text(
                            "${(masterVol * 100).round()}%",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppCupertinoTheme.iosBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(CupertinoIcons.volume_mute, size: 16, color: isDark ? AppCupertinoTheme.darkSubtext : AppCupertinoTheme.lightSubtext),
                          Expanded(
                            child: CupertinoSlider(
                              value: masterVol,
                              min: 0.0,
                              max: 1.0,
                              activeColor: AppCupertinoTheme.iosBlue,
                              onChanged: (val) => AudioService().setMasterVolume(val),
                            ),
                          ),
                          Icon(CupertinoIcons.volume_up, size: 16, color: isDark ? AppCupertinoTheme.darkSubtext : AppCupertinoTheme.lightSubtext),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 3. 16 ta Tovush Kartalari Grid
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    "16 TA FAZOVIY TOVUSH QATLAMLARI & YUKLAB OLISH",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppCupertinoTheme.darkSubtext : AppCupertinoTheme.lightSubtext,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    int crossAxisCount = 1;
                    if (width > 1100) {
                      crossAxisCount = 3;
                    } else if (width > 680) {
                      crossAxisCount = 2;
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        mainAxisExtent: 265, // Increased height to 265 to eliminate any bottom overflow
                      ),
                      itemCount: channels.length,
                      itemBuilder: (context, index) {
                        return SoundCardWidget(channel: channels[index]);
                      },
                    );
                  },
                ),

                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }
}

class SpectrumPainter extends CustomPainter {
  final double progress;
  final int activeCount;
  final Color barColor;

  SpectrumPainter({
    required this.progress,
    required this.activeCount,
    required this.barColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    const int barCount = 44;
    final barWidth = (size.width / barCount) - 3.0;

    for (int i = 0; i < barCount; i++) {
      final t = (progress * 2 * pi) + (i * 0.25);
      final wave = (sin(t) + cos(t * 1.7) + 2) / 4.0;
      final mult = activeCount > 0 ? (0.3 + (activeCount * 0.08).clamp(0.0, 0.7)) : 0.08;
      final barHeight = max(4.0, wave * (size.height - 10) * mult);

      final left = i * (barWidth + 3.0) + 2;
      final top = size.height - barHeight - 4;

      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, max(2.0, barWidth), barHeight),
        const Radius.circular(2.5),
      );
      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SpectrumPainter oldDelegate) => true;
}
