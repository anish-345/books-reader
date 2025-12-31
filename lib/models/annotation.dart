enum AnnotationType { highlight, underline }

class Annotation {
  final String id;
  final String bookId;
  final String cfi;
  final AnnotationType type;
  final int color;
  final DateTime createdAt;

  Annotation({
    required this.id,
    required this.bookId,
    required this.cfi,
    required this.type,
    required this.color,
    required this.createdAt,
  });

  factory Annotation.fromJson(Map<String, dynamic> json) {
    return Annotation(
      id: json['id'],
      bookId: json['bookId'],
      cfi: json['cfi'],
      type: AnnotationType.values.byName(json['type']),
      color: json['color'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'cfi': cfi,
      'type': type.name,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
