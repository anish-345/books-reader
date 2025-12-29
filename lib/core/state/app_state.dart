import 'package:flutter/material.dart';

import 'package:book_reader/core/constants/app_constants.dart';

class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  bool _isDarkMode = false;
  String _currentTheme = AppConstants.lightMode;

  bool get isDarkMode => _isDarkMode;
  String get currentTheme => _currentTheme;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _currentTheme = _isDarkMode
        ? AppConstants.darkMode
        : AppConstants.lightMode;
    notifyListeners();
  }

  void setTheme(String theme) {
    _currentTheme = theme;
    _isDarkMode = theme == AppConstants.darkMode;
    notifyListeners();
  }
}
