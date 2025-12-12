import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerService {
  static Widget getPdfViewer(String filePath) {
    if (Platform.isAndroid || Platform.isIOS) {
      return PDFView(
        filePath: filePath,
      );
    } else if (Platform.isWindows) {
      return SfPdfViewer.file(
        File(filePath),
      );
    } else {
      return const Center(
        child: Text('PDF viewing is not supported on this platform.'),
      );
    }
  }
}
