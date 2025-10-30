class AppConstants {
  // App Information
  static const String appName = 'Book Reader';
  static const String appVersion = '2.0.0';
  static const String appDescription =
      'Your comprehensive digital library for PDF and EPUB files';

  // File Extensions
  static const List<String> supportedExtensions = ['.pdf', '.epub'];
  static const List<String> pdfExtensions = ['.pdf'];
  static const List<String> epubExtensions = ['.epub'];

  // Storage Keys
  static const String onboardingCompletedKey = 'onboarding_completed_v2';
  static const String firstLaunchKey = 'first_launch_v2';
  static const String userSettingsKey = 'user_settings_v2';
  static const String readingProgressKey = 'reading_progress_v2';
  static const String bookmarksKey = 'bookmarks_v2';
  static const String recentFilesKey = 'recent_files_v2';
  static const String readingStatsKey = 'reading_stats_v2';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;

  // Reading Settings
  static const double minFontSize = 12.0;
  static const double maxFontSize = 32.0;
  static const double defaultFontSize = 16.0;
  static const double fontSizeStep = 2.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // File Scanning
  static const List<String> scanDirectories = [
    '/storage/emulated/0/Download',
    '/storage/emulated/0/Downloads',
    '/storage/emulated/0/Documents',
    '/storage/emulated/0/Books',
  ];

  // Reading Modes
  static const String lightMode = 'light';
  static const String darkMode = 'dark';
  static const String sepiaMode = 'sepia';
  static const String nightMode = 'night';

  // Categories
  static const List<String> defaultCategories = [
    'All Books',
    'Recent',
    'PDF Files',
    'EPUB Files',
    'Favorites',
    'Unread',
  ];

  // Limits
  static const int maxRecentFiles = 20;
  static const int maxBookmarks = 100;
  static const int maxSearchResults = 50;

  // Error Messages
  static const String fileNotFoundError =
      'File not found or cannot be accessed';
  static const String permissionDeniedError =
      'Storage permission is required to access files';
  static const String corruptedFileError =
      'File appears to be corrupted or unsupported';
  static const String networkError =
      'Network connection required for this feature';

  // Success Messages
  static const String bookmarkAddedMessage = 'Bookmark added successfully';
  static const String bookmarkRemovedMessage = 'Bookmark removed';
  static const String settingsSavedMessage = 'Settings saved successfully';
}
