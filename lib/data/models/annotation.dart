import 'package:flutter/material.dart';

enum AnnotationType {
  highlight,
  underline,
  strikethrough,
  squiggly,
}

class Annotation {
  final String id;
  final String bookId;
  final AnnotationType type;
  final String text;
  final int page; // For PDF
  final String? chapterId; // For EPUB
  final DateTime createdAt;
  final String? cfi; // EPUB Canonical Fragment Identifier

  Annotation({
    required this.id,
    required this.bookId,
    required this.type,
    required this.text,
    required this.page,
    this.chapterId,
    required this.createdAt,
    this.cfi,
  });

  Color get color {
    switch (type) {
      case AnnotationType.highlight:
        return Colors.yellow.withOpacity(0.5);
      case AnnotationType.underline:
        return Colors.red;
      case AnnotationType.strikethrough:
        return Colors.black;
      case AnnotationType.squiggly:
        return Colors.blue;
    }
  }
}
