# Format Handlers Reference

## Quick Reference: How Each Format is Handled

### 🟢 Native Viewer (Full Reading Experience)
```
PDF → PdfViewerScreen
```
- Smooth scrolling
- Page navigation
- Page counter
- Dark background

---

### 🔵 Text Viewer (Readable Text Formats)
```
TXT  → TextViewerScreen
HTML → TextViewerScreen (monospace)
HTM  → TextViewerScreen (monospace)
XML  → TextViewerScreen (monospace)
JSON → TextViewerScreen (monospace)
MD   → TextViewerScreen (monospace)
CSV  → TextViewerScreen
LOG  → TextViewerScreen
```
- Font size control (12, 16, 20, 24)
- Dark mode toggle
- Selectable text
- Monospace font for code files
- File type label in header

---

### 🟡 Generic Viewer (Info Display)
```
EPUB  → GenericViewerScreen
MOBI  → GenericViewerScreen
AZW   → GenericViewerScreen
AZW3  → GenericViewerScreen
FB2   → GenericViewerScreen
RTF   → GenericViewerScreen
DjVu  → GenericViewerScreen
DOC   → GenericViewerScreen
DOCX  → GenericViewerScreen
ODT   → GenericViewerScreen
PPT   → GenericViewerScreen
PPTX  → GenericViewerScreen
ODP   → GenericViewerScreen
XLS   → GenericViewerScreen
XLSX  → GenericViewerScreen
ODS   → GenericViewerScreen
```
- File information
- Format-specific icon
- File size and date
- Copy path button
- Placeholder for future viewers

---

## Implementation Details

### File Service (file_service.dart)
**Supported Formats Array:**
```dart
final supportedFormats = [
  // Books
  '.pdf', '.epub', '.txt', '.mobi', '.azw', '.azw3', '.fb2', '.rtf', '.djvu',
  // Documents
  '.doc', '.docx', '.odt',
  // Presentations
  '.ppt', '.pptx', '.odp',
  // Spreadsheets
  '.xls', '.xlsx', '.ods', '.csv',
  // Other
  '.html', '.htm', '.xml', '.json', '.md', '.log',
];
```

### Home Screen (home_screen.dart)
**Routing Logic:**
```dart
void _openBook(BookFile book) {
  switch (book.type.toLowerCase()) {
    case 'pdf':
      return PdfViewerScreen(bookFile: book);
    
    case 'txt':
    case 'html':
    case 'htm':
    case 'xml':
    case 'json':
    case 'md':
    case 'log':
    case 'csv':
      return TextViewerScreen(bookFile: book);
    
    default:
      return GenericViewerScreen(bookFile: book);
  }
}
```

### Book Model (book_file.dart)
**Type Display Names:**
```dart
String get typeDisplayName {
  switch (type.toLowerCase()) {
    case 'pdf': return 'PDF';
    case 'epub': return 'EPUB';
    case 'doc': case 'docx': return 'Word';
    case 'ppt': case 'pptx': return 'PowerPoint';
    case 'xls': case 'xlsx': return 'Excel';
    case 'html': case 'htm': return 'HTML';
    case 'json': return 'JSON';
    case 'md': return 'Markdown';
    // ... etc
  }
}
```

**Categories:**
```dart
String get category {
  switch (type.toLowerCase()) {
    case 'pdf': case 'epub': case 'mobi': 
      return 'Books';
    case 'doc': case 'docx': case 'txt': 
      return 'Documents';
    case 'ppt': case 'pptx': 
      return 'Presentations';
    case 'xls': case 'xlsx': case 'csv': 
      return 'Spreadsheets';
    case 'html': case 'xml': case 'json': 
      return 'Code/Data';
  }
}
```

---

## Color Schemes

### Books
- PDF: Red (#E53E3E)
- EPUB: Green (#38A169)
- MOBI/AZW: Orange (#ED8936)
- FB2: Purple (#9F7AEA)
- DjVu: Indigo (#667EEA)

### Documents
- TXT: Blue (#4299E1)
- Word: Dark Blue (#2B6CB0)
- ODT: Blue (#3182CE)
- RTF: Green (#48BB78)

### Presentations
- PowerPoint: Orange (#D97706)
- ODP: Amber (#F59E0B)

### Spreadsheets
- Excel: Green (#059669)
- ODS: Emerald (#10B981)
- CSV: Teal (#14B8A6)

### Code/Data
- HTML: Red (#DC2626)
- XML: Purple (#7C3AED)
- JSON: Violet (#8B5CF6)
- Markdown: Indigo (#6366F1)
- LOG: Slate (#64748B)

---

## Adding New Format Support

### Step 1: Add to Supported Formats
```dart
// lib/services/file_service.dart
final supportedFormats = [
  // ... existing formats
  '.newformat',
];
```

### Step 2: Add Display Name
```dart
// lib/models/book_file.dart
String get typeDisplayName {
  switch (type.toLowerCase()) {
    // ... existing cases
    case 'newformat': return 'New Format';
  }
}
```

### Step 3: Add Category
```dart
// lib/models/book_file.dart
String get category {
  switch (type.toLowerCase()) {
    // ... existing cases
    case 'newformat': return 'Category Name';
  }
}
```

### Step 4: Add Color Scheme
```dart
// lib/widgets/book_tile.dart
Map<String, dynamic> _getColorForType(String type) {
  switch (type.toLowerCase()) {
    // ... existing cases
    case 'newformat':
      return {
        'bg': const Color(0xFFHEXCODE).withValues(alpha: 0.1),
        'color': const Color(0xFFHEXCODE),
        'icon': Icons.icon_name,
      };
  }
}
```

### Step 5: Add Routing
```dart
// lib/screens/home_screen.dart
void _openBook(BookFile book) {
  switch (book.type.toLowerCase()) {
    // ... existing cases
    case 'newformat':
      screen = YourViewerScreen(bookFile: book);
      break;
  }
}
```

### Step 6: Update Regex
```dart
// lib/models/book_file.dart
String get displayName {
  return name.replaceAll(
    RegExp(r'\.(existing|formats|newformat)$', caseSensitive: false),
    '',
  );
}
```

---

## Testing Checklist

- [ ] File appears in library after scanning
- [ ] Correct icon and color displayed
- [ ] Correct type label shown
- [ ] Opens in appropriate viewer
- [ ] No duplicate files
- [ ] File info displays correctly
- [ ] No crashes or errors

---

**Last Updated**: December 2024
