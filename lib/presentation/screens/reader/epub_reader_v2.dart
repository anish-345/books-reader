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
  PageController _pageController = PageController();
  int _currentChapter = 0;
  bool _showControls = true;
  double _fontSize = 16.0;
  bool _isLoading = true;

  EpubBookData? _epubBook;
  List<EpubChapterData> _chapters = [];
  String _errorMessage = '';

  bool get _isDarkMode => false; // Always use light mode

  @override
  void initState() {
    super.initState();
    _loadEpubFile();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _saveProgress();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadEpubFile() async {
    try {
      debugPrint('=== EPUB READER DEBUG ===');
      debugPrint('Loading EPUB file: ${widget.book.path}');
      debugPrint('Book type: ${widget.book.type}');
      debugPrint('Book name: ${widget.book.name}');

      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final epubData = await EpubParserService.parseEpubFile(widget.book.path);

      if (epubData != null) {
        debugPrint('EPUB parsed successfully');
        debugPrint('Title: ${epubData.title}');
        debugPrint('Author: ${epubData.author}');
        debugPrint('Chapters found: ${epubData.chapters.length}');

        for (int i = 0; i < epubData.chapters.length && i < 3; i++) {
          debugPrint('Chapter ${i + 1}: ${epubData.chapters[i].title}');
          debugPrint('Content length: ${epubData.chapters[i].content.length}');
        }

        setState(() {
          _epubBook = epubData;
          _chapters = epubData.chapters;
          _isLoading = false;
        });

        // Load reading progress after chapters are loaded
        await _loadReadingProgress();
      } else {
        debugPrint('EPUB parsing returned null');
        setState(() {
          _errorMessage = 'Failed to load EPUB file - parser returned null';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('EPUB loading error: $e');
      setState(() {
        _errorMessage = 'Error loading EPUB: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadReadingProgress() async {
    final progress = await ReadingHistoryService.getProgress(widget.book.id);
    if (progress != null && mounted && _chapters.isNotEmpty) {
      final chapterIndex = (progress.currentPage - 1).clamp(
        0,
        _chapters.length - 1,
      );
      setState(() {
        _currentChapter = chapterIndex;
      });
      _pageController = PageController(initialPage: _currentChapter);
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

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: _isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF38A169)),
              SizedBox(height: 16),
              Text('Loading EPUB...'),
            ],
          ),
        ),
      );
    }

    if (_errorMessage.isNotEmpty || _chapters.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.book.displayName)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage.isNotEmpty ? _errorMessage : 'No content found',
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
      body: Stack(
        children: [
          // EPUB Content
          GestureDetector(
            onTap: _toggleControls,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentChapter = index;
                });
                _saveProgress();
              },
              itemCount: _chapters.length,
              itemBuilder: (context, index) {
                return _buildChapterContent(index);
              },
            ),
          ),

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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _epubBook?.title ?? widget.book.displayName,
                                style: AppTextStyles.h6.copyWith(
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (_epubBook?.author != null &&
                                  _epubBook!.author.isNotEmpty)
                                Text(
                                  'by ${_epubBook!.author}',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: Colors.white70,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.list, color: Colors.white),
                          onPressed: () => _showChapterList(),
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white),
                          onPressed: () => _showSettings(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Bottom chapter indicator
          if (_showControls)
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
                    color: const Color(0xFF38A169).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentChapter + 1} of ${_chapters.length} chapters',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChapterContent(int index) {
    final chapter = _chapters[index];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 80), // Space for top controls
          // Chapter title
          Text(
            chapter.title,
            style: TextStyle(
              fontSize: _fontSize + 4,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // Chapter content using HTML renderer
          Html(
            data: EpubParserService.cleanHtmlContent(chapter.content),
            style: {
              "body": Style(
                fontSize: FontSize(_fontSize),
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontFamily: 'serif',
                lineHeight: const LineHeight(1.6),
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
              ),
              "p": Style(
                margin: Margins.only(bottom: 16),
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              "h1, h2, h3, h4, h5, h6": Style(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headlineMedium?.color,
                margin: Margins.only(top: 24, bottom: 16),
              ),
              "em, i": Style(fontStyle: FontStyle.italic),
              "strong, b": Style(fontWeight: FontWeight.bold),
              "blockquote": Style(
                margin: Margins.symmetric(vertical: 16, horizontal: 20),
                padding: HtmlPaddings.only(left: 16),
                border: Border(
                  left: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 3,
                  ),
                ),
              ),
            },
          ),

          const SizedBox(height: 100), // Space for bottom controls
        ],
      ),
    );
  }

  void _showChapterList() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Chapters', style: AppTextStyles.h5),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _chapters.length,
                itemBuilder: (context, index) {
                  final chapter = _chapters[index];
                  return ListTile(
                    title: Text(
                      chapter.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: index == _currentChapter
                          ? const Color(0xFF38A169)
                          : Colors.grey,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
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
      backgroundColor: _isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Reading Settings',
                style: AppTextStyles.h5.copyWith(
                  color: _isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              // Font size
              ListTile(
                title: Text(
                  'Font Size',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                subtitle: Slider(
                  value: _fontSize,
                  min: 12.0,
                  max: 24.0,
                  divisions: 12,
                  activeColor: const Color(0xFF38A169),
                  label: _fontSize.round().toString(),
                  onChanged: (value) {
                    setModalState(() {
                      _fontSize = value;
                    });
                    setState(() {
                      _fontSize = value;
                    });
                  },
                ),
              ),

              // Book info
              if (_epubBook != null) ...[
                const Divider(),
                ListTile(
                  title: Text(
                    'Book Information',
                    style: TextStyle(
                      color: _isDarkMode ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_epubBook!.author.isNotEmpty)
                        Text(
                          'Author: ${_epubBook!.author}',
                          style: TextStyle(
                            color: _isDarkMode
                                ? Colors.white70
                                : Colors.black54,
                          ),
                        ),
                      Text(
                        'Chapters: ${_chapters.length}',
                        style: TextStyle(
                          color: _isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      if (_epubBook!.description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _epubBook!.description,
                            style: TextStyle(
                              color: _isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
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
