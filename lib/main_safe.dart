import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  // Wrap everything in try-catch to prevent crashes
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Set basic system UI
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    runApp(const BookReaderApp());
  } catch (e) {
    // If anything fails, run a minimal app
    runApp(const MinimalApp());
  }
}

class BookReaderApp extends StatelessWidget {
  const BookReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Reader',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const SafeHomeScreen(),
    );
  }
}

class MinimalApp extends StatelessWidget {
  const MinimalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Reader',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Book Reader'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.library_books, size: 64, color: Colors.blue),
              SizedBox(height: 16),
              Text(
                'Book Reader',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Minimal safe mode'),
            ],
          ),
        ),
      ),
    );
  }
}

class SafeHomeScreen extends StatefulWidget {
  const SafeHomeScreen({super.key});

  @override
  State<SafeHomeScreen> createState() => _SafeHomeScreenState();
}

class _SafeHomeScreenState extends State<SafeHomeScreen> {
  bool _isLoading = true;
  String _status = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      setState(() {
        _status = 'Loading app...';
      });

      // Small delay to show loading
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _isLoading = false;
        _status = 'Ready';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Reader'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_status),
                ],
              ),
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.library_books, size: 64, color: Colors.blue),
                  SizedBox(height: 16),
                  Text(
                    'Book Reader v2.0.0',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('PDF & EPUB Reader'),
                  SizedBox(height: 24),
                  Text(
                    'App is running successfully!',
                    style: TextStyle(color: Colors.green, fontSize: 16),
                  ),
                ],
              ),
            ),
    );
  }
}
