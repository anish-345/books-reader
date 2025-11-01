import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/book_file_v2.dart';
import '../data/models/reading_progress.dart';

class ReadingHistoryService {
  static const String _historyKey = 'reading_history';
  static const String _progressKey = 'reading_progress';
  static const int _maxHistoryItems = 50;

  /// Add a book to reading history
  static Future<void> addToHistory(BookFileV2 book) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey) ?? '[]';
      final List<dynamic> historyList = jsonDecode(historyJson);

      // Remove existing entry if present
      historyList.removeWhere((item) => item['id'] == book.id);

      // Add to beginning of list
      historyList.insert(0, {
        'id': book.id,
        'title': book.displayName,
        'path': book.path,
        'type': book.type,
        'lastRead': DateTime.now().toIso8601String(),
        'size': book.size,
      });

      // Keep only recent items
      if (historyList.length > _maxHistoryItems) {
        historyList.removeRange(_maxHistoryItems, historyList.length);
      }

      await prefs.setString(_historyKey, jsonEncode(historyList));
    } catch (e) {
      // Silent error handling
    }
  }

  /// Get reading history
  static Future<List<BookFileV2>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey) ?? '[]';
      final List<dynamic> historyList = jsonDecode(historyJson);

      return historyList.map((item) {
        return BookFileV2(
          id: item['id'],
          name: item['title'],
          title: item['title'],
          path: item['path'],
          type: item['type'],
          size: item['size'] ?? 0,
          lastModified: DateTime.parse(item['lastRead']),
          dateAdded: DateTime.parse(item['lastRead']),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Clear reading history
  static Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
    } catch (e) {
      // Silent error handling
    }
  }

  /// Remove specific item from history
  static Future<void> removeFromHistory(String bookId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey) ?? '[]';
      final List<dynamic> historyList = jsonDecode(historyJson);

      historyList.removeWhere((item) => item['id'] == bookId);

      await prefs.setString(_historyKey, jsonEncode(historyList));
    } catch (e) {
      // Silent error handling
    }
  }

  /// Save reading progress
  static Future<void> saveProgress(ReadingProgress progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString(_progressKey) ?? '{}';
      final Map<String, dynamic> progressMap = jsonDecode(progressJson);

      progressMap[progress.bookId] = progress.toJson();

      await prefs.setString(_progressKey, jsonEncode(progressMap));
    } catch (e) {
      // Silent error handling
    }
  }

  /// Get reading progress for a book
  static Future<ReadingProgress?> getProgress(String bookId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString(_progressKey) ?? '{}';
      final Map<String, dynamic> progressMap = jsonDecode(progressJson);

      if (progressMap.containsKey(bookId)) {
        final data = progressMap[bookId];
        return ReadingProgress.fromJson(data);
      }
    } catch (e) {
      // Silent error handling
    }
    return null;
  }

  /// Get all reading progress
  static Future<Map<String, ReadingProgress>> getAllProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString(_progressKey) ?? '{}';
      final Map<String, dynamic> progressMap = jsonDecode(progressJson);

      final Map<String, ReadingProgress> result = {};

      progressMap.forEach((bookId, data) {
        result[bookId] = ReadingProgress.fromJson(data);
      });

      return result;
    } catch (e) {
      return {};
    }
  }

  /// Get recently read books (with progress)
  static Future<List<BookFileV2>> getRecentlyRead() async {
    try {
      final history = await getHistory();
      final progressMap = await getAllProgress();

      // Filter books that have reading progress
      final recentBooks = history.where((book) {
        return progressMap.containsKey(book.id);
      }).toList();

      // Sort by last read date
      recentBooks.sort((a, b) {
        final progressA = progressMap[a.id];
        final progressB = progressMap[b.id];
        if (progressA == null || progressB == null) return 0;
        return progressB.lastReadAt.compareTo(progressA.lastReadAt);
      });

      return recentBooks.take(10).toList(); // Return top 10 recent books
    } catch (e) {
      return [];
    }
  }

  /// Get reading statistics
  static Future<Map<String, dynamic>> getReadingStats() async {
    try {
      final progressMap = await getAllProgress();
      final history = await getHistory();

      int totalBooksRead = progressMap.length;
      int totalReadingTimeMinutes = 0;
      int completedBooks = 0;

      progressMap.forEach((bookId, progress) {
        totalReadingTimeMinutes += progress.totalReadingTime.inMinutes;
        if (progress.progress >= 1.0) {
          completedBooks++;
        }
      });

      return {
        'totalBooksRead': totalBooksRead,
        'totalReadingTimeMinutes': totalReadingTimeMinutes,
        'completedBooks': completedBooks,
        'totalBooksInLibrary': history.length,
        'averageProgress': totalBooksRead > 0
            ? progressMap.values
                      .map((p) => p.progress)
                      .reduce((a, b) => a + b) /
                  totalBooksRead
            : 0.0,
      };
    } catch (e) {
      return {
        'totalBooksRead': 0,
        'totalReadingTimeMinutes': 0,
        'completedBooks': 0,
        'totalBooksInLibrary': 0,
        'averageProgress': 0.0,
      };
    }
  }
}
