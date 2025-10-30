# Intent Handling Test Guide

## Features Added:

### 1. File Manager Integration
- App now responds to "Open with" from file managers
- Supports both PDF and EPUB files
- Handles content URIs and file URIs
- Works with Downloads, Google Drive, and other file sources

### 2. Intent Filters Added:
- `android.intent.action.VIEW` for opening files
- `android.intent.action.SEND` for sharing files
- MIME types: `application/pdf`, `application/epub+zip`
- File extensions: `.pdf`, `.epub`
- Content URIs and file URIs

### 3. App Size Optimizations:
- ProGuard rules for code shrinking
- Resource optimization
- ABI splitting (separate APKs for different architectures)
- Removed unused dependencies
- Bundle optimization enabled

## Testing Steps:

1. **Install the app** on your device
2. **Download a PDF or EPUB file** to your device
3. **Open file manager** (Downloads, Files, Google Drive, etc.)
4. **Tap on a PDF or EPUB file**
5. **Select "Open with" or "Share"**
6. **Choose "Book Reader"** from the list
7. **Verify the file opens** in the reader

## Expected Behavior:
- File should open directly in the appropriate reader (PDF/EPUB)
- File gets added to reading history
- Navigation works properly
- App handles both local files and content URIs

## Size Reduction Features:
- Split APKs by architecture (arm64-v8a, armeabi-v7a)
- Code obfuscation and minification
- Resource shrinking
- Unused code removal
- Optimized packaging

## Supported File Sources:
- Device storage
- Downloads folder
- Google Drive
- Dropbox
- Email attachments
- Web downloads
- Any app that can share files