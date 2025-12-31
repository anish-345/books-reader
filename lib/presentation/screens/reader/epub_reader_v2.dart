import 'dart:convert';
import 'dart:io';
import 'package:book_reader/data/models/reading_progress.dart';
import 'package:book_reader/services/reading_history_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_windows/webview_windows.dart';

import '../../../core/constants/text_styles.dart';
import '../../../data/models/book_file_v2.dart';
import '../../../models/annotation.dart';
import '../../../services/annotation_service.dart';
import '../../../services/epub_parser_service.dart';

class EpubReaderV2 extends StatefulWidget {
  final BookFileV2 book;
  final int? initialPage;

  const EpubReaderV2({super.key, required this.book, this.initialPage});

  @override
  State<EpubReaderV2> createState() => _EpubReaderV2State();
}

class _EpubReaderV2State extends State<EpubReaderV2> {
  WebviewController? _webviewController;
  String _cfi = '';
  bool _showControls = true;
  int _currentChapter = 0;
  List<EpubChapterData> _chapters = [];
  final FocusNode _focusNode = FocusNode();
  String? _initialCfi;
  double _fontSize = 16.0;

  @override
  void initState() {
    super.initState();
    _loadReadingProgress();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadReadingProgress() async {
    final progress = await ReadingHistoryService.getProgress(widget.book.id);
    if (progress != null) {
      setState(() {
        _initialCfi = progress.currentChapterId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            _webviewController?.runJavaScript('rendition.next()');
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            _webviewController?.runJavaScript('rendition.prev()');
          }
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            FutureBuilder<String>(
              future: _getHtmlContent(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (Platform.isWindows) {
                    return Webview(
                      onWebviewCreated: (controller) {
                        _webviewController = controller;
                        _webviewController!.loadUrl(Uri.dataFromString(
                          snapshot.data!,
                          mimeType: 'text/html',
                          encoding: Encoding.getByName('utf-8'),
                        ).toString());
                      },
                      javascriptChannels: {
                        JavascriptChannel(
                          name: 'AnnotationChannel',
                          onMessageReceived: (message) {
                            final selectionData = jsonDecode(message.message);
                            _showContextMenu(selectionData);
                          },
                        ),
                        JavascriptChannel(
                          name: 'RelocatedChannel',
                          onMessageReceived: (message) {
                            final cfi = message.message;
                            _saveProgress(cfi);
                          },
                        ),
                      },
                    );
                  } else {
                    return WebView(
                      onWebViewCreated: (controller) {
                        _webviewController = controller;
                        _webviewController!.loadUrl(Uri.dataFromString(
                          snapshot.data!,
                          mimeType: 'text/html',
                          encoding: Encoding.getByName('utf-8'),
                        ).toString());
                      },
                      javascriptChannels: {
                        JavascriptChannel(
                          name: 'AnnotationChannel',
                          onMessageReceived: (message) {
                            final selectionData = jsonDecode(message.message);
                            _showContextMenu(selectionData);
                          },
                        ),
                        JavascriptChannel(
                          name: 'RelocatedChannel',
                          onMessageReceived: (message) {
                            final cfi = message.message;
                            _saveProgress(cfi);
                          },
                        ),
                      },
                    );
                  }
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
            if (_showControls) _buildTopControls(),
            if (_showControls) _buildBottomChapterIndicator(),
          ],
        ),
      ),
    );
  }

  Future<String> _getHtmlContent() async {
    final epubData = await EpubParserService.parseEpubFile(widget.book.path);
    _chapters = epubData?.chapters ?? [];
    final js = await rootBundle.loadString('assets/js/epub_reader.js');
    final jszip = await rootBundle.loadString('assets/js/jszip.min.js');
    final epubjs = await rootBundle.loadString('assets/js/epub.min.js');
    final annotations = await AnnotationService.getAnnotationsForBook(widget.book.id);
    final annotationsJson = jsonEncode(annotations.map((a) => a.toJson()).toList());
    final bookData = await File(widget.book.path).readAsBytes();
    final bookDataBase64 = base64Encode(bookData);

    String html = await rootBundle.loadString('assets/epub_reader.html');
    html = html.replaceAll('{{book_data}}', bookDataBase64);
    html = html.replaceAll('{{annotations}}', annotationsJson);
    html = html.replaceAll('{{js}}', js);
    html = html.replaceAll('{{jszip}}', jszip);
    html = html.replaceAll('{{epubjs}}', epubjs);
    html = html.replaceAll('{{initial_cfi}}', _initialCfi ?? '');
    return html;
  }

  void _showContextMenu(Map<String, dynamic> selectionData) {
    _cfi = selectionData['cfi'];
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy'),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: selectionData['text']));
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.highlight),
                title: const Text('Highlight'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showColorPalette(context, (color) {
                    _addAnnotation(AnnotationType.highlight, color.value);
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.format_underline),
                title: const Text('Underline'),
                onTap: () {
                  Navigator.of(context).pop();
                  _addAnnotation(AnnotationType.underline,
                      Theme.of(context).colorScheme.onBackground.value);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showColorPalette(
      BuildContext context, void Function(Color) onColorSelected) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildColorOption(Colors.yellow, onColorSelected),
              _buildColorOption(Colors.green, onColorSelected),
              _buildColorOption(Colors.blue, onColorSelected),
              _buildColorOption(Colors.red, onColorSelected),
              _buildColorOption(Colors.purple, onColorSelected),
            ],
          ),
        );
      },
    );
  }

  Widget _buildColorOption(
      Color color, void Function(Color) onColorSelected) {
    return GestureDetector(
      onTap: () {
        onColorSelected(color);
        Navigator.of(context).pop();
      },
      child: CircleAvatar(
        backgroundColor: color,
        radius: 24,
      ),
    );
  }

  void _addAnnotation(AnnotationType type, int color) {
    final annotation = Annotation(
      id: const Uuid().v4(),
      bookId: widget.book.id,
      cfi: _cfi,
      type: type,
      color: color,
      createdAt: DateTime.now(),
    );
    AnnotationService.saveAnnotation(annotation);
    _webviewController
        ?.runJavaScript('window.applyAnnotation("$_cfi", "${type.name}", $color)');
  }

  Future<void> _saveProgress(String cfi) async {
    final progress = ReadingProgress(
      id: '${widget.book.id}_progress',
      bookId: widget.book.id,
      currentPage: _currentChapter + 1,
      progress: (_currentChapter + 1) / _chapters.length,
      lastReadAt: DateTime.now(),
      currentChapterId: cfi,
    );
    await ReadingHistoryService.saveProgress(progress);
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
                  child: Text(
                    widget.book.displayName,
                    style: AppTextStyles.h6.copyWith(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                      _webviewController?.runJavaScript(
                          'rendition.display("${chapter.href}")');
                      Navigator.pop(context);
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
                    setModalState(() {
                      _fontSize = value;
                    });
                    _webviewController?.runJavaScript(
                        'rendition.themes.fontSize("${value}px")');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
