import 'dart:io';

import 'package:book_reader/core/error/app_error_handler.dart';
import 'package:book_reader/data/models/book_file_v2.dart';
import 'package:book_reader/presentation/screens/reader/epub_reader_v2.dart';
import 'package:book_reader/presentation/screens/reader/pdf_reader_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'package:path/path.dart' as p;

import 'core/theme/app_theme.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen_v2.dart';
import 'presentation/screens/home/home_screen_v2.dart';
import 'presentation/screens/splash/app_initializer.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main(List<String> args) async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await windowManager.ensureInitialized();

      WindowOptions windowOptions = const WindowOptions(
        minimumSize: Size(800, 600),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.normal,
      );
      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
        await windowManager.setTitle('EPUB & PDF Reader');
      });
    }

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    Widget home = const SplashScreen();

    if (args.isNotEmpty) {
      final file = File(args.first);
      if (await file.exists()) {
        final book = BookFileV2(
          id: file.path,
          path: file.path,
          name: p.basename(file.path),
          type: p.extension(file.path).replaceAll('.', ''),
          size: await file.length(),
          lastModified: await file.lastModified(),
          dateAdded: DateTime.now(),
        );

        if (book.type == 'pdf') {
          home = PDFReaderScreen(book: book);
        } else if (book.type == 'epub') {
          home = EpubReaderV2(book: book);
        }
      }
    }

    runApp(PDFEpubReaderV2(home: home));
  } catch (e, s) {
    AppErrorHandler.handleError(e, s);
    runApp(const PDFEpubReaderV2(home: SplashScreen()));
  }
}

class PDFEpubReaderV2 extends StatelessWidget {
  final Widget home;
  const PDFEpubReaderV2({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EPUB & PDF Reader',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      navigatorKey: navigatorKey,
      home: home,
      routes: {
        '/home': (context) => const HomeScreenV2(),
        '/onboarding': (context) => const OnboardingScreenV2(),
        '/app-initializer': (context) => const AppInitializer(),
      },
    );
  }
}
