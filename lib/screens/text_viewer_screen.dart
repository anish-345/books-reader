import 'dart:io';
import 'package:flutter/material.dart';
import '../models/book_file.dart';

class TextViewerScreen extends StatefulWidget {
  final BookFile bookFile;

  const TextViewerScreen({super.key, required this.bookFile});

  @override
  State<TextViewerScreen> createState() => _TextViewerScreenState();
}

class _TextViewerScreenState extends State<TextViewerScreen> {
  String? content;
  bool isLoading = true;
  String? error;
  double fontSize = 16.0;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      final file = File(widget.bookFile.path);
      final text = await file.readAsString();
      setState(() {
        content = text;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load file: $e';
        isLoading = false;
      });
    }
  }

  String _getFileTypeLabel() {
    switch (widget.bookFile.type.toLowerCase()) {
      case 'html':
      case 'htm':
        return 'HTML Document';
      case 'xml':
        return 'XML Document';
      case 'json':
        return 'JSON Data';
      case 'md':
        return 'Markdown';
      case 'csv':
        return 'CSV Data';
      case 'log':
        return 'Log File';
      default:
        return 'Text File';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.bookFile.displayName,
              style: TextStyle(
                color: isDarkMode ? Colors.white : const Color(0xFF2D3748),
                fontSize: 16,
              ),
            ),
            Text(
              _getFileTypeLabel(),
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
                fontSize: 12,
              ),
            ),
          ],
        ),
        backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : const Color(0xFF2D3748),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              setState(() {
                isDarkMode = !isDarkMode;
              });
            },
          ),
          PopupMenuButton<double>(
            icon: const Icon(Icons.text_fields),
            onSelected: (value) {
              setState(() {
                fontSize = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 12.0, child: Text('Small')),
              const PopupMenuItem(value: 16.0, child: Text('Medium')),
              const PopupMenuItem(value: 20.0, child: Text('Large')),
              const PopupMenuItem(value: 24.0, child: Text('Extra Large')),
            ],
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      );
    }

    final isCodeFile = [
      'html',
      'htm',
      'xml',
      'json',
      'md',
    ].contains(widget.bookFile.type.toLowerCase());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SelectableText(
        content ?? '',
        style: TextStyle(
          fontSize: fontSize,
          height: 1.6,
          color: isDarkMode ? Colors.white : Colors.black87,
          fontFamily: isCodeFile ? 'monospace' : null,
        ),
      ),
    );
  }
}
