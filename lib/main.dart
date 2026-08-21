import 'package:flutter/cupertino.dart';
import 'services/audio_service.dart';
import 'services/storage_service.dart';
import 'theme/cupertino_theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/audio_studio_screen.dart';
import 'screens/archive_screen.dart';
import 'screens/about_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService().init();
  runApp(const AuraEchoApp());
}

class AuraEchoApp extends StatefulWidget {
  const AuraEchoApp({super.key});

  @override
  State<AuraEchoApp> createState() => _AuraEchoAppState();
}

class _AuraEchoAppState extends State<AuraEchoApp> {
  void _toggleTheme() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = StorageService().isDarkMode;

    return CupertinoApp(
      title: 'AuraEcho',
      debugShowCheckedModeBanner: false,
      theme: isDark ? AppCupertinoTheme.darkTheme() : AppCupertinoTheme.lightTheme(),
      home: MainTabScaffold(onThemeChanged: _toggleTheme),
    );
  }
}

class MainTabScaffold extends StatefulWidget {
  final VoidCallback onThemeChanged;

  const MainTabScaffold({super.key, required this.onThemeChanged});

  @override
  State<MainTabScaffold> createState() => _MainTabScaffoldState();
}

class _MainTabScaffoldState extends State<MainTabScaffold> {
  final CupertinoTabController _tabController = CupertinoTabController();

  void _navigateToTab(int index) {
    AudioService().playTaptic('light');
    _tabController.index = index;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return CupertinoTabScaffold(
      controller: _tabController,
      tabBar: CupertinoTabBar(
        backgroundColor: isDark ? AppCupertinoTheme.darkCard : AppCupertinoTheme.lightCard,
        activeColor: AppCupertinoTheme.iosBlue,
        inactiveColor: isDark ? AppCupertinoTheme.darkSubtext : AppCupertinoTheme.lightSubtext,
        onTap: (index) {
          AudioService().playTaptic('light');
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house_fill),
            label: 'Boshqaruv',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.music_note_list),
            label: 'Tovushlar (16)',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.archivebox_fill),
            label: 'Arxiv',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.info_circle_fill),
            label: 'Haqida',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(
              builder: (ctx) => DashboardScreen(
                onNavigateTab: _navigateToTab,
                onThemeChanged: widget.onThemeChanged,
              ),
            );
          case 1:
            return CupertinoTabView(
              builder: (ctx) => const AudioStudioScreen(),
            );
          case 2:
            return CupertinoTabView(
              builder: (ctx) => ArchiveScreen(
                onNavigateTab: _navigateToTab,
              ),
            );
          case 3:
            return CupertinoTabView(
              builder: (ctx) => AboutScreen(
                onDataChanged: () => setState(() {}),
              ),
            );
          default:
            return CupertinoTabView(
              builder: (ctx) => DashboardScreen(
                onNavigateTab: _navigateToTab,
                onThemeChanged: widget.onThemeChanged,
              ),
            );
        }
      },
    );
  }
}
