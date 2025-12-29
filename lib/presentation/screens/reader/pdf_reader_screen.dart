import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
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
  // Common state
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isReady = false;
  bool _showControls = true;
  Timer? _hideControlsTimer;
  bool _isCurrentPageBookmarked = false;
  ReadingProgress? _readingProgress;

  // Platform-specific controllers
  PDFViewController? _pdfViewController; // For Android/iOS
  PdfViewerController? _pdfViewerController; // For Windows/Desktop
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      _pdfViewerController = PdfViewerController();
    }

    if (widget.initialPage != null) {
      _currentPage = widget.initialPage!;
    } else {
      _loadReadingProgress();
    }

    _checkBookmarkStatus();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _startHideControlsTimer();
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _saveProgress();
    _focusNode.dispose();

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
        progress: _totalPages > 0 ? _currentPage / _totalPages : 0,
        lastReadAt: DateTime.now(),
      );
      await ReadingHistoryService.saveProgress(progress);
    }
  }

  void _onPageChanged(int page) {
    if (mounted) {
      setState(() {
        _currentPage = page;
      });
      _saveProgress();
      _checkBookmarkStatus();
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideControlsTimer();
    } else {
      _hideControlsTimer?.cancel();
    }
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _showControls) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _goToPage(int page) {
    if (page >= 1 && page <= _totalPages) {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        _pdfViewerController?.jumpToPage(page);
      } else {
        _pdfViewController?.setPage(page - 1);
      }
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
        await BookmarkService.removeBookmarkByPage(widget.book.id, _currentPage);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bookmark removed'), duration: Duration(seconds: 2)),
          );
        }
      } else {
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
            const SnackBar(content: Text('Bookmark added'), duration: Duration(seconds: 2)),
          );
        }
      }
      await _checkBookmarkStatus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), duration: const Duration(seconds: 2)),
        );
      }
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages) {
      _goToPage(_currentPage + 1);
      if (_showControls) _startHideControlsTimer();
    }
  }

  void _previousPage() {
    if (_currentPage > 1) {
      _goToPage(_currentPage - 1);
      if (_showControls) _startHideControlsTimer();
    }
  }
  
  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final controller = _pdfViewerController;
        if (controller == null) return;

        if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          _nextPage();
        } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          _previousPage();
        } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          controller.jumpTo(yOffset: controller.scrollOffset.dy + 200.0);
        } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          controller.jumpTo(yOffset: controller.scrollOffset.dy - 200.0);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget viewer;
    bool isDesktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;

    if (isDesktop) {
      viewer = _buildDesktopViewer();
    } else if (Platform.isAndroid || Platform.isIOS) {
      viewer = _buildMobileViewer();
    } else {
      viewer = _buildUnsupportedView();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,
        child: Stack(
          children: [
            GestureDetector(
              onTapDown: (details) {
                 FocusScope.of(context).requestFocus(_focusNode);
                final screenWidth = MediaQuery.of(context).size.width;
                final tapX = details.globalPosition.dx;
                if (tapX < screenWidth * 0.2) {
                  _previousPage();
                } else if (tapX > screenWidth * 0.8) {
                  _nextPage();
                } else {
                  _toggleControls();
                }
              },
              child: viewer,
            ),
            if (!_isReady) const Center(child: CircularProgressIndicator(color: Colors.white)),
            if (_showControls) _buildTopControls(),
            if (_isReady && _showControls) _buildBottomPageCounter(),
            if (_showControls && _isReady) _buildVerticalSlider(),
          ],
        ),
      ),
      bottomNavigationBar:
          (!_showControls && !isDesktop) ? const SizedBox.shrink() : null,
    );
  }

  Widget _buildMobileViewer() {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return PDFView(
      filePath: widget.book.path,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: false,
      pageFling: false,
      pageSnap: false,
      defaultPage: _currentPage - 1,
      fitPolicy: isLandscape ? FitPolicy.BOTH : FitPolicy.WIDTH,
      preventLinkNavigation: false,
      onRender: (pages) {
        if(mounted){
          setState(() {
            _totalPages = pages ?? 0;
            _isReady = true;
          });
        }
      },
      onViewCreated: (PDFViewController pdfViewController) {
        _pdfViewController = pdfViewController;
        if(widget.initialPage != null){
           _goToPage(widget.initialPage!);
        }
      },
      onPageChanged: (int? page, int? total) => _onPageChanged((page ?? 0) + 1),
      onError: (error) {},
      onPageError: (page, error) {},
    );
  }

  Widget _buildDesktopViewer() {
    return SfPdfViewer.file(
      File(widget.book.path),
      controller: _pdfViewerController,
      onDocumentLoaded: (details) {
        if(mounted){
          setState(() {
            _totalPages = details.document.pages.count;
            _isReady = true;
          });
          _goToPage(_currentPage);
        }
      },
      onPageChanged: (details) => _onPageChanged(details.newPageNumber),
    );
  }

  Widget _buildUnsupportedView() {
    return const Center(child: Text('PDF viewing is not supported on this platform.', style: TextStyle(color: Colors.white)));
  }

  Widget _buildTopControls() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withAlpha(178), Colors.transparent],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Text(
                    widget.book.displayName,
                    style: AppTextStyles.h6.copyWith(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isCurrentPageBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: _isCurrentPageBookmarked ? AppColors.primary : Colors.white,
                  ),
                  onPressed: _toggleBookmark,
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: _showOptionsMenu,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomPageCounter() {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(178),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Page $_currentPage of $_totalPages',
            style: AppTextStyles.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalSlider() {
    return Positioned(
      right: 16,
      top: 100,
      bottom: 100,
      child: Container(
        width: 60,
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(178),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '$_currentPage',
                style: AppTextStyles.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 6,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
                ),
                child: RotatedBox(
                  quarterTurns: 1,
                  child: Slider(
                    value: _currentPage.toDouble(),
                    min: 1,
                    max: _totalPages.toDouble(),
                    divisions: _totalPages > 1 ? _totalPages - 1 : 1,
                    activeColor: AppColors.primary,
                    inactiveColor: Colors.white.withAlpha(77),
                    thumbColor: Colors.white,
                    onChanged: (value) {
                      _goToPage(value.round());
                      _startHideControlsTimer();
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '$_totalPages',
                style: AppTextStyles.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
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
                _isCurrentPageBookmarked ? Icons.bookmark_remove : Icons.bookmark_add,
                color: _isCurrentPageBookmarked ? Colors.red : null,
              ),
              title: Text(_isCurrentPageBookmarked ? 'Remove Bookmark' : 'Add Bookmark'),
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
