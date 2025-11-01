import 'dart:io';
import 'package:permission_handler/permission_handler.dart' as ph;

class PermissionService {
  static Future<bool> requestStoragePermission() async {
    if (!Platform.isAndroid) {
      return true;
    }

    try {
      // Try MANAGE_EXTERNAL_STORAGE first (Android 11+) for full access
      try {
        final manageStatus = await ph.Permission.manageExternalStorage
            .request();
        if (manageStatus.isGranted) {
          return true;
        }
      } catch (e) {
        // Silent error handling
      }

      // Try basic storage permission
      final storageStatus = await ph.Permission.storage.request();
      if (storageStatus.isGranted) {
        return true;
      }

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
          return true;
        }
      } catch (e) {
        // Silent error handling
      }

      return false;
    } catch (e) {
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
        // Silent error handling
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
        // Silent error handling
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> openAppSettings() async {
    try {
      return await ph.openAppSettings();
    } catch (e) {
      return false;
    }
  }
}
