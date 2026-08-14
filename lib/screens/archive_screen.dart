import 'package:flutter/cupertino.dart';
import '../models/capsule.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../theme/cupertino_theme.dart';
import '../widgets/view_capsule_modal.dart';

class ArchiveScreen extends StatefulWidget {
  final Function(int) onNavigateTab;

  const ArchiveScreen({super.key, required this.onNavigateTab});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  final _searchController = TextEditingController();
  String _selectedMood = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCapsuleDetails(MemoryCapsule capsule) {
    AudioService().playTaptic('light');
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => ViewCapsuleModal(
        capsule: capsule,
        onDeleted: () => setState(() {}),
        onPlaySound: () => widget.onNavigateTab(1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppCupertinoTheme.darkCard : AppCupertinoTheme.lightCard;
    final borderColor = isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA);

    final filteredList = StorageService().filterCapsules(
      query: _searchController.text,
      mood: _selectedMood,
    );

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text(
          "Xotiralar Arxivi",
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 1. Qidiruv va Filtrlar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                children: [
                  CupertinoSearchTextField(
                    controller: _searchController,
                    placeholder: "Xotiralar, joylashuv yoki teglar bo'yicha...",
                    onChanged: (val) => setState(() {}),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoSegmentedControl<String>(
                      groupValue: _selectedMood,
                      children: const {
                        'all': Padding(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6), child: Text("Barchasi", style: TextStyle(fontSize: 12))),
                        'Xotirjamlik': Padding(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6), child: Text("Xotirjam", style: TextStyle(fontSize: 12))),
                        'Chuqur Diqqat': Padding(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6), child: Text("Diqqat", style: TextStyle(fontSize: 12))),
                        'Ilhom va Hayrat': Padding(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6), child: Text("Ilhom", style: TextStyle(fontSize: 12))),
                      },
                      onValueChanged: (val) => setState(() => _selectedMood = val),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Kapsulalar Ro'yxati
            Expanded(
              child: filteredList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: isDark ? AppCupertinoTheme.darkSecondaryBg : AppCupertinoTheme.lightSecondaryBg,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(CupertinoIcons.search, size: 28, color: isDark ? AppCupertinoTheme.darkSubtext : AppCupertinoTheme.lightSubtext),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Hech qanday xotira topilmadi",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppCupertinoTheme.darkText : AppCupertinoTheme.lightText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Qidiruv mezonini o'zgartiring yoki yangi kapsula yarating.",
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppCupertinoTheme.darkSubtext : AppCupertinoTheme.lightSubtext,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      itemCount: filteredList.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final cap = filteredList[index];
                        return GestureDetector(
                          onTap: () => _openCapsuleDetails(cap),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderColor),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: cap.moodColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(CupertinoIcons.sparkles, color: Color(0xFFFFFFFF), size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cap.title,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? AppCupertinoTheme.darkText : AppCupertinoTheme.lightText,
                                          letterSpacing: -0.3,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "${cap.location} • ${cap.formattedDate}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? AppCupertinoTheme.darkSubtext : AppCupertinoTheme.lightSubtext,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: cap.moodColor.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              cap.mood,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: cap.moodColor,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            "${cap.telemetry.decibels} dB",
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: isDark ? AppCupertinoTheme.darkSubtext : AppCupertinoTheme.lightSubtext,
                                            ),
                                          ),
                                        ],
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
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
