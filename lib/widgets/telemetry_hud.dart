import 'package:flutter/cupertino.dart';
import '../models/capsule.dart';
import '../services/sensor_service.dart';
import '../theme/cupertino_theme.dart';

class TelemetryHud extends StatelessWidget {
  const TelemetryHud({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppCupertinoTheme.darkCard : AppCupertinoTheme.lightCard;
    final borderColor = isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA);

    return StreamBuilder<TelemetryData>(
      stream: SensorService().telemetryStream,
      initialData: SensorService().currentSnapshot,
      builder: (context, snapshot) {
        final data = snapshot.data ?? SensorService().currentSnapshot;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                "JONLI TELEMETRIYA & SENSORLAR",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppCupertinoTheme.darkSubtext : AppCupertinoTheme.lightSubtext,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: "Shovqin",
                    value: "${data.decibels}",
                    unit: "dB",
                    icon: CupertinoIcons.mic_fill,
                    fillPercent: (data.decibels / 100).clamp(0.0, 1.0),
                    fillColor: AppCupertinoTheme.iosBlue,
                    cardBg: cardBg,
                    borderColor: borderColor,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard(
                    title: "Yorug'lik",
                    value: "${data.lux}",
                    unit: "lux",
                    icon: CupertinoIcons.sun_max_fill,
                    fillPercent: (data.lux / 1000).clamp(0.0, 1.0),
                    fillColor: AppCupertinoTheme.iosOrange,
                    cardBg: cardBg,
                    borderColor: borderColor,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard(
                    title: "Uyg'unlik",
                    value: "${data.sensoryIndex}",
                    unit: "%",
                    icon: CupertinoIcons.heart_fill,
                    fillPercent: (data.sensoryIndex / 100).clamp(0.0, 1.0),
                    fillColor: AppCupertinoTheme.iosGreen,
                    cardBg: cardBg,
                    borderColor: borderColor,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // 3D Giroskop orientatsiyasi
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      Row(
                        children: [
                          Icon(CupertinoIcons.compass, size: 16, color: AppCupertinoTheme.iosBlue),
                          const SizedBox(width: 8),
                          Text(
                            "Fazoviy Giroskop Orientatsiyasi",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppCupertinoTheme.darkText : AppCupertinoTheme.lightText,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "X: ${data.tiltX > 0 ? '+' : ''}${data.tiltX}° | Y: ${data.tiltY > 0 ? '+' : ''}${data.tiltY}°",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppCupertinoTheme.darkSubtext : AppCupertinoTheme.lightSubtext,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 44,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? AppCupertinoTheme.darkSecondaryBg : AppCupertinoTheme.lightSecondaryBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Gorizontal chiziq
                        Container(height: 1, color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFD1D1D6)),
                        // Vertikal chiziq
                        Container(width: 1, color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFD1D1D6)),
                        // Giroskop pufakchasi
                        Transform.translate(
                          offset: Offset(data.tiltX * 2.0, data.tiltY * 1.5),
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              color: AppCupertinoTheme.iosBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required double fillPercent,
    required Color fillColor,
    required Color cardBg,
    required Color borderColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: isDark ? AppCupertinoTheme.darkSubtext : AppCupertinoTheme.lightSubtext),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppCupertinoTheme.darkSubtext : AppCupertinoTheme.lightSubtext,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppCupertinoTheme.darkText : AppCupertinoTheme.lightText,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppCupertinoTheme.darkSubtext : AppCupertinoTheme.lightSubtext,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Container(
              height: 4,
              color: isDark ? AppCupertinoTheme.darkSecondaryBg : AppCupertinoTheme.lightSecondaryBg,
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: fillPercent,
                child: Container(color: fillColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
