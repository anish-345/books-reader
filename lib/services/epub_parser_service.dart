import 'dart:io';
import 'package:flutter/services.dart';
import 'package:epubx/epubx.dart';

class EpubParserService {
  static const MethodChannel _channel = MethodChannel('pdf_epub_reader/intent');

  /// Parse an EPUB file and extract chapters
  static Future<EpubBookData?> parseEpubFile(String filePath) async {
    try {
      List<int> bytes;

      // Handle content URIs and regular file paths differently
      if (filePath.startsWith('content://')) {
        try {
          // Copy content URI to cache file for EPUB processing
          // This is only for files opened from file manager
          final result = await _channel.invokeMethod('copyContentUriToCache', {
            'uri': filePath,
          });
          if (result is String) {
            // Read from the cached file
            final cacheFile = File(result);
            if (await cacheFile.exists()) {
              bytes = await cacheFile.readAsBytes();
            } else {
              return null;
            }
          } else {
            return null;
          }
        } catch (e) {
          return null;
        }
      } else {
        // Handle regular file paths (from app home screen)
        // No caching needed - read directly
        final file = File(filePath);
        if (!await file.exists()) {
          return null;
        }
        bytes = await file.readAsBytes();
      }

      final epubBook = await EpubReader.readBook(bytes);

      // Extract book metadata
      final title = epubBook.Title ?? 'Unknown Title';
      final author = epubBook.Author ?? 'Unknown Author';
      final description = '';

      // Extract chapters
      final chapters = <EpubChapterData>[];
      if (epubBook.Chapters != null) {
        _extractChapters(epubBook.Chapters!, chapters);
      }

      // If no chapters found, try to extract from spine
      if (chapters.isEmpty && epubBook.Content?.Html != null) {
        final htmlFiles = epubBook.Content!.Html!;
        int chapterIndex = 1;

        for (final entry in htmlFiles.entries) {
          final htmlContent = entry.value;
          if (htmlContent.Content?.isNotEmpty == true) {
            chapters.add(
              EpubChapterData(
                title: 'Chapter $chapterIndex',
                content: htmlContent.Content!,
                anchor: entry.key,
              ),
            );
            chapterIndex++;
          }
        }
      }

      // If still no content, create a fallback
      if (chapters.isEmpty) {
        chapters.add(
          EpubChapterData(
            title: 'Content',
            content:
                '<p>This EPUB file could not be parsed properly. The file may be corrupted or use an unsupported format.</p>',
            anchor: 'fallback',
          ),
        );
      }

      return EpubBookData(
        title: title,
        author: author,
        description: description,
        chapters: chapters,
      );
    } catch (e) {
      return EpubBookData(
        title: 'Error Loading Book',
        author: 'Unknown',
        description: 'Failed to load this EPUB file.',
        chapters: [
          EpubChapterData(
            title: 'Error',
            content: '<p>Failed to load this EPUB file. Error: $e</p>',
            anchor: 'error',
          ),
        ],
      );
    }
  }

  /// Recursively extract chapters from EPUB structure
  static void _extractChapters(
    List<EpubChapter> chapters,
    List<EpubChapterData> result,
  ) {
    for (final chapter in chapters) {
      if (chapter.HtmlContent?.isNotEmpty == true) {
        result.add(
          EpubChapterData(
            title: chapter.Title ?? 'Chapter ${result.length + 1}',
            content: chapter.HtmlContent!,
            anchor: chapter.Anchor ?? '',
          ),
        );
      }

      // Process sub-chapters
      if (chapter.SubChapters?.isNotEmpty == true) {
        _extractChapters(chapter.SubChapters!, result);
      }
    }
  }

  /// Clean HTML content for better display
  static String cleanHtmlContent(String htmlContent) {
    // Remove script tags
    htmlContent = htmlContent.replaceAll(
      RegExp(r'<script[^>]*>.*?</script>', dotAll: true),
      '',
    );

    // Remove style tags (keep inline styles)
    htmlContent = htmlContent.replaceAll(
      RegExp(r'<style[^>]*>.*?</style>', dotAll: true),
      '',
    );

    // Remove comments
    htmlContent = htmlContent.replaceAll(
      RegExp(r'<!--.*?-->', dotAll: true),
      '',
    );

    // Ensure proper paragraph spacing
    htmlContent = htmlContent.replaceAll(RegExp(r'</p>\s*<p>'), '</p>\n\n<p>');

    return htmlContent.trim();
  }
}

/// Data class for parsed EPUB book
class EpubBookData {
  final String title;
  final String author;
  final String description;
  final List<EpubChapterData> chapters;

  EpubBookData({
    required this.title,
    required this.author,
    required this.description,
    required this.chapters,
  });
}

/// Data class for EPUB chapter
class EpubChapterData {
  final String title;
  final String content;
  final String anchor;

  EpubChapterData({
    required this.title,
    required this.content,
    required this.anchor,
  });
}
