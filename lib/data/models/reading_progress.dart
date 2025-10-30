import 'dart:convert';

class ReadingProgress {
  final String id;
  final String bookId;
  final int currentPage;
  final double progress; // 0.0 to 1.0
  final String? currentChapterId; // For EPUB
  final double? chapterProgress; // Progress within current chapter
  final DateTime lastReadAt;
  final Duration sessionTime; // Time spent in current session
  final Duration totalReadingTime;
  final int totalSessions;
  final Map<String, dynamic> metadata;

  ReadingProgress({
    required this.id,
    required this.bookId,
    required this.currentPage,
    required this.progress,
    this.currentChapterId,
    this.chapterProgress,
    required this.lastReadAt,
    this.sessionTime = Duration.zero,
    this.totalReadingTime = Duration.zero,
    this.totalSessions = 0,
    this.metadata = const {},
  });

  String get progressFormatted {
    return '${(progress * 100).toInt()}%';
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

  String get sessionTimeFormatted {
    final minutes = sessionTime.inMinutes;
    final seconds = sessionTime.inSeconds % 60;

    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  bool get isCompleted => progress >= 1.0;
  bool get isStarted => progress > 0.0;

  String get statusText {
    if (isCompleted) return 'Completed';
    if (isStarted) return 'In Progress';
    return 'Not Started';
  }

  ReadingProgress copyWith({
    String? id,
    String? bookId,
    int? currentPage,
    double? progress,
    String? currentChapterId,
    double? chapterProgress,
    DateTime? lastReadAt,
    Duration? sessionTime,
    Duration? totalReadingTime,
    int? totalSessions,
    Map<String, dynamic>? metadata,
  }) {
    return ReadingProgress(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      currentPage: currentPage ?? this.currentPage,
      progress: progress ?? this.progress,
      currentChapterId: currentChapterId ?? this.currentChapterId,
      chapterProgress: chapterProgress ?? this.chapterProgress,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      sessionTime: sessionTime ?? this.sessionTime,
      totalReadingTime: totalReadingTime ?? this.totalReadingTime,
      totalSessions: totalSessions ?? this.totalSessions,
      metadata: metadata ?? this.metadata,
    );
  }

  ReadingProgress updateProgress({
    int? newPage,
    double? newProgress,
    String? newChapterId,
    double? newChapterProgress,
    Duration? additionalTime,
  }) {
    return copyWith(
      currentPage: newPage ?? currentPage,
      progress: newProgress ?? progress,
      currentChapterId: newChapterId ?? currentChapterId,
      chapterProgress: newChapterProgress ?? chapterProgress,
      lastReadAt: DateTime.now(),
      sessionTime: additionalTime != null
          ? sessionTime + additionalTime
          : sessionTime,
      totalReadingTime: additionalTime != null
          ? totalReadingTime + additionalTime
          : totalReadingTime,
    );
  }

  ReadingProgress startNewSession() {
    return copyWith(
      lastReadAt: DateTime.now(),
      sessionTime: Duration.zero,
      totalSessions: totalSessions + 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'currentPage': currentPage,
      'progress': progress,
      'currentChapterId': currentChapterId,
      'chapterProgress': chapterProgress,
      'lastReadAt': lastReadAt.millisecondsSinceEpoch,
      'sessionTime': sessionTime.inMilliseconds,
      'totalReadingTime': totalReadingTime.inMilliseconds,
      'totalSessions': totalSessions,
      'metadata': metadata,
    };
  }

  factory ReadingProgress.fromJson(Map<String, dynamic> json) {
    return ReadingProgress(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      currentPage: json['currentPage'] as int,
      progress: (json['progress'] as num).toDouble(),
      currentChapterId: json['currentChapterId'] as String?,
      chapterProgress: (json['chapterProgress'] as num?)?.toDouble(),
      lastReadAt: DateTime.fromMillisecondsSinceEpoch(
        json['lastReadAt'] as int,
      ),
      sessionTime: Duration(milliseconds: json['sessionTime'] as int? ?? 0),
      totalReadingTime: Duration(
        milliseconds: json['totalReadingTime'] as int? ?? 0,
      ),
      totalSessions: json['totalSessions'] as int? ?? 0,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory ReadingProgress.fromJsonString(String jsonString) {
    return ReadingProgress.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReadingProgress && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ReadingProgress(id: $id, bookId: $bookId, progress: $progressFormatted, page: $currentPage)';
  }
}
