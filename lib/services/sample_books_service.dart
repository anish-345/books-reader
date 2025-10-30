import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../data/models/book_file_v2.dart';

class SampleBooksService {
  static const List<String> _sampleBooks = [
    'Sample PDF Book.pdf',
    'Sample EPUB Book.epub',
    'Flutter Guide.pdf',
  ];

  /// Get sample books for demo purposes
  static Future<List<BookFileV2>> getSampleBooks() async {
    final List<BookFileV2> sampleBooks = [];

    try {
      final directory = await getApplicationDocumentsDirectory();
      final sampleDir = Directory('${directory.path}/sample_books');

      // Create sample directory if it doesn't exist
      if (!await sampleDir.exists()) {
        await sampleDir.create(recursive: true);
      }

      for (int i = 0; i < _sampleBooks.length; i++) {
        final fileName = _sampleBooks[i];
        final filePath = '${sampleDir.path}/$fileName';
        final file = File(filePath);

        // Create sample file if it doesn't exist
        if (!await file.exists()) {
          await _createSampleFile(file, fileName);
        }

        final stat = await file.stat();
        final book = BookFileV2(
          id: 'sample_${i + 1}',
          name: fileName,
          title: _extractTitle(fileName),
          path: filePath,
          type: fileName.endsWith('.pdf') ? 'pdf' : 'epub',
          size: stat.size,
          lastModified: stat.modified,
          dateAdded: stat.modified,
        );

        sampleBooks.add(book);
      }
    } catch (e) {
      debugPrint('Error creating sample books: $e');
    }

    return sampleBooks;
  }

  static Future<void> _createSampleFile(File file, String fileName) async {
    try {
      if (fileName.endsWith('.pdf')) {
        // Create a simple PDF content placeholder
        await file.writeAsString(_getSamplePdfContent(fileName));
      } else if (fileName.endsWith('.epub')) {
        // Create a simple EPUB content placeholder
        await file.writeAsString(_getSampleEpubContent(fileName));
      }
    } catch (e) {
      debugPrint('Error creating sample file $fileName: $e');
    }
  }

  static String _getSamplePdfContent(String fileName) {
    return '''%PDF-1.4
1 0 obj
<<
/Type /Catalog
/Pages 2 0 R
>>
endobj

2 0 obj
<<
/Type /Pages
/Kids [3 0 R]
/Count 1
>>
endobj

3 0 obj
<<
/Type /Page
/Parent 2 0 R
/MediaBox [0 0 612 792]
/Contents 4 0 R
>>
endobj

4 0 obj
<<
/Length 44
>>
stream
BT
/F1 12 Tf
72 720 Td
(Sample PDF: $fileName) Tj
ET
endstream
endobj

xref
0 5
0000000000 65535 f 
0000000009 00000 n 
0000000058 00000 n 
0000000115 00000 n 
0000000206 00000 n 
trailer
<<
/Size 5
/Root 1 0 R
>>
startxref
299
%%EOF''';
  }

  static String _getSampleEpubContent(String fileName) {
    return '''This is a sample EPUB file: $fileName
    
Chapter 1: Introduction
This is the first chapter of the sample EPUB book.

Chapter 2: Content
This is the second chapter with more content.

Chapter 3: Conclusion
This is the final chapter of the sample book.''';
  }

  static String _extractTitle(String fileName) {
    return fileName
        .replaceAll(RegExp(r'\.(pdf|epub)$', caseSensitive: false), '')
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .trim();
  }

  /// Check if we should show sample books (when no real books found)
  static bool shouldShowSampleBooks(List<BookFileV2> realBooks) {
    // Only show sample books if explicitly requested, not by default
    return false;
  }
}
