import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../data/models/bookmark.dart';
import '../../../data/models/book_file_v2.dart';
import '../../../services/bookmark_service.dart';
import '../../../services/file_scanner_service.dart';
import '../reader/book_reader_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<Bookmark> _bookmarks = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    setState(() => _isLoading = true);
    try {
      final bookmarks = await BookmarkService.getAllBookmarks();
      if (mounted) {
        setState(() {
          _bookmarks = bookmarks;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading bookmarks: $e')));
      }
    }
  }

  List<Bookmark> get _filteredBookmarks {
    switch (_selectedFilter) {
      case 'Bookmarks':
        return _bookmarks
            .where((b) => b.type == BookmarkType.bookmark)
            .toList();
      case 'Highlights':
        return _bookmarks
            .where((b) => b.type == BookmarkType.highlight)
            .toList();
      case 'Notes':
        return _bookmarks.where((b) => b.type == BookmarkType.note).toList();
      default:
        return _bookmarks;
    }
  }

  Future<void> _deleteBookmark(Bookmark bookmark) async {
    try {
      await BookmarkService.removeBookmark(bookmark.id);
      await _loadBookmarks();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Bookmark deleted')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting bookmark: $e')));
      }
    }
  }

  Future<void> _navigateToBookmark(Bookmark bookmark) async {
    try {
      // Find the book file by ID
      final bookFile = await _findBookById(bookmark.bookId);
      if (bookFile != null && mounted) {
        // Navigate to the book reader with the specific page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                BookReaderScreen(book: bookFile, initialPage: bookmark.page),
          ),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Book file not found')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error opening book: $e')));
      }
    }
  }

  Future<BookFileV2?> _findBookById(String bookId) async {
    try {
      // Get all books from the file scanner
      final allBooks = await FileScannerService.scanForBooks();
      return allBooks.firstWhere(
        (book) => book.id == bookId,
        orElse: () => throw Exception('Book not found'),
      );
    } catch (e) {
      return null;
    }
  }

  void _showDeleteConfirmation(Bookmark bookmark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bookmark'),
        content: Text(
          'Are you sure you want to delete this bookmark from "${bookmark.bookTitle}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteBookmark(bookmark);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() => _selectedFilter = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All', child: Text('All')),
              const PopupMenuItem(value: 'Bookmarks', child: Text('Bookmarks')),
              const PopupMenuItem(
                value: 'Highlights',
                child: Text('Highlights'),
              ),
              const PopupMenuItem(value: 'Notes', child: Text('Notes')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredBookmarks.isEmpty
          ? _buildEmptyState()
          : _buildBookmarksList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 'All'
                ? 'No bookmarks yet'
                : 'No ${_selectedFilter.toLowerCase()} yet',
            style: AppTextStyles.h6.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Start reading and add bookmarks to see them here',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarksList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredBookmarks.length,
      itemBuilder: (context, index) {
        final bookmark = _filteredBookmarks[index];
        return _buildBookmarkCard(bookmark);
      },
    );
  }

  Widget _buildBookmarkCard(Bookmark bookmark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(bookmark.type),
          child: Icon(
            _getTypeIcon(bookmark.type),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          bookmark.bookTitle,
          style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              bookmark.displaySubtitle,
              style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
            ),
            if (bookmark.note != null && bookmark.note!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                bookmark.note!,
                style: AppTextStyles.bodySmall.copyWith(
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Text(
              _formatDate(bookmark.createdAt),
              style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'delete',
              child: const Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'delete') {
              _showDeleteConfirmation(bookmark);
            }
          },
        ),
        onTap: () => _navigateToBookmark(bookmark),
      ),
    );
  }

  Color _getTypeColor(BookmarkType type) {
    switch (type) {
      case BookmarkType.bookmark:
        return AppColors.primary;
      case BookmarkType.highlight:
        return Colors.orange;
      case BookmarkType.note:
        return Colors.green;
    }
  }

  IconData _getTypeIcon(BookmarkType type) {
    switch (type) {
      case BookmarkType.bookmark:
        return Icons.bookmark;
      case BookmarkType.highlight:
        return Icons.highlight;
      case BookmarkType.note:
        return Icons.note;
    }
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
}
