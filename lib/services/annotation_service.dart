import '../data/models/annotation.dart';

class AnnotationService {
  // For simplicity, we'll use an in-memory list.
  // A real-world app would use a database.
  static final List<Annotation> _annotations = [];

  static Future<List<Annotation>> getAnnotationsForBook(String bookId) async {
    return _annotations.where((a) => a.bookId == bookId).toList();
  }

  static Future<void> addAnnotation(Annotation annotation) async {
    _annotations.add(annotation);
  }

  static Future<void> deleteAnnotation(String annotationId) async {
    _annotations.removeWhere((a) => a.id == annotationId);
  }
}
