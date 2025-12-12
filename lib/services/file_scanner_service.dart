import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../data/models/book_file_v2.dart';

class FileScannerService {
  static const List<String> _supportedExtensions = ['.pdf', '.epub'];

  static Future<List<BookFileV2>> scanForBooks() async {
    final List<BookFileV2> books = [];
    try {
      final directories = await _getSearchDirectories();
      for (final directory in directories) {
        if (await directory.exists()) {
          try {
            await for (final entity in directory.list(recursive: true, followLinks: false)) {
              if (entity is File) {
                final extension = _getFileExtension(entity.path).toLowerCase();
                if (_supportedExtensions.contains(extension)) {
                  final stat = await entity.stat();
                  books.add(BookFileV2(
                    id: _generateId(entity.path),
                    name: _getFileName(entity.path),
                    path: entity.path,
                    type: extension.substring(1),
                    size: stat.size,
                    lastModified: stat.modified,
                    dateAdded: stat.modified,
                    title: _extractTitle(entity.path),
                    author: _extractAuthorFromPath(entity.path),
                  ));
                }
              }
            }
          } catch (e) {
            // Ignore errors from inaccessible subdirectories
          }
        }
      }
    } catch (e) {
      // Top-level error
    }

    final uniqueBooks = <String, BookFileV2>{};
    for (final book in books) {
      uniqueBooks[book.path] = book;
    }
    return uniqueBooks.values.toList();
  }

  static Future<List<Directory>> _getSearchDirectories() async {
    final List<Directory> directories = [];
    if (Platform.isAndroid) {
      try {
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          final root = Directory('/storage/emulated/0');
          if (await root.exists()) {
            directories.add(root);
          }
        }
      } catch (e) {
        // Fallback for Android
      }
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      try {
        final downloads = await getDownloadsDirectory();
        final documents = await getApplicationDocumentsDirectory();
        if (documents != null) {
          directories.add(documents);
          try {
            final desktop = Directory(documents.parent.path + Platform.pathSeparator + 'Desktop');
            if(await desktop.exists()){
               directories.add(desktop);
            }
          } catch(e) {
            // Ignore if desktop path can't be determined
          }
        }
        if (downloads != null) {
          directories.add(downloads);
        }
      } catch (e) {
        // Error getting desktop directories
      }
    }
    return directories;
  }

  static String _generateId(String filePath) => filePath.hashCode.abs().toString();

  static String _getFileName(String filePath) => filePath.split(Platform.pathSeparator).last;

  static String _getFileExtension(String filePath) {
    final parts = filePath.split('.');
    return parts.length > 1 ? '.${parts.last}' : '';
  }

  static String _extractTitle(String filePath) {
    final fileName = _getFileName(filePath);
    final nameWithoutExtension = fileName.replaceAll(RegExp(r'\.(pdf|epub)$', caseSensitive: false), '');
    return nameWithoutExtension.replaceAll(RegExp(r'[_-]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static String? _extractAuthorFromPath(String filePath) {
    final fileName = _getFileName(filePath);
    final nameWithoutExtension = fileName.replaceAll(RegExp(r'\.(pdf|epub)$', caseSensitive: false), '');
    if (nameWithoutExtension.contains(' - ')) {
      final parts = nameWithoutExtension.split(' - ');
      if (parts.length >= 2 && parts[0].trim().length < 50) {
        return parts[0].trim();
      }
    }
    if (nameWithoutExtension.toLowerCase().contains(' by ')) {
      final parts = nameWithoutExtension.toLowerCase().split(' by ');
      if (parts.length >= 2) {
        return parts[1].trim().split(' ').take(3).join(' ');
      }
    }
    return null;
  }
}
