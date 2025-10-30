# 🏗️ App Architecture - PDF EPUB Reader

## 📐 Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                   │
├─────────────────────────────────────────────────────────────┤
│  main.dart (App Entry + Permission Handling)               │
│  ├── HomeScreen (File List + Navigation)                   │
│  ├── PdfViewerScreen (PDF Reading)                         │
│  └── EpubViewerScreen (EPUB Reading)                       │
└─────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────┐
│                        SERVICE LAYER                        │
├─────────────────────────────────────────────────────────────┤
│  FileService (File Discovery + Deduplication)              │
│  ├── PermissionService (Android Permissions)               │
│  └── EpubService (EPUB Parsing + Content)                  │
└─────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────┐
│                         DATA LAYER                          │
├─────────────────────────────────────────────────────────────┤
│  BookFile (Data Model)                                     │
│  ├── File System (Storage Access)                          │
│  └── SharedPreferences (Settings Storage)                  │
└─────────────────────────────────────────────────────────────┘
```

## 🔧 Core Components

### **1. Main App (main.dart)**
```dart
MyApp (StatefulWidget)
├── Permission Request on Startup
├── Splash Screen with Loading
└── Navigation to HomeScreen
```

**Key Features**:
- Requests storage permissions immediately
- Shows loading while permissions are processed
- Handles permission denial gracefully

### **2. Home Screen (home_screen.dart)**
```dart
HomeScreen (StatefulWidget)
├── File List (ListView.builder)
├── Pull-to-Refresh (RefreshIndicator)
├── Empty State Handling
└── Navigation to Readers
```

**State Management**:
- `List<BookFile> books` - File list
- `bool isLoading` - Loading state
- `bool hasPermission` - Permission status

### **3. PDF Viewer (pdf_viewer_screen.dart)**
```dart
PdfViewerScreen (StatefulWidget)
├── PDFView Widget (flutter_pdfview)
├── Page Navigation (Left/Right Tap)
├── Page Indicator (Bottom Counter)
└── Error Handling
```

**Configuration**:
```dart
PDFView(
  autoSpacing: false,        // Seamless pages
  pageFling: false,          // Smooth scroll
  pageSnap: false,           // Continuous flow
  fitPolicy: FitPolicy.BOTH, // Full screen
)
```

### **4. EPUB Viewer (epub_viewer_screen.dart)**
```dart
EpubViewerScreen (StatefulWidget)
├── Chapter Navigation (PageView)
├── HTML Rendering (flutter_html)
├── Reading Settings (Font, Theme)
└── Progress Tracking
```

## 🔄 Data Flow

### **File Discovery Flow**
```
App Start → Permission Request → FileService.scanForBooks()
    ↓
Directory Resolution → File Scanning → Deduplication
    ↓
BookFile Creation → UI Update → Display List
```

### **Reading Flow**
```
File Selection → Type Detection (PDF/EPUB)
    ↓
PDF: PDFView Widget → Smooth Scrolling
EPUB: EPUB Parser → HTML Rendering → Chapter Navigation
```

## 🗂️ File Structure Details

### **Models (models/)**
```dart
// book_file.dart
class BookFile {
  String name;           // Display name
  String path;           // File system path
  String type;           // 'pdf' or 'epub'
  int size;              // File size in bytes
  DateTime lastModified; // Last modification date
  
  // Helper methods
  String get displayName;    // Name without extension
  String get sizeFormatted;  // Human readable size
}
```

### **Services (services/)**

#### **FileService**
```dart
class FileService {
  // Core Methods
  Future<bool> requestPermissions()
  Future<List<BookFile>> scanForBooks()
  
  // Private Methods
  Future<List<Directory>> _getPublicDirectories()
  Future<void> _scanDirectory(...)
  List<BookFile> _getSampleBooks()
}
```

**Deduplication Strategy**:
1. **Directory Level**: Resolve symbolic links to prevent duplicate scanning
2. **File Level**: Use `filename_filesize` as unique identifier
3. **Path Tracking**: Maintain `Set<String>` of processed paths

#### **PermissionService**
```dart
class PermissionService {
  static Future<bool> requestStoragePermission()
  static Future<bool> hasStoragePermission()
  static Future<void> openAppSettings()
}
```

**Permission Strategy**:
- Android 13+: Request media permissions
- Android 11-12: Request manage external storage
- Fallback: Basic storage permission

#### **EpubService**
```dart
class EpubService {
  static Future<EpubBook?> parseEpubFile(String filePath)
  static List<EpubChapter> getChapters(EpubBook book)
  static String getChapterContent(EpubChapter chapter)
  static String getBookTitle(EpubBook book)
  static String getBookAuthor(EpubBook book)
}
```

### **Widgets (widgets/)**
```dart
// book_tile.dart
class BookTile extends StatelessWidget {
  // Custom book list item with:
  // - File type icon (PDF/EPUB)
  // - File name and metadata
  // - Size and modification date
  // - Tap handling
}
```

## 🎨 UI Architecture

### **Design System**
```dart
// Colors
Primary: Color(0xFF4299E1)    // Blue
Background: Color(0xFFF8F9FA) // Light Gray
Text: Color(0xFF2D3748)       // Dark Gray
Success: Color(0xFF38A169)    // Green
Error: Color(0xFFE53E3E)      // Red

// Typography
Title: FontWeight.w600, 20px
Body: FontWeight.normal, 16px
Caption: FontWeight.w500, 14px
```

### **Component Hierarchy**
```
MaterialApp
└── Scaffold
    ├── AppBar (Title + Actions)
    ├── Body (Content Area)
    │   ├── ListView (File List)
    │   ├── PDFView (PDF Reader)
    │   └── PageView (EPUB Reader)
    └── BottomNavigationBar (Page Indicator)
```

## 🔧 State Management

### **Approach**: **setState() Pattern**
- Simple, effective for this app size
- Each screen manages its own state
- Services are stateless utility classes

### **State Flow**
```dart
// Home Screen State
class _HomeScreenState {
  List<BookFile> books = [];
  bool isLoading = true;
  bool hasPermission = false;
  
  // State Updates
  _initializeApp() → _loadBooks() → setState()
}

// PDF Viewer State  
class _PdfViewerScreenState {
  int currentPage = 0;
  int totalPages = 0;
  bool isReady = false;
  
  // State Updates
  onPageChanged() → setState()
}
```

## 🚀 Performance Optimizations

### **File Scanning**
- **Deduplication**: Prevents processing same files multiple times
- **Async Processing**: Non-blocking UI during file discovery
- **Error Isolation**: Individual file errors don't stop entire scan

### **UI Rendering**
- **ListView.builder**: Efficient list rendering for large file lists
- **Image Caching**: Automatic caching of file type icons
- **Smooth Animations**: 60fps scrolling in PDF viewer

### **Memory Management**
- **Proper Disposal**: All controllers and streams disposed
- **Lazy Loading**: Files loaded only when accessed
- **Resource Cleanup**: PDF and EPUB resources properly released

---

**🏗️ This architecture provides a solid foundation for a scalable, maintainable PDF/EPUB reader app.**