import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/book_file.dart';
import 'permission_service.dart';

class FileService {
  Future<bool> requestPermissions() async {
    return await PermissionService.requestStoragePermission();
  }

  Future<List<BookFile>> scanForBooks() async {
    final List<BookFile> books = [];
    final Set<String> seenPaths = <String>{};
    final Set<String> seenFiles =
        <String>{}; // Track by name+size to catch duplicates

    try {
      // Get public directories for scanning
      final directories = await _getPublicDirectories();

      debugPrint('Found ${directories.length} unique directories to scan');
      for (final directory in directories) {
        if (await directory.exists()) {
          debugPrint('Scanning directory: ${directory.path}');
          await _scanDirectory(directory, books, seenPaths, seenFiles);
        }
      }

      // If no books found in public directories, add sample books for demo
      if (books.isEmpty) {
        books.addAll(_getSampleBooks());
      }
    } catch (e) {
      debugPrint('Error scanning for books: $e');
      // Add sample books if scanning fails only if no books were found
      if (books.isEmpty) {
        books.addAll(_getSampleBooks());
      }
    }

    debugPrint('Total unique books found: ${books.length}');
    return books;
  }

  List<BookFile> _getSampleBooks() {
    return [
      BookFile(
        name: 'Sample PDF Book.pdf',
        path: '/sample/path/sample_book.pdf',
        type: 'pdf',
        size: 2048576, // 2MB
        lastModified: DateTime.now().subtract(const Duration(days: 1)),
      ),
      BookFile(
        name: 'Sample EPUB Book.epub',
        path: '/sample/path/sample_epub.epub',
        type: 'epub',
        size: 1536000, // 1.5MB
        lastModified: DateTime.now().subtract(const Duration(days: 3)),
      ),
      BookFile(
        name: 'Flutter Guide.pdf',
        path: '/sample/path/flutter_guide.pdf',
        type: 'pdf',
        size: 5242880, // 5MB
        lastModified: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
  }

  Future<List<Directory>> _getPublicDirectories() async {
    final Set<String> uniquePaths = <String>{};
    final List<Directory> directories = [];

    try {
      if (Platform.isAndroid) {
        // Common Android public directories
        final commonPaths = [
          '/storage/emulated/0/Download',
          '/storage/emulated/0/Downloads',
          '/storage/emulated/0/Documents',
          '/storage/emulated/0/Books',
        ];

        for (final path in commonPaths) {
          final dir = Directory(path);
          if (await dir.exists()) {
            final resolvedPath = await dir.resolveSymbolicLinks();
            if (!uniquePaths.contains(resolvedPath)) {
              uniquePaths.add(resolvedPath);
              directories.add(Directory(resolvedPath));
            }
          }
        }

        // Try to get external storage directory
        try {
          final externalDir = await getExternalStorageDirectory();
          if (externalDir != null) {
            // Navigate to public directories from external storage
            final publicPaths = [
              '${externalDir.parent.parent.parent.parent.path}/Download',
              '${externalDir.parent.parent.parent.parent.path}/Downloads',
              '${externalDir.parent.parent.parent.parent.path}/Documents',
              '${externalDir.parent.parent.parent.parent.path}/Books',
            ];

            for (final path in publicPaths) {
              final dir = Directory(path);
              if (await dir.exists()) {
                final resolvedPath = await dir.resolveSymbolicLinks();
                if (!uniquePaths.contains(resolvedPath)) {
                  uniquePaths.add(resolvedPath);
                  directories.add(Directory(resolvedPath));
                }
              }
            }
          }
        } catch (e) {
          debugPrint('Error accessing external storage: $e');
        }
      }

      // Also include app directories as fallback
      try {
        final appDocDir = await getApplicationDocumentsDirectory();
        final resolvedPath = await appDocDir.resolveSymbolicLinks();
        if (!uniquePaths.contains(resolvedPath)) {
          uniquePaths.add(resolvedPath);
          directories.add(Directory(resolvedPath));
        }
      } catch (e) {
        debugPrint('Error accessing app documents directory: $e');
      }
    } catch (e) {
      debugPrint('Error getting public directories: $e');
    }

    return directories;
  }

  Future<void> _scanDirectory(
    Directory directory,
    List<BookFile> books,
    Set<String> seenPaths,
    Set<String> seenFiles,
  ) async {
    try {
      await for (final entity in directory.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is File) {
          final fileName = entity.path
              .split(Platform.pathSeparator)
              .last
              .toLowerCase();

          if (fileName.endsWith('.pdf') || fileName.endsWith('.epub')) {
            // Skip if we've already seen this file path
            if (seenPaths.contains(entity.path)) {
              continue;
            }

            try {
              final stat = await entity.stat();
              final actualFileName = entity.path
                  .split(Platform.pathSeparator)
                  .last;

              // Create unique identifier using name and size
              final fileIdentifier = '${actualFileName}_${stat.size}';

              // Skip if we've already seen this file (by name and size)
              if (seenFiles.contains(fileIdentifier)) {
                debugPrint('Skipping duplicate file: $actualFileName');
                continue;
              }

              final bookFile = BookFile(
                name: actualFileName,
                path: entity.path,
                type: fileName.endsWith('.pdf') ? 'pdf' : 'epub',
                size: stat.size,
                lastModified: stat.modified,
              );

              books.add(bookFile);
              seenPaths.add(entity.path);
              seenFiles.add(fileIdentifier);
              debugPrint('Added unique book: ${bookFile.name}');
            } catch (e) {
              debugPrint('Error processing file ${entity.path}: $e');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error scanning directory ${directory.path}: $e');
    }
  }
}
