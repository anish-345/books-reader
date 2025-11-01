import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../data/models/book_file_v2.dart';

class FileScannerService {
  static const List<String> _supportedExtensions = ['.pdf', '.epub'];

  /// Scan device for PDF and EPUB files
  static Future<List<BookFileV2>> scanForBooks() async {
    final List<BookFileV2> books = [];

    try {
      // Clean up any existing test files first
      await _cleanupTestFiles();

      // Get external storage directories
      final directories = await _getSearchDirectories();

      for (final directory in directories) {
        try {
          if (await directory.exists()) {
            final foundBooks = await _scanDirectory(directory);
            books.addAll(foundBooks);
          }
        } catch (e) {
          // Silent error handling
        }
      }

      // Remove duplicates based on file path
      final uniqueBooks = <String, BookFileV2>{};
      for (final book in books) {
        uniqueBooks[book.path] = book;
      }

      return uniqueBooks.values.toList();
    } catch (e) {
      return [];
    }
  }

  /// Get directories to search for books
  static Future<List<Directory>> _getSearchDirectories() async {
    final List<Directory> directories = [];

    try {
      // Get proper external storage paths using path_provider
      try {
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          // Get the actual external storage root
          final externalRoot = Directory('/storage/emulated/0');
          if (await externalRoot.exists()) {
            directories.add(externalRoot);

            // Scan ALL subdirectories in external storage
            await for (final entity in externalRoot.list(followLinks: false)) {
              if (entity is Directory) {
                try {
                  final dirName = entity.path.split('/').last.toLowerCase();
                  // Include ALL user directories except system ones
                  if (!dirName.startsWith('.') &&
                      !dirName.startsWith('android') &&
                      dirName != 'lost+found' &&
                      !dirName.contains('cache')) {
                    directories.add(entity);
                  }
                } catch (e) {
                  // Silent error handling
                }
              }
            }
          }
        }
      } catch (e) {
        // Fallback to hardcoded path
        final fallbackStorage = Directory('/storage/emulated/0');
        if (await fallbackStorage.exists()) {
          directories.add(fallbackStorage);
        }
      }

      // Also add common paths that might exist
      final commonPaths = [
        '/storage/emulated/0/Download',
        '/storage/emulated/0/Downloads',
        '/storage/emulated/0/Documents',
        '/storage/emulated/0/Books',
        '/storage/emulated/0/DCIM',
        '/storage/emulated/0/Pictures',
        '/storage/emulated/0/Music',
        '/storage/emulated/0/Movies',
        '/storage/emulated/0/Audiobooks',
        '/storage/emulated/0/Podcasts',
        '/storage/emulated/0/WhatsApp/Media/WhatsApp Documents',
        '/storage/emulated/0/Telegram',
        '/storage/emulated/0/bluetooth',
        '/sdcard/Download',
        '/sdcard/Downloads',
        '/sdcard/Documents',
        '/sdcard/Books',
      ];

      for (final path in commonPaths) {
        try {
          final dir = Directory(path);
          if (await dir.exists() && !directories.any((d) => d.path == path)) {
            directories.add(dir);
          }
        } catch (e) {
          // Silent error handling
        }
      }
    } catch (e) {
      // Silent error handling
    }

    return directories;
  }

  /// Scan a directory for book files (with limited recursion)
  static Future<List<BookFileV2>> _scanDirectory(Directory directory) async {
    final List<BookFileV2> books = [];

    try {
      await for (final entity in directory.list(
        recursive: false, // Non-recursive to avoid permission issues
        followLinks: false,
      )) {
        if (entity is File) {
          final extension = _getFileExtension(entity.path).toLowerCase();

          if (_supportedExtensions.contains(extension)) {
            try {
              final stat = await entity.stat();
              final book = BookFileV2(
                id: _generateId(entity.path),
                name: _getFileName(entity.path),
                title: _extractTitle(entity.path),
                path: entity.path,
                type: extension == '.pdf' ? 'pdf' : 'epub',
                size: stat.size,
                lastModified: stat.modified,
                dateAdded: stat.modified,
                author: _extractAuthorFromPath(entity.path),
              );
              books.add(book);
            } catch (e) {
              // Silent error handling
            }
          }
        } else if (entity is Directory) {
          // Scan subdirectories recursively for comprehensive coverage
          final dirName = entity.path.split('/').last.toLowerCase();
          if (!dirName.startsWith('.') &&
              !dirName.startsWith('android') &&
              !dirName.contains('cache') &&
              dirName != 'lost+found') {
            try {
              final subBooks = await _scanDirectoryRecursive(
                entity,
                0,
                2,
              ); // Max 2 levels deep
              books.addAll(subBooks);
            } catch (e) {
              // Silent error handling
            }
          }
        }
      }
    } catch (e) {
      // Silent error handling
    }

    return books;
  }

  /// Recursively scan directory with depth limit
  static Future<List<BookFileV2>> _scanDirectoryRecursive(
    Directory directory,
    int currentDepth,
    int maxDepth,
  ) async {
    final List<BookFileV2> books = [];

    if (currentDepth >= maxDepth) {
      return books;
    }

    try {
      await for (final entity in directory.list(
        recursive: false,
        followLinks: false,
      )) {
        if (entity is File) {
          final extension = _getFileExtension(entity.path).toLowerCase();

          if (_supportedExtensions.contains(extension)) {
            try {
              final stat = await entity.stat();
              final book = BookFileV2(
                id: _generateId(entity.path),
                name: _getFileName(entity.path),
                title: _extractTitle(entity.path),
                path: entity.path,
                type: extension == '.pdf' ? 'pdf' : 'epub',
                size: stat.size,
                lastModified: stat.modified,
                dateAdded: stat.modified,
                author: _extractAuthorFromPath(entity.path),
              );
              books.add(book);
            } catch (e) {
              // Silent error handling
            }
          }
        } else if (entity is Directory) {
          final dirName = entity.path.split('/').last.toLowerCase();

          if (!dirName.startsWith('.') &&
              !dirName.startsWith('android') &&
              !dirName.contains('cache') &&
              dirName != 'lost+found') {
            try {
              final subBooks = await _scanDirectoryRecursive(
                entity,
                currentDepth + 1,
                maxDepth,
              );
              books.addAll(subBooks);
            } catch (e) {
              // Silent error handling
            }
          }
        }
      }
    } catch (e) {
      // Silent error handling
    }

    return books;
  }

  /// Generate unique ID for a file
  static String _generateId(String filePath) {
    return filePath.hashCode.abs().toString();
  }

  /// Get file name from path
  static String _getFileName(String filePath) {
    return filePath.split('/').last;
  }

  /// Get file extension from path
  static String _getFileExtension(String filePath) {
    final parts = filePath.split('.');
    if (parts.length > 1) {
      return '.${parts.last}';
    }
    return '';
  }

  /// Extract title from file path
  static String _extractTitle(String filePath) {
    final fileName = _getFileName(filePath);
    final nameWithoutExtension = fileName.replaceAll(
      RegExp(r'\.(pdf|epub)', caseSensitive: false),
      '',
    );

    // Clean up the filename
    return nameWithoutExtension
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Extract author from file path (basic heuristic)
  static String? _extractAuthorFromPath(String filePath) {
    final fileName = _getFileName(filePath);
    final nameWithoutExtension = fileName.replaceAll(
      RegExp(r'\.(pdf|epub)', caseSensitive: false),
      '',
    );

    // Look for common patterns like "Author - Title" or "Title by Author"
    if (nameWithoutExtension.contains(' - ')) {
      final parts = nameWithoutExtension.split(' - ');
      if (parts.length >= 2) {
        final possibleAuthor = parts[0].trim();
        // If the first part looks like an author name (not too long)
        if (possibleAuthor.length < 50 &&
            possibleAuthor.split(' ').length <= 4) {
          return possibleAuthor;
        }
      }
    }

    if (nameWithoutExtension.toLowerCase().contains(' by ')) {
      final parts = nameWithoutExtension.toLowerCase().split(' by ');
      if (parts.length >= 2) {
        final authorPart = parts[1].trim();
        // Clean up and return author
        return authorPart.split(' ').take(3).join(' '); // Limit to 3 words
      }
    }

    return null; // No author found
  }

  /// Check if a file is a supported book format
  static bool isSupportedFile(String filePath) {
    final extension = _getFileExtension(filePath).toLowerCase();
    return _supportedExtensions.contains(extension);
  }

  /// Get file size in human readable format
  static String getFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Scan specific directory
  static Future<List<BookFileV2>> scanSpecificDirectory(
    String directoryPath,
  ) async {
    try {
      final directory = Directory(directoryPath);
      if (await directory.exists()) {
        return await _scanDirectory(directory);
      }
    } catch (e) {
      // Silent error handling
    }
    return [];
  }

  /// Clean up test files that might have been created
  static Future<void> _cleanupTestFiles() async {
    try {
      final testFiles = [
        '/storage/emulated/0/Download/Test_Book.pdf',
        '/storage/emulated/0/Download/Sample_Book.epub',
        '/storage/emulated/0/Documents/Document_Sample.pdf',
        '/sdcard/Download/Test_Book.pdf',
        '/sdcard/Download/Sample_Book.epub',
        '/sdcard/Documents/Document_Sample.pdf',
      ];

      for (final filePath in testFiles) {
        try {
          final file = File(filePath);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          // Silent error handling
        }
      }
    } catch (e) {
      // Silent error handling
    }
  }
}
