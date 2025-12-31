import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/annotation.dart';

class AnnotationService {
  // TODO: For a production app, consider using a more robust storage solution like a local database (e.g., sqflite or isar) to handle a large number of annotations efficiently.
  static const String _prefsKey = 'annotations';

  static Future<void> saveAnnotation(Annotation annotation) async {
    final prefs = await SharedPreferences.getInstance();
    final annotations = await getAnnotationsForBook(annotation.bookId);
    annotations.add(annotation);
    await _saveAnnotations(prefs, annotation.bookId, annotations);
  }

  static Future<List<Annotation>> getAnnotationsForBook(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('$_prefsKey\_$bookId');
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => Annotation.fromJson(json)).toList();
    }
    return [];
  }

  static Future<void> deleteAnnotation(String bookId, String annotationId) async {
    final prefs = await SharedPreferences.getInstance();
    final annotations = await getAnnotationsForBook(bookId);
    annotations.removeWhere((annotation) => annotation.id == annotationId);
    await _saveAnnotations(prefs, bookId, annotations);
  }

  static Future<void> _saveAnnotations(
      SharedPreferences prefs, String bookId, List<Annotation> annotations) async {
    final jsonList = annotations.map((annotation) => annotation.toJson()).toList();
    await prefs.setString('$_prefsKey\_$bookId', json.encode(jsonList));
  }
}
