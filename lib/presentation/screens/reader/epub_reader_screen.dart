import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/book_file_v2.dart';

class EPUBReaderScreen extends StatefulWidget {
  final BookFileV2 book;

  const EPUBReaderScreen({super.key, required this.book});

  @override
  State<EPUBReaderScreen> createState() => _EPUBReaderScreenState();
}

class _EPUBReaderScreenState extends State<EPUBReaderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.displayName),
        backgroundColor: AppColors.surface,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'EPUB Reader',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'EPUB reading functionality will be available soon.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Text(
              'For now, you can read PDF files.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
