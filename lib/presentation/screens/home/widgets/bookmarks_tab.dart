import 'package:book_reader/core/constants/colors.dart';
import 'package:book_reader/core/constants/text_styles.dart';
import 'package:book_reader/data/models/book_file_v2.dart';
import 'package:book_reader/data/models/bookmark.dart';
import 'package:book_reader/presentation/screens/reader/book_reader_screen.dart';
import 'package:book_reader/services/bookmark_service.dart';
import 'package:book_reader/services/file_scanner_service.dart';
import 'package:flutter/material.dart';

class BookmarksTab extends StatefulWidget {
  const BookmarksTab({super.key});

  @override
  State<BookmarksTab> createState() => _BookmarksTabState();
}

class _BookmarksTabState extends State<BookmarksTab> {
  List<Bookmark> _bookmarks = [];
  bool _isLoading = true;
  final String _searchQuery = '';

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
      }
    }
  }

  Future<void> _navigateToBookmark(Bookmark bookmark) async {
    try {
      final bookFile = await _findBookById(bookmark.bookId);
      if (bookFile != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                BookReaderScreen(book: bookFile, initialPage: bookmark.page),
          ),
        ).then((_) => _loadBookmarks());
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Book file not found')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening book: $e')),
        );
      }
    }
  }

  Future<BookFileV2?> _findBookById(String bookId) async {
    try {
      final allBooks = await FileScannerService.scanForBooks();
      return allBooks.firstWhere(
        (book) => book.id == bookId,
        orElse: () => throw Exception('Book not found'),
      );
    } catch (e) {
      return null;
    }
  }

  List<Bookmark> get _filteredBookmarks {
    if (_searchQuery.isEmpty) {
      return _bookmarks;
    }
    return _bookmarks.where((bookmark) {
      return bookmark.bookTitle.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          (bookmark.displayTitle.toLowerCase().contains(_searchQuery.toLowerCase()));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        actions: [
          if (_bookmarks.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () async {
                final selectedBookmark = await showSearch(
                  context: context,
                  delegate: BookmarkSearchDelegate(_bookmarks),
                );
                if (selectedBookmark != null && mounted) {
                  _navigateToBookmark(selectedBookmark);
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredBookmarks.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bookmark, size: 64, color: AppColors.textTertiary),
                      SizedBox(height: 16),
                      Text('No bookmarks', style: AppTextStyles.h4),
                      SizedBox(height: 8),
                      Text(
                        'Bookmark pages to find them easily',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredBookmarks.length,
                  itemBuilder: (context, index) {
                    final bookmark = _filteredBookmarks[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Icon(
                            Icons.bookmark,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          bookmark.bookTitle,
                          style: AppTextStyles.labelLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          'Page ${bookmark.page}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        trailing: Text(
                          _formatDate(bookmark.createdAt),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        onTap: () => _navigateToBookmark(bookmark),
                      ),
                    );
                  },
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
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}

class BookmarkSearchDelegate extends SearchDelegate<Bookmark?> {
  final List<Bookmark> bookmarks;

  BookmarkSearchDelegate(this.bookmarks);

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
    final filteredBookmarks = bookmarks.where((bookmark) {
      return bookmark.bookTitle.toLowerCase().contains(query.toLowerCase()) ||
          (bookmark.displayTitle.toLowerCase().contains(query.toLowerCase()));
    }).toList();

    if (filteredBookmarks.isEmpty) {
      return const Center(child: Text('No bookmarks found'));
    }

    return ListView.builder(
      itemCount: filteredBookmarks.length,
      itemBuilder: (context, index) {
        final bookmark = filteredBookmarks[index];
        return ListTile(
          leading: const CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Icon(Icons.bookmark, color: Colors.white, size: 20),
          ),
          title: Text(bookmark.bookTitle, overflow: TextOverflow.ellipsis),
          subtitle: Text('Page ${bookmark.page}'),
          onTap: () {
            close(context, bookmark);
          },
        );
      },
    );
  }
}
