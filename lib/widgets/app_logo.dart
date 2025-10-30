import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLogo({super.key, this.size = 100, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.2),
      ),
      child: CustomPaint(
        painter: BookLogoPainter(
          color: color ?? Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

class BookLogoPainter extends CustomPainter {
  final Color color;

  BookLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Create gradient colors based on the provided image
    const darkBlue = Color(0xFF1E3A8A); // Dark blue
    const mediumBlue = Color(0xFF3B82F6); // Medium blue
    const lightBlue = Color(0xFF60A5FA); // Light blue

    // Main book body (dark blue)
    final bookPaint = Paint()
      ..color = darkBlue
      ..style = PaintingStyle.fill;

    final bookPath = Path();

    // Create the main book shape - rounded rectangle with curved spine
    bookPath.moveTo(width * 0.1, height * 0.25);
    bookPath.quadraticBezierTo(
      width * 0.05,
      height * 0.3,
      width * 0.05,
      height * 0.4,
    );
    bookPath.lineTo(width * 0.05, height * 0.75);
    bookPath.quadraticBezierTo(
      width * 0.05,
      height * 0.85,
      width * 0.1,
      height * 0.9,
    );
    bookPath.lineTo(width * 0.9, height * 0.9);
    bookPath.quadraticBezierTo(
      width * 0.95,
      height * 0.85,
      width * 0.95,
      height * 0.75,
    );
    bookPath.lineTo(width * 0.95, height * 0.4);
    bookPath.quadraticBezierTo(
      width * 0.95,
      height * 0.3,
      width * 0.9,
      height * 0.25,
    );
    bookPath.close();

    canvas.drawPath(bookPath, bookPaint);

    // Book pages (gradient effect)

    // Draw layered pages to create depth
    for (int i = 0; i < 3; i++) {
      final offset = i * 3.0;
      final pagePath = Path();

      pagePath.moveTo(width * 0.15 + offset, height * 0.15 - offset);
      pagePath.lineTo(width * 0.85 + offset, height * 0.1 - offset);
      pagePath.lineTo(width * 0.85 + offset, height * 0.2 - offset);
      pagePath.lineTo(width * 0.15 + offset, height * 0.25 - offset);
      pagePath.close();

      canvas.drawPath(
        pagePath,
        Paint()
          ..color = i == 0
              ? lightBlue
              : i == 1
              ? mediumBlue
              : darkBlue,
      );
    }

    // Add white highlights for the book spine
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    final highlightPath = Path();
    highlightPath.moveTo(width * 0.05, height * 0.4);
    highlightPath.lineTo(width * 0.15, height * 0.35);
    highlightPath.lineTo(width * 0.15, height * 0.8);
    highlightPath.lineTo(width * 0.05, height * 0.75);
    highlightPath.close();

    canvas.drawPath(highlightPath, highlightPaint);

    // Add bookmark ribbon
    final ribbonPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    final ribbonPath = Path();
    ribbonPath.moveTo(width * 0.8, height * 0.25);
    ribbonPath.lineTo(width * 0.85, height * 0.25);
    ribbonPath.lineTo(width * 0.85, height * 0.6);
    ribbonPath.lineTo(width * 0.825, height * 0.55);
    ribbonPath.lineTo(width * 0.8, height * 0.6);
    ribbonPath.close();

    canvas.drawPath(ribbonPath, ribbonPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
