import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

class PermissionService {
  static Future<bool> requestStoragePermission() async {
    if (!Platform.isAndroid) {
      return true;
    }

    try {
      debugPrint('🔐 Requesting storage permissions...');

      // Try MANAGE_EXTERNAL_STORAGE first (Android 11+) for full access
      try {
        final manageStatus = await ph.Permission.manageExternalStorage
            .request();
        if (manageStatus.isGranted) {
          debugPrint(
            '✅ MANAGE_EXTERNAL_STORAGE permission granted - full access!',
          );
          return true;
        }
        debugPrint('⚠️ MANAGE_EXTERNAL_STORAGE denied');
      } catch (e) {
        debugPrint('⚠️ MANAGE_EXTERNAL_STORAGE not available: $e');
      }

      // Try basic storage permission
      final storageStatus = await ph.Permission.storage.request();
      if (storageStatus.isGranted) {
        debugPrint('✅ Basic storage permission granted');
        return true;
      }

      debugPrint(
        '⚠️ Basic storage permission denied, trying media permissions...',
      );

      // Try media permissions for Android 13+
      try {
        final mediaPermissions = await [
          ph.Permission.photos,
          ph.Permission.videos,
          ph.Permission.audio,
        ].request();

        final hasAnyMediaPermission = mediaPermissions.values.any(
          (s) => s.isGranted,
        );
        if (hasAnyMediaPermission) {
          debugPrint('✅ Media permissions granted');
          return true;
        }
      } catch (e) {
        debugPrint('⚠️ Media permissions not available: $e');
      }

      debugPrint('❌ No storage permissions granted - limited file access');
      return false;
    } catch (e) {
      debugPrint('❌ Permission request error: $e');
      return false;
    }
  }

  static Future<bool> hasStoragePermission() async {
    if (!Platform.isAndroid) {
      return true;
    }

    try {
      // Check MANAGE_EXTERNAL_STORAGE first (best access)
      try {
        final manageStatus = await ph.Permission.manageExternalStorage.status;
        if (manageStatus.isGranted) {
          return true;
        }
      } catch (e) {
        debugPrint('⚠️ MANAGE_EXTERNAL_STORAGE check failed: $e');
      }

      // Check basic storage permission
      final storageStatus = await ph.Permission.storage.status;
      if (storageStatus.isGranted) {
        return true;
      }

      // Check media permissions as fallback
      try {
        final mediaStatuses = await Future.wait([
          ph.Permission.photos.status,
          ph.Permission.videos.status,
          ph.Permission.audio.status,
        ]);

        final hasAnyMediaPermission = mediaStatuses.any(
          (status) => status.isGranted,
        );
        if (hasAnyMediaPermission) {
          return true;
        }
      } catch (e) {
        debugPrint('⚠️ Media permissions check failed: $e');
      }

      return false;
    } catch (e) {
      debugPrint('❌ Permission check error: $e');
      return false;
    }
  }

  static Future<bool> openAppSettings() async {
    try {
      return await ph.openAppSettings();
    } catch (e) {
      debugPrint('❌ Error opening app settings: $e');
      return false;
    }
  }
}
