import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../theme/cupertino_theme.dart';

class AboutScreen extends StatefulWidget {
  final VoidCallback onDataChanged;

  const AboutScreen({super.key, required this.onDataChanged});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  Future<void> _launchTelegram() async {
    AudioService().playTaptic('medium');
    final Uri url = Uri.parse("https://t.me/HayrullohAdusamadov");
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  void _exportJson() {
    AudioService().playTaptic('medium');
    AudioService().exportAudioToFile(
      target: 'active_mix',
      duration: 1,
      fileName: "AuraEcho_Xotiralar_${DateTime.now().millisecondsSinceEpoch}.json",
    );
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text("JSON Eksport"),
        content: Text("Barcha xotiralar muvaffaqiyatli eksport qilindi (${StorageService().capsules.length} ta kapsula)."),
        actions: [
          CupertinoDialogAction(
            child: const Text("Tushundim"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  void _resetDefaults() {
    AudioService().playTaptic('medium');
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text("Qayta Tiklash"),
        content: const Text("Namunaviy xotiralarni dastlabki holatga qaytarmoqchimisiz?"),
        actions: [
          CupertinoDialogAction(
            child: const Text("Bekor qilish"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text("Tiklash"),
            onPressed: () async {
              await StorageService().resetToDefaults();
              AudioService().playTaptic('success');
              if (ctx.mounted) {
                Navigator.of(ctx).pop();
              }
              if (mounted) {
                widget.onDataChanged();
                setState(() {});
              }
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
    final borderColor = isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text(
          "Muallif va Tizim",
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // 1. Tizim Haqida
            _buildSectionHeader("TIZIM HAQIDA", isDark),
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  _buildListRow("Ilova Nomi", "AuraEcho v2.5 (Flutter)", isDark, isPrimary: true),
                  _buildDivider(isDark),
                  _buildListRow("Konsept", "Fazoviy Xotira & Sintezator", isDark),
                  _buildDivider(isDark),
                  _buildListRow("Tovushlar Studiyasi", "16 Qatlamli Web Audio Engine", isDark),
                  _buildDivider(isDark),
                  _buildListRow("Audio Eksport", "WAV Audio Yuklab Olish", isDark, isSuccess: true),
                  _buildDivider(isDark),
                  _buildListRow("Qurilmalar Mosligi", "Mobil, Planshet, Desktop", isDark),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 2. Ma'lumotlar Boshqaruvi
            _buildSectionHeader("MA'LUMOTLAR BOSHQARUVI", isDark),
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  _buildActionRow(
                    icon: CupertinoIcons.cloud_download_fill,
                    iconColor: AppCupertinoTheme.iosIndigo,
                    title: "Xotiralarni Eksport Qilish",
                    subtitle: "JSON zaxira nusxasini saqlash",
                    onTap: _exportJson,
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),
                  _buildActionRow(
                    icon: CupertinoIcons.arrow_counterclockwise_circle_fill,
                    iconColor: AppCupertinoTheme.iosRed,
                    title: "Boshlang'ich Holatga Qaytarish",
                    subtitle: "Namunaviy xotiralarni tiklash",
                    onTap: _resetDefaults,
                    isDark: isDark,
                    isDestructive: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 3. Majburiy Mualliflik Bo'limi
            _buildSectionHeader("MUALLIF VA ISHLAB CHIQISH", isDark),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          color: AppCupertinoTheme.iosBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(CupertinoIcons.person_crop_circle_fill, color: Color(0xFFFFFFFF), size: 32),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hayrulloh Abdusamadov",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppCupertinoTheme.darkText : AppCupertinoTheme.lightText,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Senior Flutter & Web UI/UX Architect",
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? AppCupertinoTheme.darkSubtext : AppCupertinoTheme.lightSubtext,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    "AuraEcho inson xotiralarini shunchaki matn sifatida emas, balki 16 qatlamli fazoviy tovush to'lqinlari, shaxsiy sintezator va akustik tebranish muhiti bilan birga saqlovchi hamda audio eksport qiluvchi professional sensorli platformadir.",
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: isDark ? AppCupertinoTheme.darkSubtext : AppCupertinoTheme.lightSubtext,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      color: AppCupertinoTheme.iosBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      borderRadius: BorderRadius.circular(14),
                      onPressed: _launchTelegram,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.paperplane_fill, size: 18, color: Color(0xFFFFFFFF)),
                          SizedBox(width: 8),
                          Text(
                            "Telegram Kanalga O'tish (t.me/HayrullohAdusamadov)",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 4. Majburiy Footer
            Center(
              child: Column(
                children: [
                  Text(
                    "AuraEcho — Fazoviy Xotira va Hissiyot Tizimi",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppCupertinoTheme.darkSubtext : AppCupertinoTheme.lightSubtext,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Yaratuvchi: Hayrulloh Abdusamadov",
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppCupertinoTheme.darkSubtext : AppCupertinoTheme.lightSubtext,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: _launchTelegram,
                    child: const Text(
                      "https://t.me/HayrullohAdusamadov",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppCupertinoTheme.iosBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
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

  Widget _buildListRow(String title, String value, bool isDark, {bool isPrimary = false, bool isSuccess = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppCupertinoTheme.darkText : AppCupertinoTheme.lightText,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isPrimary || isSuccess ? FontWeight.w600 : FontWeight.w400,
              color: isPrimary
                  ? AppCupertinoTheme.iosBlue
                  : (isSuccess
                      ? AppCupertinoTheme.iosGreen
                      : (isDark ? AppCupertinoTheme.darkSubtext : AppCupertinoTheme.lightSubtext)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: const Color(0x00000000), // hit test
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFFFFFFFF), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDestructive
                          ? AppCupertinoTheme.iosRed
                          : (isDark ? AppCupertinoTheme.darkText : AppCupertinoTheme.lightText),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppCupertinoTheme.darkSubtext : AppCupertinoTheme.lightSubtext,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: isDark ? AppCupertinoTheme.darkSubtext : AppCupertinoTheme.lightSubtext,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      height: 1,
      color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
    );
  }
}
