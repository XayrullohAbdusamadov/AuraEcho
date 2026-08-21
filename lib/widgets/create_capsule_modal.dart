import 'package:flutter/cupertino.dart';
import '../models/capsule.dart';
import '../services/sensor_service.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import '../theme/cupertino_theme.dart';

class CreateCapsuleModal extends StatefulWidget {
  final VoidCallback onSaved;

  const CreateCapsuleModal({super.key, required this.onSaved});

  @override
  State<CreateCapsuleModal> createState() => _CreateCapsuleModalState();
}

class _CreateCapsuleModalState extends State<CreateCapsuleModal> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedMood = "Xotirjamlik";
  Color _selectedMoodColor = const Color(0xFF34C759);
  String _selectedSound = "calm";
  final Set<String> _selectedTags = {"Tabiat", "Salqin shabada"};

  final List<String> _allTags = [
    "Tabiat", "Salqin shabada", "Tungi shahar", "Yomg'ir",
    "Qahva", "Ijodkorlik", "Gulxan", "Pianino", "Tog' havosi"
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveCapsule() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      AudioService().playTaptic('medium');
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text("Xatolik"),
          content: const Text("Iltimos, xotira nomini kiriting."),
          actions: [
            CupertinoDialogAction(
              child: const Text("Tushundim"),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      );
      return;
    }

    final capsule = MemoryCapsule(
      id: 'cap_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      mood: _selectedMood,
      moodColor: _selectedMoodColor,
      location: _locationController.text.trim().isEmpty ? "Noma'lum hudud" : _locationController.text.trim(),
      notes: _notesController.text.trim(),
      tags: _selectedTags.toList(),
      telemetry: SensorService().currentSnapshot,
      soundPreset: _selectedSound,
      createdAt: DateTime.now(),
    );

    StorageService().addCapsule(capsule);
    AudioService().playTaptic('success');
    widget.onSaved();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppCupertinoTheme.darkCard : AppCupertinoTheme.lightCard;
    final inputBg = isDark ? AppCupertinoTheme.darkSecondaryBg : AppCupertinoTheme.lightSecondaryBg;
    final snapshot = SensorService().currentSnapshot;

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
                      "Bekor qilish",
                      style: TextStyle(
                        color: isDark ? AppCupertinoTheme.darkSubtext : AppCupertinoTheme.lightSubtext,
                      ),
                    ),
                  ),
                  Text(
                    "Yangi Xotira Kapsulasi",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppCupertinoTheme.darkText : AppCupertinoTheme.lightText,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _saveCapsule,
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

              // Xotira Nomi
              _buildSectionTitle("XOTIRA NOMI", isDark),
              CupertinoTextField(
                controller: _titleController,
                placeholder: "Masalan: Zomin tog'lari shabadasi...",
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                style: TextStyle(
                  color: isDark ? AppCupertinoTheme.darkText : AppCupertinoTheme.lightText,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 14),

              // Hissiyot (Mood)
              _buildSectionTitle("HISSIYOT HOLATI (MOOD)", isDark),
              SizedBox(
                width: double.infinity,
                child: CupertinoSegmentedControl<String>(
                  groupValue: _selectedMood,
                  children: const {
                    'Xotirjamlik': Padding(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6), child: Text("Xotirjam", style: TextStyle(fontSize: 12))),
                    'Chuqur Diqqat': Padding(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6), child: Text("Diqqat", style: TextStyle(fontSize: 12))),
                    'Ilhom va Hayrat': Padding(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6), child: Text("Ilhom", style: TextStyle(fontSize: 12))),
                    'Quvonch': Padding(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6), child: Text("Quvonch", style: TextStyle(fontSize: 12))),
                  },
                  onValueChanged: (val) {
                    setState(() {
                      _selectedMood = val;
                      if (val == 'Xotirjamlik') _selectedMoodColor = const Color(0xFF34C759);
                      if (val == 'Chuqur Diqqat') _selectedMoodColor = const Color(0xFF007AFF);
                      if (val == 'Ilhom va Hayrat') _selectedMoodColor = const Color(0xFFAF52DE);
                      if (val == 'Quvonch') _selectedMoodColor = const Color(0xFFFF9500);
                    });
                  },
                ),
              ),
              const SizedBox(height: 14),

              // Joylashuv
              _buildSectionTitle("JOYLASHUV / MUHIT", isDark),
              CupertinoTextField(
                controller: _locationController,
                placeholder: "Masalan: Zomin milliy bog'i, Jizzax",
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                style: TextStyle(
                  color: isDark ? AppCupertinoTheme.darkText : AppCupertinoTheme.lightText,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 14),

              // Biriktiriladigan Fazoviy Tovush Muhiti
              _buildSectionTitle("FAZOVIY TOVUSH MUHITI", isDark),
              SizedBox(
                width: double.infinity,
                child: CupertinoSegmentedControl<String>(
                  groupValue: _selectedSound,
                  children: const {
                    'calm': Padding(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6), child: Text("Tinchlik", style: TextStyle(fontSize: 11))),
                    'focus': Padding(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6), child: Text("Yomg'ir", style: TextStyle(fontSize: 11))),
                    'meditation': Padding(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6), child: Text("Zen", style: TextStyle(fontSize: 11))),
                    'campfire': Padding(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6), child: Text("Gulxan", style: TextStyle(fontSize: 11))),
                    'creative': Padding(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6), child: Text("Pianino", style: TextStyle(fontSize: 11))),
                  },
                  onValueChanged: (val) => setState(() => _selectedSound = val),
                ),
              ),
              const SizedBox(height: 14),

              // Telemetriya Holati
              _buildSectionTitle("SENSOR TELEMETRIYA HOLATI", isDark),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text("Shovqin", style: TextStyle(fontSize: 11, color: isDark ? AppCupertinoTheme.darkSubtext : AppCupertinoTheme.lightSubtext)),
                          const SizedBox(height: 2),
                          Text("${snapshot.decibels} dB", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? AppCupertinoTheme.darkText : AppCupertinoTheme.lightText)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text("Yorug'lik", style: TextStyle(fontSize: 11, color: isDark ? AppCupertinoTheme.darkSubtext : AppCupertinoTheme.lightSubtext)),
                          const SizedBox(height: 2),
                          Text("${snapshot.lux} lux", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? AppCupertinoTheme.darkText : AppCupertinoTheme.lightText)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text("Uyg'unlik", style: TextStyle(fontSize: 11, color: isDark ? AppCupertinoTheme.darkSubtext : AppCupertinoTheme.lightSubtext)),
                          const SizedBox(height: 2),
                          Text("${snapshot.sensoryIndex}%", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppCupertinoTheme.iosGreen)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Sensorli Teglar
              _buildSectionTitle("SENSORLI TEGLAR", isDark),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allTags.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return GestureDetector(
                    onTap: () {
                      AudioService().playTaptic('light');
                      setState(() {
                        if (isSelected) {
                          _selectedTags.remove(tag);
                        } else {
                          _selectedTags.add(tag);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppCupertinoTheme.iosBlue
                            : (isDark ? AppCupertinoTheme.darkSecondaryBg : AppCupertinoTheme.lightSecondaryBg),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFFFFFFFF)
                              : (isDark ? AppCupertinoTheme.darkText : AppCupertinoTheme.lightText),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Xotira Tafsilotlari & Fikrlar
              _buildSectionTitle("XOTIRA TAFSILOTLARI & FIKRLAR", isDark),
              CupertinoTextField(
                controller: _notesController,
                placeholder: "Ushbu lahzada nimalarni his qildingiz? Atrof muhit qanday edi?",
                maxLines: 3,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                style: TextStyle(
                  color: isDark ? AppCupertinoTheme.darkText : AppCupertinoTheme.lightText,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),

              // Saqlash tugmasi
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: AppCupertinoTheme.iosBlue,
                  borderRadius: BorderRadius.circular(14),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  onPressed: _saveCapsule,
                  child: const Text(
                    "Kapsulani Muhrlash & Saqlash",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ),
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
