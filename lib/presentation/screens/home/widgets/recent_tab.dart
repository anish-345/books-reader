import 'package:book_reader/core/constants/colors.dart';
import 'package:book_reader/core/constants/text_styles.dart';
import 'package:book_reader/data/models/book_file_v2.dart';
import 'package:book_reader/presentation/screens/reader/book_reader_screen.dart';
import 'package:book_reader/services/reading_history_service.dart';
import 'package:flutter/material.dart';

class RecentTab extends StatefulWidget {
  final List<BookFileV2> books;
  final bool isLoading;
  final VoidCallback onRefresh;

  const RecentTab({
    super.key,
    required this.books,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  State<RecentTab> createState() => _RecentTabState();
}

class _RecentTabState extends State<RecentTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recent')),
      body: widget.isLoading
          ? const Center(child: CircularProgressIndicator())
          : widget.books.isEmpty
              ? _buildEmptyState()
              : _buildRecentBooksList(),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: AppColors.textTertiary),
          SizedBox(height: 16),
          Text('No recent books', style: AppTextStyles.h4),
          SizedBox(height: 8),
          Text(
            'Books you read will appear here',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentBooksList() {
    final books = widget.books;

    return RefreshIndicator(
      onRefresh: () async {
        widget.onRefresh();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return _buildRecentBookCard(book);
        },
      ),
    );
  }

  Widget _buildRecentBookCard(BookFileV2 book) {
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
              'Last read: ${_formatDate(book.lastModified)}',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _openBook(book),
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
}
