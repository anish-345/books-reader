import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../data/models/book_file_v2.dart';
import '../../../data/models/bookmark.dart';
import '../../../data/models/reading_progress.dart';
import '../../../services/bookmark_service.dart';
import '../../../services/reading_history_service.dart';

class PDFReaderScreen extends StatefulWidget {
  final BookFileV2 book;
  final int? initialPage;

  const PDFReaderScreen({super.key, required this.book, this.initialPage});

  @override
  State<PDFReaderScreen> createState() => _PDFReaderScreenState();
}

class _PDFReaderScreenState extends State<PDFReaderScreen> {
  PDFViewController? _pdfController;
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isReady = false;
  bool _showControls = true;

  ReadingProgress? _readingProgress;
  Timer? _hideControlsTimer;
  bool _isCurrentPageBookmarked = false;

  @override
  void initState() {
    super.initState();
    // Set initial page if provided (for bookmark navigation)
    if (widget.initialPage != null) {
      _currentPage = widget.initialPage!;
    } else {
      _loadReadingProgress();
    }
    _checkBookmarkStatus();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _saveProgress();
    super.dispose();
  }

  Future<void> _loadReadingProgress() async {
    final progress = await ReadingHistoryService.getProgress(widget.book.id);
    if (progress != null && mounted) {
      setState(() {
        _readingProgress = progress;
        _currentPage = progress.currentPage;
      });
    }
  }

  Future<void> _saveProgress() async {
    if (_totalPages > 0) {
      final progress = ReadingProgress(
        id: '${widget.book.id}_progress',
        bookId: widget.book.id,
        currentPage: _currentPage,
        progress: _currentPage / _totalPages,
        lastReadAt: DateTime.now(),
      );
      await ReadingHistoryService.saveProgress(progress);
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    // Auto-hide controls after 3 seconds when shown
    if (_showControls) {
      _startHideControlsTimer();
    } else {
      _hideControlsTimer?.cancel();
    }
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _showControls) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _goToPage(int page) {
    if (_pdfController != null && page >= 1 && page <= _totalPages) {
      _pdfController!.setPage(page - 1);
    }
  }

  Future<void> _checkBookmarkStatus() async {
    final isBookmarked = await BookmarkService.isPageBookmarked(
      widget.book.id,
      _currentPage,
    );
    if (mounted) {
      setState(() {
        _isCurrentPageBookmarked = isBookmarked;
      });
    }
  }

  Future<void> _toggleBookmark() async {
    try {
      if (_isCurrentPageBookmarked) {
        // Remove bookmark
        await BookmarkService.removeBookmarkByPage(
          widget.book.id,
          _currentPage,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bookmark removed'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Add bookmark
        final bookmark = Bookmark(
          id: BookmarkService.generateBookmarkId(),
          bookId: widget.book.id,
          bookTitle: widget.book.displayName,
          page: _currentPage,
          createdAt: DateTime.now(),
          type: BookmarkType.bookmark,
        );
        await BookmarkService.addBookmark(bookmark);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bookmark added'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
      await _checkBookmarkStatus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages) {
      _goToPage(_currentPage + 1);
      if (_showControls) {
        _startHideControlsTimer(); // Reset auto-hide timer
      }
    }
  }

  void _previousPage() {
    if (_currentPage > 1) {
      _goToPage(_currentPage - 1);
      if (_showControls) {
        _startHideControlsTimer(); // Reset auto-hide timer
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // PDF Viewer with smooth scrolling
          GestureDetector(
            onTapDown: (details) {
              final screenWidth = MediaQuery.of(context).size.width;
              final tapX = details.globalPosition.dx;

              // Left edge tap - previous page
              if (tapX < screenWidth * 0.2) {
                _previousPage();
              }
              // Right edge tap - next page
              else if (tapX > screenWidth * 0.8) {
                _nextPage();
              }
              // Center tap - toggle controls for full-screen experience
              else {
                _toggleControls();
              }
            },
            child: PDFView(
              filePath: widget.book.path,
              enableSwipe: true,
              swipeHorizontal:
                  isLandscape, // Horizontal in landscape, vertical in portrait
              autoSpacing: false, // No gaps between pages
              pageFling: false, // Smooth scrolling instead of page flinging
              pageSnap:
                  isLandscape, // Page snap in landscape for better navigation
              defaultPage: _currentPage - 1,
              fitPolicy: isLandscape
                  ? FitPolicy.BOTH
                  : FitPolicy.WIDTH, // Fit both in landscape
              preventLinkNavigation: false,
              onRender: (pages) {
                setState(() {
                  _totalPages = pages ?? 0;
                  _isReady = true;
                });
              },
              onViewCreated: (PDFViewController pdfViewController) {
                _pdfController = pdfViewController;
              },
              onPageChanged: (int? page, int? total) {
                setState(() {
                  _currentPage = (page ?? 0) + 1;
                });
                _saveProgress();
                _checkBookmarkStatus();
              },
              onError: (error) {
                debugPrint('PDF Error: $error');
              },
              onPageError: (page, error) {
                debugPrint('PDF Page Error: $page - $error');
              },
            ),
          ),

          // Bottom page counter (visible with controls)
          if (_isReady && _showControls)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Page $_currentPage of $_totalPages',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

          // Loading indicator
          if (!_isReady)
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          // Top controls
          if (_showControls)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: Text(
                            widget.book.displayName,
                            style: AppTextStyles.h6.copyWith(
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _isCurrentPageBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: _isCurrentPageBookmarked
                                ? AppColors.primary
                                : Colors.white,
                          ),
                          onPressed: _toggleBookmark,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                          ),
                          onPressed: () => _showOptionsMenu(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Page slider - vertical on right in portrait, horizontal at bottom in landscape
          if (_showControls && _isReady)
            isLandscape
                ? Positioned(
                    bottom: 16,
                    left: 100,
                    right: 100,
                    child: Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          // Current page number at left
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$_currentPage',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Horizontal slider
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 6,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 12,
                                ),
                                overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 0,
                                ),
                              ),
                              child: Slider(
                                value: _currentPage.toDouble(),
                                min: 1,
                                max: _totalPages.toDouble(),
                                divisions: _totalPages > 1
                                    ? _totalPages - 1
                                    : 1,
                                activeColor: AppColors.primary,
                                inactiveColor: Colors.white.withValues(
                                  alpha: 0.3,
                                ),
                                thumbColor: Colors.white,
                                onChanged: (value) {
                                  _goToPage(value.round());
                                  _startHideControlsTimer(); // Reset auto-hide timer
                                },
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Total pages at right
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$_totalPages',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Positioned(
                    right: 16,
                    top: 100,
                    bottom: 100,
                    child: Container(
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Column(
                        children: [
                          // Current page number at top
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              '$_currentPage',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          // Vertical slider
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 6,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 12,
                                ),
                                overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 0,
                                ),
                              ),
                              child: RotatedBox(
                                quarterTurns:
                                    1, // Rotate slider to be vertical (top to bottom)
                                child: Slider(
                                  value: _currentPage.toDouble(),
                                  min: 1,
                                  max: _totalPages.toDouble(),
                                  divisions: _totalPages > 1
                                      ? _totalPages - 1
                                      : 1,
                                  activeColor: AppColors.primary,
                                  inactiveColor: Colors.white.withValues(
                                    alpha: 0.3,
                                  ),
                                  thumbColor: Colors.white,
                                  onChanged: (value) {
                                    _goToPage(value.round());
                                    _startHideControlsTimer(); // Reset auto-hide timer
                                  },
                                ),
                              ),
                            ),
                          ),

                          // Total pages at bottom
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              '$_totalPages',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
        ],
      ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                _isCurrentPageBookmarked
                    ? Icons.bookmark_remove
                    : Icons.bookmark_add,
                color: _isCurrentPageBookmarked ? Colors.red : null,
              ),
              title: Text(
                _isCurrentPageBookmarked ? 'Remove Bookmark' : 'Add Bookmark',
              ),
              onTap: () {
                Navigator.pop(context);
                _toggleBookmark();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Share functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Book Info'),
              onTap: () {
                Navigator.pop(context);
                _showBookInfo();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBookInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.book.displayName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('File: ${widget.book.name}'),
            Text('Size: ${widget.book.sizeFormatted}'),
            Text('Type: ${widget.book.type.toUpperCase()}'),
            Text('Pages: $_totalPages'),
            if (_readingProgress != null)
              Text('Progress: ${(_readingProgress!.progress * 100).toInt()}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
