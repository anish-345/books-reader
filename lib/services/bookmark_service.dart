import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/bookmark.dart';

class BookmarkService {
  static const String _bookmarksKey = 'bookmarks';
  static SharedPreferences? _prefs;

  static Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Add a new bookmark
  static Future<void> addBookmark(Bookmark bookmark) async {
    await _initPrefs();
    final bookmarks = await getAllBookmarks();

    // Check if bookmark already exists for this page
    final existingIndex = bookmarks.indexWhere(
      (b) =>
          b.bookId == bookmark.bookId &&
          b.page == bookmark.page &&
          b.type == bookmark.type,
    );

    if (existingIndex != -1) {
      // Update existing bookmark
      bookmarks[existingIndex] = bookmark.copyWith(updatedAt: DateTime.now());
    } else {
      // Add new bookmark
      bookmarks.add(bookmark);
    }

    await _saveBookmarks(bookmarks);
  }

  /// Remove a bookmark
  static Future<void> removeBookmark(String bookmarkId) async {
    await _initPrefs();
    final bookmarks = await getAllBookmarks();
    bookmarks.removeWhere((b) => b.id == bookmarkId);
    await _saveBookmarks(bookmarks);
  }

  /// Remove bookmark by book and page
  static Future<void> removeBookmarkByPage(
    String bookId,
    int page, {
    BookmarkType type = BookmarkType.bookmark,
  }) async {
    await _initPrefs();
    final bookmarks = await getAllBookmarks();
    bookmarks.removeWhere(
      (b) => b.bookId == bookId && b.page == page && b.type == type,
    );
    await _saveBookmarks(bookmarks);
  }

  /// Get all bookmarks
  static Future<List<Bookmark>> getAllBookmarks() async {
    await _initPrefs();
    final bookmarksJson = _prefs!.getStringList(_bookmarksKey) ?? [];
    return bookmarksJson.map((json) => Bookmark.fromJsonString(json)).toList()
      ..sort(
        (a, b) => b.createdAt.compareTo(a.createdAt),
      ); // Sort by newest first
  }

  /// Get bookmarks for a specific book
  static Future<List<Bookmark>> getBookmarksForBook(String bookId) async {
    final allBookmarks = await getAllBookmarks();
    return allBookmarks.where((b) => b.bookId == bookId).toList()
      ..sort((a, b) => a.page.compareTo(b.page)); // Sort by page number
  }

  /// Check if a page is bookmarked
  static Future<bool> isPageBookmarked(
    String bookId,
    int page, {
    BookmarkType type = BookmarkType.bookmark,
  }) async {
    final bookmarks = await getBookmarksForBook(bookId);
    return bookmarks.any((b) => b.page == page && b.type == type);
  }

  /// Get bookmark for a specific page
  static Future<Bookmark?> getBookmarkForPage(
    String bookId,
    int page, {
    BookmarkType type = BookmarkType.bookmark,
  }) async {
    final bookmarks = await getBookmarksForBook(bookId);
    try {
      return bookmarks.firstWhere((b) => b.page == page && b.type == type);
    } catch (e) {
      return null;
    }
  }

  /// Update an existing bookmark
  static Future<void> updateBookmark(Bookmark bookmark) async {
    await _initPrefs();
    final bookmarks = await getAllBookmarks();
    final index = bookmarks.indexWhere((b) => b.id == bookmark.id);

    if (index != -1) {
      bookmarks[index] = bookmark.copyWith(updatedAt: DateTime.now());
      await _saveBookmarks(bookmarks);
    }
  }

  /// Clear all bookmarks
  static Future<void> clearAllBookmarks() async {
    await _initPrefs();
    await _prefs!.remove(_bookmarksKey);
  }

  /// Clear bookmarks for a specific book
  static Future<void> clearBookmarksForBook(String bookId) async {
    await _initPrefs();
    final bookmarks = await getAllBookmarks();
    bookmarks.removeWhere((b) => b.bookId == bookId);
    await _saveBookmarks(bookmarks);
  }

  /// Get bookmark statistics
  static Future<Map<String, int>> getBookmarkStats() async {
    final bookmarks = await getAllBookmarks();
    final stats = <String, int>{
      'total': bookmarks.length,
      'bookmarks': bookmarks
          .where((b) => b.type == BookmarkType.bookmark)
          .length,
      'highlights': bookmarks
          .where((b) => b.type == BookmarkType.highlight)
          .length,
      'notes': bookmarks.where((b) => b.type == BookmarkType.note).length,
    };
    return stats;
  }

  /// Private method to save bookmarks to SharedPreferences
  static Future<void> _saveBookmarks(List<Bookmark> bookmarks) async {
    final bookmarksJson = bookmarks.map((b) => b.toJsonString()).toList();
    await _prefs!.setStringList(_bookmarksKey, bookmarksJson);
  }

  /// Generate a unique ID for bookmarks
  static String generateBookmarkId() {
    return 'bookmark_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }
}
