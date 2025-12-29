import 'dart:io';

import 'package:flutter/material.dart';

import 'package:book_reader/core/constants/colors.dart';
import 'package:book_reader/core/constants/text_styles.dart';
import 'package:book_reader/data/models/book_file_v2.dart';
import 'package:book_reader/services/permission_service.dart';
import 'package:book_reader/services/reading_history_service.dart';
import 'package:book_reader/presentation/screens/reader/book_reader_screen.dart';

class LibraryTab extends StatefulWidget {
  final List<BookFileV2> books;
  final bool isLoading;
  final bool hasPermission;
  final VoidCallback onRefresh;
  final VoidCallback onRequestPermission;

  const LibraryTab({
    super.key,
    required this.books,
    required this.isLoading,
    required this.hasPermission,
    required this.onRefresh,
    required this.onRequestPermission,
  });

  @override
  State<LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends State<LibraryTab> {
  final String _searchQuery = '';
  List<BookFileV2> get _filteredBooks {
    if (_searchQuery.isEmpty) return widget.books;
    return widget.books.where((book) {
      return book.displayName.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final navigator = Navigator.of(context);
              final selectedBook = await showSearch(
                context: context,
                delegate: BookSearchDelegate(widget.books),
              );
              if (selectedBook != null && mounted) {
                navigator.push(
                  MaterialPageRoute(
                    builder: (context) => BookReaderScreen(book: selectedBook),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: widget.isLoading
          ? const Center(child: CircularProgressIndicator())
          : !widget.hasPermission && (Platform.isAndroid)
              ? _buildPermissionRequest()
              : widget.books.isEmpty
                  ? _buildEmptyState()
                  : _buildBooksList(),
    );
  }

  Widget _buildPermissionRequest() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.folder_off,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Storage Access Required',
              style: AppTextStyles.h4,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'To find your PDF and EPUB files, we need access to your device storage.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                children: [
                  Text(
                    '💡 For best results:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1. Tap "Grant Permission" below\n2. Select "Allow access to manage all files"\n3. This lets us find ALL your PDF/EPUB files',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: widget.onRequestPermission,
              icon: const Icon(Icons.folder_open),
              label: const Text('Grant Storage Access'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () async {
                await PermissionService.openAppSettings();
              },
              child: const Text('Open App Settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.library_books,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            const Text('No books found', style: AppTextStyles.h4),
            const SizedBox(height: 8),
            const Text(
              'Download some PDF or EPUB files to your device, then tap "Scan Again" to find them.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: widget.onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Scan Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBooksList() {
    final books = _filteredBooks;

    return RefreshIndicator(
      onRefresh: () async {
        widget.onRefresh();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return _buildBookCard(book);
        },
      ),
    );
  }

  Widget _buildBookCard(BookFileV2 book) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 64,
          decoration: BoxDecoration(
            color: book.type == 'pdf'
                ? Colors.red.withAlpha(25)
                : Colors.grey.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            book.type == 'pdf' ? Icons.picture_as_pdf : Icons.menu_book,
            color: book.type == 'pdf' ? Colors.red : Colors.grey,
            size: 24,
          ),
        ),
        title: Text(
          book.displayName,
          style: AppTextStyles.listTitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (book.author != null && book.author!.isNotEmpty)
              Text(
                'by ${book.author}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            Text(
              '${book.sizeFormatted} • ${book.type.toUpperCase()}',
              style: AppTextStyles.labelSmall,
            ),
            Text(
              'Modified: ${_formatDate(book.lastModified)}',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _openBook(book),
        onLongPress: () => _showBookDetails(book),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _openBook(BookFileV2 book) {
    ReadingHistoryService.addToHistory(book);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => BookReaderScreen(book: book)),
    );
  }

  void _showBookDetails(BookFileV2 book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(book.displayName, style: AppTextStyles.h5),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (book.author != null && book.author!.isNotEmpty) ...[
              Text('Author: ${book.author}', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 8),
            ],
            Text(
              'Type: ${book.type.toUpperCase()}',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Size: ${book.sizeFormatted}',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Modified: ${_formatDate(book.lastModified)}',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 8),
            const Text('Path:', style: AppTextStyles.labelLarge),
            const SizedBox(height: 4),
            Text(
              book.path,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _openBook(book);
            },
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }
}

class BookSearchDelegate extends SearchDelegate<BookFileV2?> {
  final List<BookFileV2> books;

  BookSearchDelegate(this.books);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final filteredBooks = books.where((book) {
      return book.displayName.toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (filteredBooks.isEmpty) {
      return const Center(child: Text('No books found'));
    }

    return ListView.builder(
      itemCount: filteredBooks.length,
      itemBuilder: (context, index) {
        final book = filteredBooks[index];
        return ListTile(
          leading: Icon(
            book.type == 'pdf' ? Icons.picture_as_pdf : Icons.menu_book,
            color: book.type == 'pdf' ? Colors.red : Colors.grey,
          ),
          title: Text(book.displayName),
          subtitle: Text('${book.sizeFormatted} • ${book.type.toUpperCase()}'),
          onTap: () {
            close(context, book);
          },
        );
      },
    );
  }
}
