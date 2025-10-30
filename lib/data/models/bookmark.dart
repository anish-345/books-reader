import 'dart:convert';

class Bookmark {
  final String id;
  final String bookId;
  final String bookTitle;
  final int page;
  final double? position; // For EPUB, position within chapter
  final String? chapterId; // For EPUB
  final String? chapterTitle;
  final String? note;
  final String? highlightedText;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final BookmarkType type;
  final Map<String, dynamic> metadata;

  Bookmark({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.page,
    this.position,
    this.chapterId,
    this.chapterTitle,
    this.note,
    this.highlightedText,
    required this.createdAt,
    this.updatedAt,
    this.type = BookmarkType.bookmark,
    this.metadata = const {},
  });

  String get displayTitle {
    if (note != null && note!.isNotEmpty) {
      return note!;
    }
    if (highlightedText != null && highlightedText!.isNotEmpty) {
      return highlightedText!.length > 50
          ? '${highlightedText!.substring(0, 50)}...'
          : highlightedText!;
    }
    if (chapterTitle != null && chapterTitle!.isNotEmpty) {
      return 'Page $page - $chapterTitle';
    }
    return 'Page $page';
  }

  String get displaySubtitle {
    final parts = <String>[];

    if (chapterTitle != null && chapterTitle!.isNotEmpty) {
      parts.add(chapterTitle!);
    }

    parts.add('Page $page');

    if (type == BookmarkType.highlight && highlightedText != null) {
      parts.add('Highlighted');
    }

    return parts.join(' • ');
  }

  String get typeDisplayName {
    switch (type) {
      case BookmarkType.bookmark:
        return 'Bookmark';
      case BookmarkType.highlight:
        return 'Highlight';
      case BookmarkType.note:
        return 'Note';
    }
  }

  Bookmark copyWith({
    String? id,
    String? bookId,
    String? bookTitle,
    int? page,
    double? position,
    String? chapterId,
    String? chapterTitle,
    String? note,
    String? highlightedText,
    DateTime? createdAt,
    DateTime? updatedAt,
    BookmarkType? type,
    Map<String, dynamic>? metadata,
  }) {
    return Bookmark(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      bookTitle: bookTitle ?? this.bookTitle,
      page: page ?? this.page,
      position: position ?? this.position,
      chapterId: chapterId ?? this.chapterId,
      chapterTitle: chapterTitle ?? this.chapterTitle,
      note: note ?? this.note,
      highlightedText: highlightedText ?? this.highlightedText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'page': page,
      'position': position,
      'chapterId': chapterId,
      'chapterTitle': chapterTitle,
      'note': note,
      'highlightedText': highlightedText,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'type': type.name,
      'metadata': metadata,
    };
  }

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      bookTitle: json['bookTitle'] as String,
      page: json['page'] as int,
      position: (json['position'] as num?)?.toDouble(),
      chapterId: json['chapterId'] as String?,
      chapterTitle: json['chapterTitle'] as String?,
      note: json['note'] as String?,
      highlightedText: json['highlightedText'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int)
          : null,
      type: BookmarkType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => BookmarkType.bookmark,
      ),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory Bookmark.fromJsonString(String jsonString) {
    return Bookmark.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Bookmark && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Bookmark(id: $id, bookId: $bookId, page: $page, type: $type)';
  }
}

enum BookmarkType { bookmark, highlight, note }
