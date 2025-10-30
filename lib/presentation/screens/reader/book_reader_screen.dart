import 'package:flutter/material.dart';
import '../../../data/models/book_file_v2.dart';

import 'pdf_reader_screen.dart';
import 'epub_reader_v2.dart';

class BookReaderScreen extends StatefulWidget {
  final BookFileV2 book;
  final int? initialPage;

  const BookReaderScreen({super.key, required this.book, this.initialPage});

  @override
  State<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.book.type.toLowerCase()) {
      case 'pdf':
        return PDFReaderScreen(
          book: widget.book,
          initialPage: widget.initialPage,
        );
      case 'epub':
        return EpubReaderV2(book: widget.book, initialPage: widget.initialPage);
      default:
        return Scaffold(
          appBar: AppBar(title: const Text('Unsupported Format')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Unsupported file format: ${widget.book.type}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This app supports PDF and EPUB files only.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        );
    }
  }
}
