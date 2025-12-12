# Supported File Formats

## 📚 Overview
The Document Reader app now supports **25+ file formats** across multiple categories with intelligent handling for each type.

---

## 📖 Books & eBooks (7 formats)

### ✅ Native Viewer
- **PDF** - Full native viewer with smooth scrolling, page navigation, and dark background

### 📋 Generic Viewer (Info Display)
- **EPUB** - Electronic Publication format
- **MOBI** - Mobipocket eBook format
- **AZW/AZW3** - Amazon Kindle formats
- **FB2** - FictionBook 2.0 format
- **DjVu** - Document image format

---

## 📄 Documents (5 formats)

### ✅ Text Viewer
- **TXT** - Plain text files with font size control and dark mode

### 📋 Generic Viewer (Info Display)
- **DOC/DOCX** - Microsoft Word documents
- **ODT** - OpenDocument Text format
- **RTF** - Rich Text Format

---

## 🎨 Presentations (3 formats)

### 📋 Generic Viewer (Info Display)
- **PPT/PPTX** - Microsoft PowerPoint presentations
- **ODP** - OpenDocument Presentation format

---

## 📊 Spreadsheets (4 formats)

### ✅ Text Viewer
- **CSV** - Comma-separated values (viewable as text)

### 📋 Generic Viewer (Info Display)
- **XLS/XLSX** - Microsoft Excel spreadsheets
- **ODS** - OpenDocument Spreadsheet format

---

## 💻 Code & Data Files (6 formats)

### ✅ Text Viewer (with monospace font)
- **HTML/HTM** - HyperText Markup Language
- **XML** - Extensible Markup Language
- **JSON** - JavaScript Object Notation
- **MD** - Markdown files
- **LOG** - Log files

---

## 🎯 Viewer Types Explained

### 1. Native Viewer (PDF)
- Full-featured reading experience
- Smooth continuous scrolling
- Page navigation (tap left/right)
- Page counter at bottom
- Dark background for comfortable reading

### 2. Text Viewer (TXT, HTML, XML, JSON, MD, CSV, LOG)
- Selectable text content
- Font size adjustment (Small, Medium, Large, Extra Large)
- Dark mode toggle
- Monospace font for code files
- File type indicator in header

### 3. Generic Viewer (All other formats)
- File information display
- Format-specific icon
- File size and modification date
- Copy file path to clipboard
- Placeholder for future native viewers

---

## 🎨 Visual Features

### Color-Coded Badges
Each file type has a unique color scheme:
- **PDF** - Red
- **EPUB** - Green
- **TXT** - Blue
- **Word (DOC/DOCX)** - Dark Blue
- **PowerPoint (PPT/PPTX)** - Orange
- **Excel (XLS/XLSX)** - Green
- **HTML** - Red
- **JSON** - Purple
- **Markdown** - Indigo
- And more...

### Format-Specific Icons
- 📕 PDF - picture_as_pdf
- 📗 EPUB - book
- 📘 Word - article
- 📙 PowerPoint - slideshow
- 📊 Excel - table_chart
- 💻 HTML - code
- 📝 Text - description
- And more...

---

## 📁 File Detection

### Scanned Directories
The app automatically scans these folders:
- `/storage/emulated/0/Download`
- `/storage/emulated/0/Downloads`
- `/storage/emulated/0/Documents`
- `/storage/emulated/0/Books`

### Smart Features
- **No Duplicates** - Advanced deduplication by path, name, and size
- **Recursive Scanning** - Finds files in subdirectories
- **Efficient** - Fast scanning with proper error handling
- **Permission Handling** - Graceful permission requests

---

## 🔄 File Categories

Files are automatically categorized:

### Books
PDF, EPUB, MOBI, AZW, AZW3, FB2, DjVu

### Documents
DOC, DOCX, ODT, TXT, RTF

### Presentations
PPT, PPTX, ODP

### Spreadsheets
XLS, XLSX, ODS, CSV

### Code/Data
HTML, HTM, XML, JSON, MD, LOG

---

## 🚀 Usage

### Opening Files
1. Launch the app
2. Grant storage permission when prompted
3. Browse your files in the library
4. Tap any file to open it

### Text Viewer Controls
- **Font Size** - Tap the text icon (Aa) in the toolbar
- **Dark Mode** - Tap the moon/sun icon
- **Select Text** - Long press and drag to select

### Generic Viewer
- **Copy Path** - Tap "Copy File Path" button
- **View Info** - See file size, format, and modification date

---

## 🎯 Future Enhancements

Potential native viewers for:
- [ ] EPUB reader with chapter navigation
- [ ] MOBI/AZW reader
- [ ] Basic DOC/DOCX viewer
- [ ] PowerPoint slide viewer
- [ ] Excel spreadsheet viewer
- [ ] Markdown renderer with formatting
- [ ] HTML renderer

---

## 📱 App Information

**Name**: Document Reader (formerly Book Reader)  
**Version**: 2.0.0+2  
**Platform**: Android  
**Minimum SDK**: API 21+  

---

## 🔧 Technical Details

### Dependencies
- `flutter_pdfview` - PDF rendering
- `permission_handler` - Storage permissions
- `path_provider` - File system access
- `shared_preferences` - Settings storage

### File Size Limits
- No hard limits imposed
- Large files may take longer to load
- Text files loaded entirely into memory

### Supported Encodings
- UTF-8 (primary)
- ASCII
- Most common text encodings

---

**Last Updated**: December 2024  
**Status**: ✅ Fully Functional
