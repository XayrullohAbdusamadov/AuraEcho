import 'package:flutter/cupertino.dart';
import '../models/capsule.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../theme/cupertino_theme.dart';

class ViewCapsuleModal extends StatelessWidget {
  final MemoryCapsule capsule;
  final VoidCallback onDeleted;
  final VoidCallback onPlaySound;

  const ViewCapsuleModal({
    super.key,
    required this.capsule,
    required this.onDeleted,
    required this.onPlaySound,
  });

  void _confirmDelete(BuildContext context) {
    AudioService().playTaptic('medium');
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text("Xotirani O'chirish"),
        content: const Text("Haqiqatan ham ushbu xotira kapsulasini o'chirib tashlamoqchimisiz? Bu amalni ortga qaytarib bo'lmaydi."),
        actions: [
          CupertinoDialogAction(
            child: const Text("Bekor qilish"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text("O'chirish"),
            onPressed: () {
              StorageService().deleteCapsule(capsule.id);
              AudioService().playTaptic('success');
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
              onDeleted();
            },
          ),
        ],
      ),
    );
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
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      "Yopish",
                      style: TextStyle(
                        color: isDark ? AppCupertinoTheme.darkSubtext : AppCupertinoTheme.lightSubtext,
                      ),
                    ),
                  ),
                  Text(
                    "Xotira Tafsilotlari",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppCupertinoTheme.darkText : AppCupertinoTheme.lightText,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _confirmDelete(context),
                    child: const Text(
                      "O'chirish",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppCupertinoTheme.iosRed,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Asosiy Xotira Kartasi
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                capsule.title,
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppCupertinoTheme.darkText : AppCupertinoTheme.lightText,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "📍 ${capsule.location} • ${capsule.formattedDate}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppCupertinoTheme.darkSubtext : AppCupertinoTheme.lightSubtext,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: capsule.moodColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            capsule.mood,
                            style: const TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (capsule.notes.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        capsule.notes,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.45,
                          color: isDark ? AppCupertinoTheme.darkText : AppCupertinoTheme.lightText,
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: capsule.tags.map((t) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppCupertinoTheme.iosBlue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            t,
                            style: const TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Telemetriya
              Text(
                "MUHRLANGAN SENSOR TELEMETRIYASI",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppCupertinoTheme.darkSubtext : AppCupertinoTheme.lightSubtext,
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text("Shovqin", style: TextStyle(fontSize: 11, color: isDark ? AppCupertinoTheme.darkSubtext : AppCupertinoTheme.lightSubtext)),
                          const SizedBox(height: 4),
                          Text("${capsule.telemetry.decibels} dB", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? AppCupertinoTheme.darkText : AppCupertinoTheme.lightText)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text("Yorug'lik", style: TextStyle(fontSize: 11, color: isDark ? AppCupertinoTheme.darkSubtext : AppCupertinoTheme.lightSubtext)),
                          const SizedBox(height: 4),
                          Text("${capsule.telemetry.lux} lux", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? AppCupertinoTheme.darkText : AppCupertinoTheme.lightText)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text("Uyg'unlik", style: TextStyle(fontSize: 11, color: isDark ? AppCupertinoTheme.darkSubtext : AppCupertinoTheme.lightSubtext)),
                          const SizedBox(height: 4),
                          Text("${capsule.telemetry.sensoryIndex}%", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppCupertinoTheme.iosGreen)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Tovushni Tinglash & Audio Yuklab Olish
              Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                      color: AppCupertinoTheme.iosBlue,
                      borderRadius: BorderRadius.circular(14),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      onPressed: () {
                        AudioService().applyPreset(capsule.soundPreset);
                        Navigator.of(context).pop();
                        onPlaySound();
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.play_arrow_solid, size: 16, color: Color(0xFFFFFFFF)),
                          SizedBox(width: 6),
                          Text(
                            "Tovushni Tinglash",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFFFFFF),
                            ),
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
                          target: capsule.soundPreset,
                          duration: 15,
                          fileName: "AuraEcho_${capsule.title.replaceAll(' ', '_')}.wav",
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.cloud_download, size: 16, color: isDark ? AppCupertinoTheme.darkText : AppCupertinoTheme.lightText),
                          const SizedBox(width: 6),
                          Text(
                            "Audio Yuklab Olish",
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
