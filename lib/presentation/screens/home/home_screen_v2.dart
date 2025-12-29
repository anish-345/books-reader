import 'dart:io';

import 'package:book_reader/data/models/book_file_v2.dart';
import 'package:book_reader/presentation/screens/home/widgets/bookmarks_tab.dart';
import 'package:book_reader/presentation/screens/home/widgets/library_tab.dart';
import 'package:book_reader/presentation/screens/home/widgets/recent_tab.dart';
import 'package:book_reader/services/book_cache_service.dart';
import 'package:book_reader/services/file_scanner_service.dart';
import 'package:book_reader/services/permission_service.dart';
import 'package:book_reader/services/reading_history_service.dart';
import 'package:book_reader/services/sample_books_service.dart';
import 'package:flutter/material.dart';

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
      await _loadBooksFromCache();
      await _refreshBooks(isSilent: true);
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkPermissions() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final hasPermission = await PermissionService.hasStoragePermission();
      if (!hasPermission) {
        final granted = await PermissionService.requestStoragePermission();
        setState(() => _hasPermission = granted);
      } else {
        setState(() => _hasPermission = true);
      }
    } else {
      setState(() => _hasPermission = true);
    }
  }

  Future<void> _loadBooksFromCache() async {
    final cachedBooks = await BookCacheService.loadBooks();
    final recentBooks = await ReadingHistoryService.getRecentlyRead();

    if (mounted) {
      setState(() {
        _allBooks = cachedBooks;
        _recentBooks = recentBooks;
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshBooks({bool isSilent = false}) async {
    if (!isSilent) {
      setState(() => _isLoading = true);
    }

    try {
      final scannedBooks = await FileScannerService.scanForBooks();
      final recentBooks = await ReadingHistoryService.getRecentlyRead();

      List<BookFileV2> allBooks = scannedBooks;
      if (SampleBooksService.shouldShowSampleBooks(scannedBooks)) {
        final sampleBooks = await SampleBooksService.getSampleBooks();
        allBooks = [...sampleBooks, ...scannedBooks];
      }

      if (mounted) {
        setState(() {
          _allBooks = allBooks;
          _recentBooks = recentBooks;
        });
      }

      await BookCacheService.saveBooks(allBooks);
    } catch (e) {
      // Silent error handling
    }

    if (mounted && !isSilent) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshRecentBooks() async {
    final recentBooks = await ReadingHistoryService.getRecentlyRead();
    if (mounted) {
      setState(() {
        _recentBooks = recentBooks.take(20).toList();
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
    bool isDesktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;

    return Scaffold(
      body: isDesktop
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  labelType: NavigationRailLabelType.all,
                  indicatorColor: Colors.grey[300],
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.library_books_outlined),
                      selectedIcon: Icon(Icons.library_books),
                      label: Text('Library'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.history_outlined),
                      selectedIcon: Icon(Icons.history),
                      label: Text('Recent'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.bookmark_border),
                      selectedIcon: Icon(Icons.bookmark),
                      label: Text('Bookmarks'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: _screens[_selectedIndex]),
              ],
            )
          : _screens[_selectedIndex],
      bottomNavigationBar: isDesktop
          ? null
          : BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
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
    );
  }
}
