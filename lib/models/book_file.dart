class BookFile {
  final String name;
  final String path;
  final String type; // 'pdf' or 'epub'
  final int size;
  final DateTime lastModified;

  BookFile({
    required this.name,
    required this.path,
    required this.type,
    required this.size,
    required this.lastModified,
  });

  String get displayName {
    return name.replaceAll(RegExp(r'\.(pdf|epub)$', caseSensitive: false), '');
  }

  String get sizeFormatted {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
