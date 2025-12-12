import 'package:flutter/material.dart';
import '../models/book_file.dart';
import '../services/pdf_viewer_service.dart';

class PdfViewerScreen extends StatelessWidget {
  final BookFile bookFile;

  const PdfViewerScreen({super.key, required this.bookFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(bookFile.name),
      ),
      body: PdfViewerService.getPdfViewer(bookFile.path),
    );
  }
}
