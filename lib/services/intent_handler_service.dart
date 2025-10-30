import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/models/book_file_v2.dart';
import '../presentation/screens/reader/book_reader_screen.dart';

class IntentHandlerService {
  static const MethodChannel _channel = MethodChannel('pdf_epub_reader/intent');
  static GlobalKey<NavigatorState>? _navigatorKey;

  /// Initialize the intent handler with navigator key
  static void initialize({GlobalKey<NavigatorState>? navigatorKey}) {
    _navigatorKey = navigatorKey;
    _setupMethodCallHandler();
  }

  /// Set navigator key for navigation
  static void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  /// Setup method call handler for receiving intents from Android
  static void _setupMethodCallHandler() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'handleFileIntent':
          final intentData = Map<String, dynamic>.from(call.arguments);
          await _handleFileIntent(intentData);
          break;
        default:
          debugPrint('Unknown method: ${call.method}');
      }
    });
  }

  /// Check for pending intents when app starts
  static Future<void> checkPendingIntents() async {
    try {
      final result = await _channel.invokeMethod('getPendingIntent');
      if (result != null) {
        final intentData = Map<String, dynamic>.from(result);
        await _handleFileIntent(intentData);
      }
    } catch (e) {
      debugPrint('Error checking pending intents: $e');
    }
  }

  /// Handle file intent from external apps
  static Future<void> _handleFileIntent(Map<String, dynamic> intentData) async {
    try {
      debugPrint('📱 Handling file intent: $intentData');

      final filePath = intentData['filePath'] as String?;
      final fileName = intentData['fileName'] as String?;
      final mimeType = intentData['mimeType'] as String?;
      // final uri = intentData['uri'] as String?; // Available if needed

      if (filePath == null || fileName == null) {
        debugPrint('❌ Invalid intent data');
        return;
      }

      // Determine file type
      String fileType = 'pdf';
      if (mimeType?.contains('epub') == true ||
          fileName.toLowerCase().endsWith('.epub')) {
        fileType = 'epub';
      }

      // Handle content URI (from file managers, cloud storage, etc.)
      String finalPath = filePath;
      if (filePath.startsWith('content://')) {
        debugPrint('📁 Handling content URI: $filePath');
        finalPath = await _handleContentUri(filePath);
      }

      // Create BookFileV2 object
      final book = BookFileV2(
        id: 'intent_${DateTime.now().millisecondsSinceEpoch}',
        name: fileName,
        title: _extractTitle(fileName),
        path: finalPath,
        type: fileType,
        size: await _getFileSize(finalPath),
        lastModified: DateTime.now(),
        dateAdded: DateTime.now(),
      );

      // Navigate to book reader
      await _navigateToBookReader(book);
    } catch (e) {
      debugPrint('❌ Error handling file intent: $e');
      _showErrorMessage('Error opening file: $e');
    }
  }

  /// Handle content URI by copying to cache
  static Future<String> _handleContentUri(String contentUri) async {
    try {
      debugPrint('📋 Copying content URI to cache...');
      final result = await _channel.invokeMethod('copyContentUriToCache', {
        'uri': contentUri,
      });

      if (result != null) {
        debugPrint('✅ File copied to cache: $result');
        return result as String;
      } else {
        throw Exception('Failed to copy content URI to cache');
      }
    } catch (e) {
      debugPrint('❌ Error handling content URI: $e');
      throw Exception('Could not access file: $e');
    }
  }

  /// Get file size
  static Future<int> _getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final stat = await file.stat();
        return stat.size;
      }
    } catch (e) {
      debugPrint('⚠️ Error getting file size: $e');
    }
    return 0;
  }

  /// Extract title from filename
  static String _extractTitle(String fileName) {
    return fileName
        .replaceAll(RegExp(r'\.(pdf|epub)$', caseSensitive: false), '')
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Navigate to book reader
  static Future<void> _navigateToBookReader(BookFileV2 book) async {
    final context = _navigatorKey?.currentContext;
    if (context != null) {
      debugPrint('📖 Opening book: ${book.name}');

      // Navigate to book reader
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => BookReaderScreen(book: book)),
      );
    } else {
      debugPrint('❌ No navigator context available');
      _showErrorMessage('Could not open book reader');
    }
  }

  /// Show error message
  static void _showErrorMessage(String message) {
    final context = _navigatorKey?.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  /// Show success message
  static void showSuccessMessage(String message) {
    final context = _navigatorKey?.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
