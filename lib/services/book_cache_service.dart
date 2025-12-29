import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../data/models/book_file_v2.dart';

class BookCacheService {
  static const _cacheFileName = 'book_cache.json';

  static Future<File> get _cacheFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_cacheFileName');
  }

  static Future<void> saveBooks(List<BookFileV2> books) async {
    try {
      final file = await _cacheFile;
      final jsonList = books.map((book) => book.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      // Handle cache write errors
    }
  }

  static Future<List<BookFileV2>> loadBooks() async {
    try {
      final file = await _cacheFile;
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final jsonList = jsonDecode(jsonString) as List;
        return jsonList.map((json) => BookFileV2.fromJson(json)).toList();
      }
    } catch (e) {
      // Handle cache read errors
    }
    return [];
  }
}
