import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../models/book_file.dart';

class PdfViewerScreen extends StatefulWidget {
  final BookFile bookFile;

  const PdfViewerScreen({super.key, required this.bookFile});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  int currentPage = 0;
  int totalPages = 0;
  bool isReady = false;
  String errorMessage = '';
  PDFViewController? pdfController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _goToPage(int page) async {
    if (pdfController != null && page >= 0 && page < totalPages) {
      HapticFeedback.lightImpact();
      try {
        await pdfController!.setPage(page);
        setState(() {
          currentPage = page;
        });
      } catch (e) {
        debugPrint('Error navigating to page $page: $e');
      }
    }
  }

  void _nextPage() {
    if (currentPage < totalPages - 1) {
      _goToPage(currentPage + 1);
    }
  }

  void _previousPage() {
    if (currentPage > 0) {
      _goToPage(currentPage - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.bookFile.displayName,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Stack(
        children: [
          if (errorMessage.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.white70,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Error Loading PDF',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              color: Colors.black,
              width: double.infinity,
              height: double.infinity,
              child: ClipRect(
                child: PDFView(
                  filePath: widget.bookFile.path,
                  enableSwipe: true,
                  swipeHorizontal: false,
                  autoSpacing: false,
                  pageFling: false,
                  pageSnap: false,
                  defaultPage: currentPage,
                  fitPolicy: FitPolicy.BOTH,
                  preventLinkNavigation: false,
                  nightMode: false,
                  onRender: (pages) {
                    setState(() {
                      totalPages = pages!;
                      isReady = true;
                    });
                  },
                  onError: (error) {
                    setState(() {
                      errorMessage = error.toString();
                    });
                  },
                  onPageError: (page, error) {
                    setState(() {
                      errorMessage = 'Error on page $page: $error';
                    });
                  },
                  onViewCreated: (PDFViewController controller) {
                    pdfController = controller;
                  },
                  onLinkHandler: (String? uri) {
                    // Handle link clicks
                  },
                  onPageChanged: (int? page, int? total) {
                    setState(() {
                      currentPage = page ?? 0;
                    });
                  },
                ),
              ),
            ),
          if (!isReady && errorMessage.isEmpty)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          // Page indicator at bottom
          if (isReady && totalPages > 1)
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
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${currentPage + 1} of $totalPages',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          // Page navigation buttons (left/right sides)
          if (isReady && totalPages > 1) ...[
            // Previous page (left side)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 80,
              child: GestureDetector(
                onTap: _previousPage,
                child: Container(
                  color: Colors.transparent,
                  child: currentPage > 0
                      ? const Center(
                          child: Icon(
                            Icons.chevron_left,
                            color: Colors.white30,
                            size: 32,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            // Next page (right side)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 80,
              child: GestureDetector(
                onTap: _nextPage,
                child: Container(
                  color: Colors.transparent,
                  child: currentPage < totalPages - 1
                      ? const Center(
                          child: Icon(
                            Icons.chevron_right,
                            color: Colors.white30,
                            size: 32,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
