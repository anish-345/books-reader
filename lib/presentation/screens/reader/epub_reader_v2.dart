import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../core/constants/text_styles.dart';
import '../../../data/models/book_file_v2.dart';
import '../../../data/models/reading_progress.dart';
import '../../../services/reading_history_service.dart';
import '../../../services/epub_parser_service.dart';

class EpubReaderV2 extends StatefulWidget {
  final BookFileV2 book;
  final int? initialPage;

  const EpubReaderV2({super.key, required this.book, this.initialPage});

  @override
  State<EpubReaderV2> createState() => _EpubReaderV2State();
}

class _EpubReaderV2State extends State<EpubReaderV2> {
  late PageController _pageController;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  int _currentChapter = 0;
  bool _showControls = true;
  double _fontSize = 16.0;
  bool _isLoading = true;

  EpubBookData? _epubBook;
  List<EpubChapterData> _chapters = [];
  String _errorMessage = '';

  bool get _isDarkMode => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadEpubFile();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _saveProgress();
    _pageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadEpubFile() async {
    try {
      setState(() => _isLoading = true);

      final epubData = await EpubParserService.parseEpubFile(widget.book.path);
      if (epubData == null || epubData.chapters.isEmpty) {
        setState(() {
          _errorMessage = 'Failed to load EPUB file or no content found.';
          _isLoading = false;
        });
        return;
      }

      final progress = await ReadingHistoryService.getProgress(widget.book.id);

      int startingChapter = widget.initialPage ?? 0;
      if (widget.initialPage == null && progress != null) {
        startingChapter =
            (progress.currentPage - 1).clamp(0, epubData.chapters.length - 1);
      }

      setState(() {
        _epubBook = epubData;
        _chapters = epubData.chapters;
        _currentChapter = startingChapter;
        _pageController = PageController(initialPage: _currentChapter);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading EPUB: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProgress() async {
    if (_chapters.isNotEmpty) {
      final progress = ReadingProgress(
        id: '${widget.book.id}_progress',
        bookId: widget.book.id,
        currentPage: _currentChapter + 1,
        progress: (_currentChapter + 1) / _chapters.length,
        lastReadAt: DateTime.now(),
        currentChapterId: _chapters[_currentChapter].title,
      );
      await ReadingHistoryService.saveProgress(progress);
    }
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _nextChapter();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _previousChapter();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _scrollDown();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _scrollUp();
      }
    }
  }

  void _nextChapter() {
    if (_currentChapter < _chapters.length - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  void _previousChapter() {
    if (_currentChapter > 0) {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.offset + 100,
      duration: const Duration(milliseconds: 200),
      curve: Curves.ease,
    );
  }

  void _scrollUp() {
    _scrollController.animateTo(
      _scrollController.offset - 100,
      duration: const Duration(milliseconds: 200),
      curve: Curves.ease,
    );
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor =
        _isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty || _chapters.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.book.displayName)),
        body: Center(
            child: Text(_errorMessage.isNotEmpty
                ? _errorMessage
                : 'No content found.')),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,
        child: Stack(
          children: [
            GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(_focusNode);
                _toggleControls();
              },
              child: PageView.builder(
                controller: _pageController,
                itemCount: _chapters.length,
                onPageChanged: (index) {
                  setState(() => _currentChapter = index);
                  _saveProgress();
                },
                itemBuilder: (context, index) => _buildChapterContent(index),
              ),
            ),
            if (_showControls) _buildTopControls(),
            if (_showControls) _buildBottomChapterIndicator(),
          ],
        ),
      ),
      bottomNavigationBar: !_showControls ? const SizedBox.shrink() : null,
    );
  }

  Widget _buildChapterContent(int index) {
    final chapter = _chapters[index];
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 80),
          Text(chapter.title,
              style: TextStyle(
                  fontSize: _fontSize + 4, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Html(
            data: EpubParserService.cleanHtmlContent(chapter.content),
            style: {
              "body": Style(
                  fontSize: FontSize(_fontSize),
                  fontFamily: 'serif',
                  lineHeight: const LineHeight(1.6)),
            },
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
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
                colors: [Colors.black.withAlpha(178), Colors.transparent])),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop()),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_epubBook?.title ?? widget.book.displayName,
                          style: AppTextStyles.h6.copyWith(color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      if (_epubBook?.author != null &&
                          _epubBook!.author.isNotEmpty)
                        Text('by ${_epubBook!.author}',
                            style: AppTextStyles.labelSmall
                                .copyWith(color: Colors.white70),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                IconButton(
                    icon: const Icon(Icons.list, color: Colors.white),
                    onPressed: _showChapterList),
                IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: _showSettings),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomChapterIndicator() {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
              color: const Color(0xFF38A169).withAlpha(230),
              borderRadius: BorderRadius.circular(20)),
          child: Text('${_currentChapter + 1} of ${_chapters.length} chapters',
              style: AppTextStyles.labelMedium
                  .copyWith(color: Colors.white, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }

  void _showChapterList() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Chapters', style: AppTextStyles.h5),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _chapters.length,
                itemBuilder: (context, index) {
                  final chapter = _chapters[index];
                  return ListTile(
                    title: Text(chapter.title,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    leading: CircleAvatar(
                        backgroundColor: index == _currentChapter
                            ? const Color(0xFF38A169)
                            : Colors.grey,
                        child: Text('${index + 1}',
                            style: const TextStyle(color: Colors.white))),
                    onTap: () {
                      Navigator.pop(context);
                      _pageController.animateToPage(index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Reading Settings', style: AppTextStyles.h5),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Font Size'),
                subtitle: Slider(
                  value: _fontSize,
                  min: 12.0,
                  max: 24.0,
                  divisions: 12,
                  activeColor: const Color(0xFF38A169),
                  label: _fontSize.round().toString(),
                  onChanged: (value) {
                    setModalState(() => _fontSize = value);
                    setState(() => _fontSize = value);
                  },
                ),
              ),
              if (_epubBook != null) ...[
                const Divider(),
                ListTile(
                  title: const Text('Book Information',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_epubBook!.author.isNotEmpty)
                        Text('Author: ${_epubBook!.author}'),
                      Text('Chapters: ${_chapters.length}'),
                      if (_epubBook!.description.isNotEmpty)
                        Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(_epubBook!.description,
                                maxLines: 3, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
