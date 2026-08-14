import 'package:flutter/cupertino.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../theme/cupertino_theme.dart';
import '../widgets/telemetry_hud.dart';
import '../widgets/create_capsule_modal.dart';
import '../widgets/custom_synth_modal.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int) onNavigateTab;
  final VoidCallback onThemeChanged;

  const DashboardScreen({
    super.key,
    required this.onNavigateTab,
    required this.onThemeChanged,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  void _openCreateModal() {
    AudioService().playTaptic('light');
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CreateCapsuleModal(
        onSaved: () => setState(() {}),
      ),
    );
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
    final capsules = StorageService().capsules;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          "AuraEcho",
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isDark ? "Tungi" : "Tongi",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppCupertinoTheme.darkSubtext : AppCupertinoTheme.lightSubtext,
              ),
            ),
            const SizedBox(width: 8),
            CupertinoSwitch(
              value: StorageService().isDarkMode,
              onChanged: (val) async {
                AudioService().playTaptic('light');
                await StorageService().setDarkMode(val);
                widget.onThemeChanged();
              },
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // 1. Asosiy Xotira Muhrlash Banneri
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "SENSORLI XOTIRA & STUDIYA",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppCupertinoTheme.iosBlue,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppCupertinoTheme.iosGreen,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          "16 Fazoviy Tovush",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Lahzani Fazoviy Muhrlang",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppCupertinoTheme.darkText : AppCupertinoTheme.lightText,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Atrof-muhit akustikasi, yorug'lik va tebranish parametrlarini xotirangiz bilan birga saqlang hamda xohlagan audio miksingizni yuklab oling.",
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: isDark ? AppCupertinoTheme.darkSubtext : AppCupertinoTheme.lightSubtext,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: CupertinoButton(
                          color: AppCupertinoTheme.iosBlue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          borderRadius: BorderRadius.circular(12),
                          onPressed: _openCreateModal,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.add, size: 16, color: Color(0xFFFFFFFF)),
                              SizedBox(width: 6),
                              Text(
                                "Yangi Kapsula",
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFFFFFFF)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CupertinoButton(
                          color: isDark ? AppCupertinoTheme.darkSecondaryBg : AppCupertinoTheme.lightSecondaryBg,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          borderRadius: BorderRadius.circular(12),
                          onPressed: _openCustomSynthModal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.slider_horizontal_3, size: 16, color: isDark ? AppCupertinoTheme.darkText : AppCupertinoTheme.lightText),
                              const SizedBox(width: 6),
                              Text(
                                "Tovush Yaratish",
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

            const SizedBox(height: 16),

            // 2. Jonli Telemetriya & Sensorlar
            const TelemetryHud(),

            const SizedBox(height: 16),

            // 3. Tezkor Fazoviy Muhitlar & Presetlar
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                "TEZKOR FAZOVIY MUHITLAR & PRESETLAR",
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
                final isWide = constraints.maxWidth > 580;
                final presets = [
                  {'id': 'focus', 'name': 'Chuqur Diqqat', 'desc': "Yomg'ir + 6Hz Theta to'lqin", 'color': AppCupertinoTheme.iosBlue, 'icon': CupertinoIcons.waveform_path},
                  {'id': 'calm', 'name': 'Tinchlanish (Calm)', 'desc': "O'rmon, okean va tog' bulog'i", 'color': AppCupertinoTheme.iosGreen, 'icon': CupertinoIcons.tree},
                  {'id': 'meditation', 'name': 'Zen Meditatsiya', 'desc': 'Tibet kosasi + Kosmik dron', 'color': AppCupertinoTheme.iosPurple, 'icon': CupertinoIcons.bell_fill},
                  {'id': 'campfire', 'name': "Tog' Gulxani", 'desc': "Gulxan chirsillashi va shabada", 'color': AppCupertinoTheme.iosOrange, 'icon': CupertinoIcons.flame_fill},
                  {'id': 'storm', 'name': 'Tungi Momaqaldiroq', 'desc': 'Yomg\u2019ir va chaqmoq gulduragi', 'color': AppCupertinoTheme.iosIndigo, 'icon': CupertinoIcons.bolt_fill},
                  {'id': 'cafe', 'name': 'Qahvaxona & Yomg\u2019ir', 'desc': 'Issiq qahvaxona va deraza', 'color': AppCupertinoTheme.iosYellow, 'icon': CupertinoIcons.cart_fill},
                  {'id': 'creative', 'name': 'Pianino & Kuzgi Shamol', 'desc': 'Neoklassik akkordlar va barg', 'color': AppCupertinoTheme.iosPink, 'icon': CupertinoIcons.music_note_2},
                  {'id': 'train', 'name': 'Tungi Poyezd Relslari', 'desc': 'Gipnotik sokin relslar sadosi', 'color': AppCupertinoTheme.iosGray, 'icon': CupertinoIcons.car_detailed},
                ];

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isWide ? 2 : 1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: isWide ? 3.4 : 4.4,
                  ),
                  itemCount: presets.length,
                  itemBuilder: (context, index) {
                    final p = presets[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: p['color'] as Color,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(p['icon'] as IconData, color: const Color(0xFFFFFFFF), size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  p['name'] as String,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppCupertinoTheme.darkText : AppCupertinoTheme.lightText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  p['desc'] as String,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? AppCupertinoTheme.darkSubtext : AppCupertinoTheme.lightSubtext,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          CupertinoButton(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            color: isDark ? AppCupertinoTheme.darkSecondaryBg : AppCupertinoTheme.lightSecondaryBg,
                            borderRadius: BorderRadius.circular(10),
                            onPressed: () {
                              AudioService().applyPreset(p['id'] as String);
                              widget.onNavigateTab(1); // Tovushlar studiyasiga o'tish
                            },
                            child: Text(
                              "Tinglash",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppCupertinoTheme.darkText : AppCupertinoTheme.lightText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 16),

            // 4. Statistika
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Saqlangan Xotiralar", style: TextStyle(fontSize: 14, color: isDark ? AppCupertinoTheme.darkText : AppCupertinoTheme.lightText)),
                      Text("${capsules.length}", style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppCupertinoTheme.iosBlue)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Fazoviy Audio Dvigateli", style: TextStyle(fontSize: 14, color: isDark ? AppCupertinoTheme.darkText : AppCupertinoTheme.lightText)),
                      const Text("Web Audio API (16 Qatlam)", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppCupertinoTheme.iosGreen)),
                    ],
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
}
