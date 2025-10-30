import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF4299E1);
  static const Color primaryDark = Color(0xFF2B6CB0);
  static const Color primaryLight = Color(0xFF90CDF4);

  // Secondary Colors
  static const Color secondary = Color(0xFF38A169);
  static const Color secondaryDark = Color(0xFF2F855A);
  static const Color secondaryLight = Color(0xFF68D391);

  // Accent Colors
  static const Color accent = Color(0xFF9F7AEA);
  static const Color accentDark = Color(0xFF805AD5);
  static const Color accentLight = Color(0xFFB794F6);

  // Neutral Colors
  static const Color background = Color(0xFFF7FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1A202C);
  static const Color surfaceLight = Color(0xFFF7FAFC);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A202C);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textTertiary = Color(0xFF718096);
  static const Color textLight = Color(0xFFA0AEC0);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF38A169);
  static const Color warning = Color(0xFFED8936);
  static const Color error = Color(0xFFE53E3E);
  static const Color info = Color(0xFF3182CE);

  // Reading Theme Colors
  static const Color readingLight = Color(0xFFFFFFFF);
  static const Color readingDark = Color(0xFF1A1A1A);
  static const Color readingSepia = Color(0xFFF4F1EA);
  static const Color readingNight = Color(0xFF0D1117);

  // PDF File Colors
  static const Color pdfPrimary = Color(0xFFE53E3E);
  static const Color pdfLight = Color(0xFFFED7D7);
  static const Color pdfDark = Color(0xFFC53030);

  // EPUB File Colors
  static const Color epubPrimary = Color(0xFF38A169);
  static const Color epubLight = Color(0xFFC6F6D5);
  static const Color epubDark = Color(0xFF2F855A);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
  );

  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
  );

  static const LinearGradient infoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF9D50BB), Color(0xFF6E48AA)],
  );

  // Shadow Colors
  static Color shadowLight = Colors.black.withValues(alpha: 0.1);
  static Color shadowMedium = Colors.black.withValues(alpha: 0.2);
  static Color shadowDark = Colors.black.withValues(alpha: 0.3);

  // Overlay Colors
  static Color overlayLight = Colors.white.withValues(alpha: 0.9);
  static Color overlayMedium = Colors.black.withValues(alpha: 0.5);
  static Color overlayDark = Colors.black.withValues(alpha: 0.7);

  // Border Colors
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderMedium = Color(0xFFCBD5E0);
  static const Color borderDark = Color(0xFFA0AEC0);

  // Category Colors
  static const List<Color> categoryColors = [
    Color(0xFF4299E1), // Blue
    Color(0xFF38A169), // Green
    Color(0xFF9F7AEA), // Purple
    Color(0xFFED8936), // Orange
    Color(0xFFE53E3E), // Red
    Color(0xFF3182CE), // Dark Blue
    Color(0xFF2F855A), // Dark Green
    Color(0xFF805AD5), // Dark Purple
  ];

  // Reading Progress Colors
  static const Color progressBackground = Color(0xFFE2E8F0);
  static const Color progressForeground = Color(0xFF4299E1);
  static const Color progressComplete = Color(0xFF38A169);

  // Bookmark Colors
  static const Color bookmarkActive = Color(0xFFED8936);
  static const Color bookmarkInactive = Color(0xFFA0AEC0);
}
