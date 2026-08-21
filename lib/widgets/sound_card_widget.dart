import 'package:flutter/cupertino.dart';
import '../models/sound_channel.dart';
import '../services/audio_service.dart';
import '../theme/cupertino_theme.dart';

class SoundCardWidget extends StatelessWidget {
  final SoundChannel channel;

  const SoundCardWidget({
    super.key,
    required this.channel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppCupertinoTheme.darkCard : AppCupertinoTheme.lightCard;
    final borderColor = channel.isActive
        ? AppCupertinoTheme.iosBlue
        : (isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: channel.isActive ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sarlavha, Icon, Switch va Play/Pause
          Row(
            children: [
              // Play / Pause Icon Button
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  AudioService().toggleChannel(channel.id, !channel.isActive);
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: channel.isActive
                        ? AppCupertinoTheme.iosBlue
                        : (isDark ? AppCupertinoTheme.darkSecondaryBg : AppCupertinoTheme.lightSecondaryBg),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    channel.isActive ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                    size: 14,
                    color: channel.isActive
                        ? const Color(0xFFFFFFFF)
                        : (isDark ? AppCupertinoTheme.darkText : AppCupertinoTheme.lightText),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Solid Icon Box
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: channel.color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(channel.icon, color: const Color(0xFFFFFFFF), size: 17),
              ),
              const SizedBox(width: 8),

              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      channel.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppCupertinoTheme.darkText : AppCupertinoTheme.lightText,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      channel.subtitle,
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

              const SizedBox(width: 4),

              // Cupertino Switch
              CupertinoSwitch(
                value: channel.isActive,
                activeTrackColor: AppCupertinoTheme.iosGreen,
                onChanged: (val) {
                  AudioService().toggleChannel(channel.id, val);
                },
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Ovoz kuchi (Volume)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Ovoz kuchi",
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppCupertinoTheme.darkSubtext : AppCupertinoTheme.lightSubtext,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                channel.volumeLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppCupertinoTheme.iosBlue,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 32,
            child: CupertinoSlider(
              value: channel.volume,
              min: 0.0,
              max: 1.0,
              activeColor: AppCupertinoTheme.iosBlue,
              onChanged: (val) {
                AudioService().setVolume(channel.id, val);
              },
            ),
          ),

          // Stereo Pan (Chap / O'ng)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Stereo Pan",
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppCupertinoTheme.darkSubtext : AppCupertinoTheme.lightSubtext,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                channel.panLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppCupertinoTheme.darkSubtext : AppCupertinoTheme.lightSubtext,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 32,
            child: CupertinoSlider(
              value: channel.pan,
              min: -1.0,
              max: 1.0,
              activeColor: AppCupertinoTheme.iosPurple,
              onChanged: (val) {
                AudioService().setPan(channel.id, val);
              },
            ),
          ),

          const SizedBox(height: 6),

          // Yuklab Olish Tugmasi
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 7),
              color: isDark ? AppCupertinoTheme.darkSecondaryBg : AppCupertinoTheme.lightSecondaryBg,
              borderRadius: BorderRadius.circular(10),
              onPressed: () {
                AudioService().exportAudioToFile(
                  target: channel.id,
                  duration: 15,
                  fileName: "AuraEcho_${channel.id}.wav",
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.cloud_download, size: 14, color: isDark ? AppCupertinoTheme.darkText : AppCupertinoTheme.lightText),
                  const SizedBox(width: 6),
                  Text(
                    "Ushbu Tovushni Yuklab Olish",
                    style: TextStyle(
                      fontSize: 11,
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
    );
  }
}
