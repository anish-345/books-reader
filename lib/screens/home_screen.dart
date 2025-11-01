import 'package:flutter/material.dart';
import '../models/book_file.dart';
import '../widgets/book_tile.dart';
import '../services/file_service.dart';
import 'pdf_viewer_screen.dart';
// import 'epub_viewer_screen.dart'; // Removed - using new reader

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<BookFile> books = [];
  bool isLoading = true;
  bool hasPermission = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final fileService = FileService();
    final permission = await fileService.requestPermissions();

    setState(() {
      hasPermission = permission;
    });

    if (permission) {
      await _loadBooks();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadBooks() async {
    setState(() {
      isLoading = true;
    });

    try {
      final fileService = FileService();
      final scannedBooks = await fileService.scanForBooks();

      setState(() {
        books = scannedBooks;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        books = [];
        isLoading = false;
      });
    }
  }

  void _openBook(BookFile book) {
    if (book.type == 'pdf') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerScreen(bookFile: book),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('EPUB Reader')),
            body: const Center(child: Text('EPUB reader not available in v1')),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'My Library',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF4A5568)),
            onPressed: hasPermission ? _loadBooks : null,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!hasPermission) {
      return _buildPermissionDenied();
    }

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4299E1)),
        ),
      );
    }

    if (books.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadBooks,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: books.length,
        itemBuilder: (context, index) {
          return BookTile(
            book: books[index],
            onTap: () => _openBook(books[index]),
          );
        },
      ),
    );
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder_off, size: 64, color: Color(0xFF9CA3AF)),
            const SizedBox(height: 16),
            const Text(
              'Storage Permission Required',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please grant storage permission to scan for PDF and EPUB files.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeApp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4299E1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Grant Permission'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.library_books, size: 64, color: Color(0xFF9CA3AF)),
            const SizedBox(height: 16),
            const Text(
              'No Books Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No PDF or EPUB files were found in Downloads, Documents, or Books folders.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBooks,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4299E1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Scan Again'),
            ),
          ],
        ),
      ),
    );
  }
}
