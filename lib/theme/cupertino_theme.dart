import 'package:flutter/cupertino.dart';

/// Apple iOS Cupertino Dizayn Tizimi (Strict Flat Colors - No Gradients)
class AppCupertinoTheme {
  // Apple iOS Flat Ranglar
  static const Color iosBlue = Color(0xFF007AFF);
  static const Color iosGreen = Color(0xFF34C759);
  static const Color iosIndigo = Color(0xFF5856D6);
  static const Color iosOrange = Color(0xFFFF9500);
  static const Color iosPink = Color(0xFFFF2D55);
  static const Color iosPurple = Color(0xFFAF52DE);
  static const Color iosRed = Color(0xFFFF3B30);
  static const Color iosTeal = Color(0xFF5AC8FA);
  static const Color iosYellow = Color(0xFFFFCC00);
  static const Color iosGray = Color(0xFF8E8E93);
  static const Color iosGray2 = Color(0xFFAEAEB2);
  static const Color iosGray3 = Color(0xFFC7C7CC);
  static const Color iosGray4 = Color(0xFFD1D1D6);
  static const Color iosGray5 = Color(0xFFE5E5EA);
  static const Color iosGray6 = Color(0xFFF2F2F7);

  // Tongi Rejim (Light Mode)
  static const Color lightBg = Color(0xFFF2F2F7);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightSecondaryBg = Color(0xFFE5E5EA);
  static const Color lightSeparator = Color(0xFFC6C6C8);
  static const Color lightText = Color(0xFF000000);
  static const Color lightSubtext = Color(0xFF8E8E93);

  // Tungi Rejim (Dark Mode)
  static const Color darkBg = Color(0xFF000000);
  static const Color darkCard = Color(0xFF1C1C1E);
  static const Color darkSecondaryBg = Color(0xFF2C2C2E);
  static const Color darkSeparator = Color(0xFF38383A);
  static const Color darkText = Color(0xFFFFFFFF);
  static const Color darkSubtext = Color(0xFF8E8E93);

  static CupertinoThemeData lightTheme() {
    return const CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: iosBlue,
      primaryContrastingColor: Color(0xFFFFFFFF),
      barBackgroundColor: lightBg,
      scaffoldBackgroundColor: lightBg,
      textTheme: CupertinoTextThemeData(
        primaryColor: lightText,
        textStyle: TextStyle(
          color: lightText,
          fontFamily: '.SF Pro Text',
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  static CupertinoThemeData darkTheme() {
    return const CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: Color(0xFF0A84FF),
      primaryContrastingColor: Color(0xFFFFFFFF),
      barBackgroundColor: darkBg,
      scaffoldBackgroundColor: darkBg,
      textTheme: CupertinoTextThemeData(
        primaryColor: darkText,
        textStyle: TextStyle(
          color: darkText,
          fontFamily: '.SF Pro Text',
          letterSpacing: -0.3,
        ),
      ),
    );
  }
}
