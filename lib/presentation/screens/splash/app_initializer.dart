import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:book_reader/core/constants/app_constants.dart';
import 'package:book_reader/presentation/screens/home/home_screen_v2.dart';
import 'package:book_reader/services/permission_service.dart';

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        await _requestPermissions();
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.firstLaunchKey, false);
      await prefs.setBool(AppConstants.onboardingCompletedKey, true);

      setState(() {
        _isInitializing = false;
      });
    } catch (e) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  Future<void> _requestPermissions() async {
    try {
      await PermissionService.requestStoragePermission();
    } catch (e) {
      // Silent error handling
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return const HomeScreenV2();
  }
}
