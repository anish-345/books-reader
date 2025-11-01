import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../data/models/book_file_v2.dart';
import '../../../data/models/bookmark.dart';
import '../../../services/bookmark_service.dart';
import '../../../services/file_scanner_service.dart';
import '../../../services/reading_history_service.dart';
import '../../../services/permission_service.dart';
import '../../../services/sample_books_service.dart';
import '../../../widgets/startapp_banner_widget.dart';
import '../../../widgets/startapp_native_widget.dart';
import '../reader/book_reader_screen.dart';

class HomeScreenV2 extends StatefulWidget {
  const HomeScreenV2({super.key});

  @override
  State<HomeScreenV2> createState() => _HomeScreenV2State();
}

class _HomeScreenV2State extends State<HomeScreenV2> {
  int _selectedIndex = 0;
  List<BookFileV2> _allBooks = [];
  List<BookFileV2> _recentBooks = [];
  bool _isLoading = true;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _checkPermissions();
    if (_hasPermission) {
      await _loadBooks();
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _checkPermissions() async {
    final hasPermission = await PermissionService.hasStoragePermission();
    if (!hasPermission) {
      final granted = await PermissionService.requestStoragePermission();
      setState(() {
        _hasPermission = granted;
      });
    } else {
      setState(() {
        _hasPermission = true;
      });
    }
  }

  Future<void> _loadBooks() async {
    try {
      final books = await FileScannerService.scanForBooks();
      final recentBooks = await ReadingHistoryService.getRecentlyRead();

      // Add sample books if no real books found
      List<BookFileV2> allBooks = books;
      if (SampleBooksService.shouldShowSampleBooks(books)) {
        final sampleBooks = await SampleBooksService.getSampleBooks();
        allBooks = [...sampleBooks, ...books];
      }

      setState(() {
        _allBooks = allBooks;
        _recentBooks = recentBooks;
      });
    } catch (e) {
      // Silent error handling
    }
  }

  Future<void> _refreshBooks() async {
    setState(() {
      _isLoading = true;
    });
    await _loadBooks();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refreshRecentBooks() async {
    // Refresh only recent books without showing loading indicator
    final recentBooks = await ReadingHistoryService.getRecentlyRead();
    if (mounted) {
      setState(() {
        _recentBooks = recentBooks.take(20).toList(); // Limit to 20 items
      });
    }
  }

  List<Widget> get _screens => [
    LibraryTab(
      books: _allBooks,
      isLoading: _isLoading,
      hasPermission: _hasPermission,
      onRefresh: _refreshBooks,
      onRequestPermission: _checkPermissions,
    ),
    RecentTab(
      books: _recentBooks,
      isLoading: _isLoading,
      onRefresh: _refreshBooks,
    ),
    const BookmarksTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // StartApp Banner Ad
          const StartAppBannerWidget(),
          BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
              // Auto-refresh recent books when Recent tab is selected
              if (index == 1) {
                _refreshRecentBooks();
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.library_books),
                label: 'Library',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'Recent',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bookmark),
                label: 'Bookmarks',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
              // Open search directly without ad (for better UX)
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
          : !widget.hasPermission
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
                color: Colors.blue.withValues(alpha: 0.1),
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
        itemCount: _getListItemCount(books.length),
        itemBuilder: (context, index) {
          // Show native ad every 5 books
          if (_shouldShowNativeAd(index)) {
            return StartAppNativeWidget(index: index);
          }

          // Calculate actual book index (accounting for ads)
          final bookIndex = _getBookIndex(index);
          if (bookIndex >= books.length) return const SizedBox.shrink();

          final book = books[bookIndex];
          return _buildBookCard(book);
        },
      ),
    );
  }

  // Calculate total items including ads
  int _getListItemCount(int bookCount) {
    if (bookCount == 0) return 0;
    // Add one ad for every 5 books
    final adCount = (bookCount / 5).floor();
    return bookCount + adCount;
  }

  // Check if this position should show a native ad
  bool _shouldShowNativeAd(int index) {
    // Show ad at positions 5, 11, 17, 23, etc. (after every 5 books)
    return (index + 1) % 6 == 0;
  }

  // Get the actual book index from list index
  int _getBookIndex(int listIndex) {
    // Calculate how many ads appear before this position
    final adsBeforeThis = (listIndex / 6).floor();
    return listIndex - adsBeforeThis;
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
                ? Colors.red.withValues(alpha: 0.1)
                : Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            book.type == 'pdf' ? Icons.picture_as_pdf : Icons.menu_book,
            color: book.type == 'pdf' ? Colors.red : Colors.blue,
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
    // Add to reading history
    ReadingHistoryService.addToHistory(book);

    // Navigate to book reader
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
            Text('Path:', style: AppTextStyles.labelLarge),
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
        itemCount: _getListItemCount(books.length),
        itemBuilder: (context, index) {
          // Show native ad every 5 books
          if (_shouldShowNativeAd(index)) {
            return StartAppNativeWidget(index: index);
          }

          // Calculate actual book index (accounting for ads)
          final bookIndex = _getBookIndex(index);
          if (bookIndex >= books.length) return const SizedBox.shrink();

          final book = books[bookIndex];
          return _buildRecentBookCard(book);
        },
      ),
    );
  }

  // Calculate total items including ads
  int _getListItemCount(int bookCount) {
    if (bookCount == 0) return 0;
    final adCount = (bookCount / 5).floor();
    return bookCount + adCount;
  }

  // Check if this position should show a native ad
  bool _shouldShowNativeAd(int index) {
    return (index + 1) % 6 == 0;
  }

  // Get the actual book index from list index
  int _getBookIndex(int listIndex) {
    final adsBeforeThis = (listIndex / 6).floor();
    return listIndex - adsBeforeThis;
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
                ? Colors.red.withValues(alpha: 0.1)
                : Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            book.type == 'pdf' ? Icons.picture_as_pdf : Icons.menu_book,
            color: book.type == 'pdf' ? Colors.red : Colors.blue,
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
    // Add to reading history
    ReadingHistoryService.addToHistory(book);

    // Navigate to book reader
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => BookReaderScreen(book: book)),
    );
  }
}

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
        ).then((_) => _loadBookmarks()); // Refresh bookmarks when returning
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

  List<Bookmark> get _filteredBookmarks {
    if (_searchQuery.isEmpty) {
      return _bookmarks;
    }
    return _bookmarks.where((bookmark) {
      return bookmark.bookTitle.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          bookmark.displayTitle.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
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
                // Open bookmark search directly without ad (for better UX)
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
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: const Icon(
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
            color: book.type == 'pdf' ? Colors.red : Colors.blue,
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
          bookmark.displayTitle.toLowerCase().contains(query.toLowerCase());
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
