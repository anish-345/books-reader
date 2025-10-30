import 'dart:convert';

class BookFileV2 {
  final String id;
  final String name;
  final String path;
  final String type; // 'pdf' or 'epub'
  final int size;
  final DateTime lastModified;
  final DateTime dateAdded;
  final String? coverImagePath;
  final String? author;
  final String? title;
  final int? totalPages;
  final String category;
  final List<String> tags;
  final bool isFavorite;
  final double readingProgress; // 0.0 to 1.0
  final DateTime? lastOpened;
  final int openCount;
  final Duration totalReadingTime;
  final String? description;
  final double? rating; // 1.0 to 5.0
  final Map<String, dynamic> metadata;

  BookFileV2({
    required this.id,
    required this.name,
    required this.path,
    required this.type,
    required this.size,
    required this.lastModified,
    required this.dateAdded,
    this.coverImagePath,
    this.author,
    this.title,
    this.totalPages,
    this.category = 'Uncategorized',
    this.tags = const [],
    this.isFavorite = false,
    this.readingProgress = 0.0,
    this.lastOpened,
    this.openCount = 0,
    this.totalReadingTime = Duration.zero,
    this.description,
    this.rating,
    this.metadata = const {},
  });

  // Getters
  String get displayName {
    if (title != null && title!.isNotEmpty) {
      return title!;
    }
    return name.replaceAll(RegExp(r'\.(pdf|epub)$', caseSensitive: false), '');
  }

  String get displayAuthor {
    return author ?? 'Unknown Author';
  }

  String get sizeFormatted {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  String get readingProgressFormatted {
    return '${(readingProgress * 100).toInt()}%';
  }

  String get totalReadingTimeFormatted {
    final hours = totalReadingTime.inHours;
    final minutes = totalReadingTime.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '< 1m';
    }
  }

  bool get isCompleted => readingProgress >= 1.0;
  bool get isStarted => readingProgress > 0.0;
  bool get isRecent =>
      lastOpened != null && DateTime.now().difference(lastOpened!).inDays < 7;

  String get statusText {
    if (isCompleted) return 'Completed';
    if (isStarted) return 'In Progress';
    return 'Not Started';
  }

  // Copy with method
  BookFileV2 copyWith({
    String? id,
    String? name,
    String? path,
    String? type,
    int? size,
    DateTime? lastModified,
    DateTime? dateAdded,
    String? coverImagePath,
    String? author,
    String? title,
    int? totalPages,
    String? category,
    List<String>? tags,
    bool? isFavorite,
    double? readingProgress,
    DateTime? lastOpened,
    int? openCount,
    Duration? totalReadingTime,
    String? description,
    double? rating,
    Map<String, dynamic>? metadata,
  }) {
    return BookFileV2(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      type: type ?? this.type,
      size: size ?? this.size,
      lastModified: lastModified ?? this.lastModified,
      dateAdded: dateAdded ?? this.dateAdded,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      author: author ?? this.author,
      title: title ?? this.title,
      totalPages: totalPages ?? this.totalPages,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      readingProgress: readingProgress ?? this.readingProgress,
      lastOpened: lastOpened ?? this.lastOpened,
      openCount: openCount ?? this.openCount,
      totalReadingTime: totalReadingTime ?? this.totalReadingTime,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      metadata: metadata ?? this.metadata,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'type': type,
      'size': size,
      'lastModified': lastModified.millisecondsSinceEpoch,
      'dateAdded': dateAdded.millisecondsSinceEpoch,
      'coverImagePath': coverImagePath,
      'author': author,
      'title': title,
      'totalPages': totalPages,
      'category': category,
      'tags': tags,
      'isFavorite': isFavorite,
      'readingProgress': readingProgress,
      'lastOpened': lastOpened?.millisecondsSinceEpoch,
      'openCount': openCount,
      'totalReadingTime': totalReadingTime.inMilliseconds,
      'description': description,
      'rating': rating,
      'metadata': metadata,
    };
  }

  factory BookFileV2.fromJson(Map<String, dynamic> json) {
    return BookFileV2(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
      type: json['type'] as String,
      size: json['size'] as int,
      lastModified: DateTime.fromMillisecondsSinceEpoch(
        json['lastModified'] as int,
      ),
      dateAdded: DateTime.fromMillisecondsSinceEpoch(json['dateAdded'] as int),
      coverImagePath: json['coverImagePath'] as String?,
      author: json['author'] as String?,
      title: json['title'] as String?,
      totalPages: json['totalPages'] as int?,
      category: json['category'] as String? ?? 'Uncategorized',
      tags: List<String>.from(json['tags'] as List? ?? []),
      isFavorite: json['isFavorite'] as bool? ?? false,
      readingProgress: (json['readingProgress'] as num?)?.toDouble() ?? 0.0,
      lastOpened: json['lastOpened'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastOpened'] as int)
          : null,
      openCount: json['openCount'] as int? ?? 0,
      totalReadingTime: Duration(
        milliseconds: json['totalReadingTime'] as int? ?? 0,
      ),
      description: json['description'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory BookFileV2.fromJsonString(String jsonString) {
    return BookFileV2.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookFileV2 && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'BookFileV2(id: $id, name: $name, type: $type, progress: $readingProgressFormatted)';
  }
}
