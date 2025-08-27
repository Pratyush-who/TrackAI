import 'package:flutter/material.dart';

class AppColors {
  static const Color darkPrimary = Color.fromRGBO(89, 183, 169, 1.0);

  static const Color darkSecondary = Color.fromRGBO(33, 43, 42, 1.0);
  static const Color darkBackground = Color.fromRGBO(25, 25, 25, 1.0);
  static const Color darkAccent = Color.fromRGBO(55, 200, 105, 1);
  static const Color darkCardBackground = Color.fromRGBO(35, 35, 35, 1.0);
  static const Color darkSurfaceColor = Color.fromRGBO(40, 40, 40, 1.0);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);

  static const Color lightPrimary = Color.fromRGBO(89, 183, 169, 1.0);
  static const Color lightSecondary = Color.fromRGBO(240, 248, 247, 1.0);
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightAccent = Color.fromRGBO(99, 207, 137, 1.0);
  static const Color lightCardBackground = Color(0xFFF8F9FA);
  static const Color lightSurfaceColor = Color(0xFFF5F5F5);
  static const Color lightTextPrimary = Color(0xFF000000);
  static const Color lightTextSecondary = Color(0xFF666666);

  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  static const Color darkGrey = Color.fromRGBO(45, 45, 45, 1.0);
  static const Color lightGrey = Color.fromRGBO(128, 128, 128, 1.0);
  static const Color errorColor = Color(0xFFFF6B6B);
  static const Color successColor = Color.fromRGBO(99, 207, 137, 1.0);
  static const Color warningColor = Color(0xFFFFB347);

  static Color primary(bool isDark) => isDark ? darkPrimary : lightPrimary;
  static Color secondary(bool isDark) =>
      isDark ? darkSecondary : lightSecondary;
  static Color background(bool isDark) =>
      isDark ? darkBackground : lightBackground;
  static Color accent(bool isDark) => isDark ? darkAccent : lightAccent;
  static Color cardBackground(bool isDark) =>
      isDark ? darkCardBackground : lightCardBackground;
  static Color surfaceColor(bool isDark) =>
      isDark ? darkSurfaceColor : lightSurfaceColor;
  static Color textPrimary(bool isDark) =>
      isDark ? darkTextPrimary : lightTextPrimary;
  static Color textSecondary(bool isDark) =>
      isDark ? darkTextSecondary : lightTextSecondary;
  static Color textDisabled(bool isDark) =>
      isDark ? Color(0xFF707070) : Color(0xFFB0B0B0);

  static const List<Color> darkPrimaryGradient = [
    Color.fromRGBO(95, 200, 185, 1.0),
    Color.fromRGBO(99, 207, 137, 1.0),
  ];

  static const List<Color> darkBackgroundGradient = [
    Color.fromRGBO(25, 25, 25, 1.0),
    Color.fromRGBO(35, 35, 35, 1.0),
  ];

  static const List<Color> darkCardGradient = [
    Color.fromRGBO(40, 50, 49, 1.0),
    Color.fromRGBO(33, 43, 42, 1.0),
  ];

  static const List<Color> darkAccentGradient = [
    Color.fromRGBO(89, 183, 169, 1.0),
    Color.fromRGBO(99, 207, 137, 1.0),
  ];

  static const List<Color> lightPrimaryGradient = [
    Color.fromRGBO(95, 200, 185, 1.0),
    Color.fromRGBO(99, 207, 137, 1.0),
  ];

  static const List<Color> lightBackgroundGradient = [
    Color(0xFFFFFFFF),
    Color(0xFFF8F9FA),
  ];

  static const List<Color> lightCardGradient = [
    Color(0xFFF8F9FA),
    Color(0xFFFFFFFF),
  ];

  static const List<Color> lightAccentGradient = [
    Color.fromRGBO(89, 183, 169, 1.0),
    Color.fromRGBO(99, 207, 137, 1.0),
  ];

  static List<Color> primaryGradient(bool isDark) =>
      isDark ? darkPrimaryGradient : lightPrimaryGradient;
  static List<Color> backgroundGradient(bool isDark) =>
      isDark ? darkBackgroundGradient : lightBackgroundGradient;
  static List<Color> cardGradient(bool isDark) =>
      isDark ? darkCardGradient : lightCardGradient;
  static List<Color> accentGradient(bool isDark) =>
      isDark ? darkAccentGradient : lightAccentGradient;

  static LinearGradient primaryLinearGradient(bool isDark) => LinearGradient(
    colors: primaryGradient(isDark),
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient backgroundLinearGradient(bool isDark) => LinearGradient(
    colors: backgroundGradient(isDark),
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient cardLinearGradient(bool isDark) => LinearGradient(
    colors: cardGradient(isDark),
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient accentLinearGradient(bool isDark) => LinearGradient(
    colors: accentGradient(isDark),
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient appBarGradient = LinearGradient(
    colors: [
      Color.fromRGBO(95, 200, 185, 1.0),
      Color.fromRGBO(99, 207, 137, 1.0),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static Color shimmerBase(bool isDark) =>
      isDark ? Color.fromRGBO(40, 40, 40, 1.0) : Color(0xFFE0E0E0);
  static Color shimmerHighlight(bool isDark) =>
      isDark ? Color.fromRGBO(60, 60, 60, 1.0) : Color(0xFFF5F5F5);

  static const Color bottomNavSelected = Color.fromRGBO(99, 207, 137, 1.0);
  static Color bottomNavUnselected(bool isDark) =>
      isDark ? Color.fromRGBO(128, 128, 128, 1.0) : Color(0xFF9E9E9E);

  static Color inputFill(bool isDark) =>
      isDark ? Color.fromRGBO(40, 40, 40, 1.0) : Color(0xFFF5F5F5);
  static const Color inputBorder = Color.fromRGBO(89, 183, 169, 1.0);
  static const Color inputFocusedBorder = Color.fromRGBO(99, 207, 137, 1.0);
}
