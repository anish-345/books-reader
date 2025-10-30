package com.example.pdf_viewer

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import java.io.File
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "pdf_epub_reader/intent"
    private var pendingFileIntent: Map<String, String>? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Set up method channel for file intents
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getPendingIntent" -> {
                    result.success(pendingFileIntent)
                    pendingFileIntent = null // Clear after sending
                }
                "readContentUri" -> {
                    val uriString = call.argument<String>("uri")
                    if (uriString != null) {
                        readContentUri(uriString, result)
                    } else {
                        result.error("INVALID_ARGUMENT", "URI is required", null)
                    }
                }
                "copyContentUriToCache" -> {
                    val uriString = call.argument<String>("uri")
                    if (uriString != null) {
                        copyContentUriToCache(uriString, result)
                    } else {
                        result.error("INVALID_ARGUMENT", "URI is required", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        try {
            super.onCreate(savedInstanceState)
            android.util.Log.d("MainActivity", "MainActivity created successfully")
            handleIntent(intent)
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "Error in onCreate", e)
            super.onCreate(savedInstanceState)
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        android.util.Log.d("MainActivity", "Handling intent: ${intent?.action}")
        
        if (intent?.action == Intent.ACTION_VIEW || intent?.action == Intent.ACTION_SEND) {
            val uri: Uri? = intent.data ?: intent.getParcelableExtra(Intent.EXTRA_STREAM)
            android.util.Log.d("MainActivity", "Intent URI: $uri")
            
            uri?.let {
                val filePath = getFilePathFromUri(it)
                val mimeType = intent.type
                android.util.Log.d("MainActivity", "File path: $filePath, MIME type: $mimeType")
                
                if (isValidBookFile(filePath, mimeType)) {
                    android.util.Log.d("MainActivity", "Valid book file detected")
                    val fileName = getFileNameFromUri(it) ?: "Unknown Document"
                    android.util.Log.d("MainActivity", "Extracted filename: $fileName")
                    
                    pendingFileIntent = mapOf(
                        "filePath" to (filePath ?: ""),
                        "mimeType" to (mimeType ?: ""),
                        "fileName" to fileName,
                        "uri" to it.toString()
                    )
                    
                    // If Flutter is ready, send immediately
                    flutterEngine?.let { engine ->
                        android.util.Log.d("MainActivity", "Sending intent to Flutter")
                        MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
                            .invokeMethod("handleFileIntent", pendingFileIntent)
                        pendingFileIntent = null
                    }
                } else {
                    android.util.Log.d("MainActivity", "File not supported or invalid")
                }
            }
        }
    }

    private fun isValidBookFile(filePath: String?, mimeType: String?): Boolean {
        return (mimeType?.contains("pdf") == true || 
                mimeType?.contains("epub") == true || 
                filePath?.endsWith(".pdf", ignoreCase = true) == true || 
                filePath?.endsWith(".epub", ignoreCase = true) == true)
    }

    private fun getFilePathFromUri(uri: Uri): String? {
        return when (uri.scheme) {
            "file" -> uri.path
            "content" -> {
                // For content URIs, return the URI string itself
                // Flutter will handle reading the content directly
                uri.toString()
            }
            else -> uri.toString()
        }
    }

    private fun readContentUri(uriString: String, result: MethodChannel.Result) {
        try {
            val uri = Uri.parse(uriString)
            val inputStream = contentResolver.openInputStream(uri)
            
            if (inputStream != null) {
                val bytes = inputStream.readBytes()
                inputStream.close()
                result.success(bytes)
            } else {
                result.error("READ_ERROR", "Could not open input stream for URI: $uriString", null)
            }
        } catch (e: Exception) {
            result.error("READ_ERROR", "Error reading content URI: ${e.message}", null)
        }
    }

    private fun copyContentUriToCache(uriString: String, result: MethodChannel.Result) {
        try {
            android.util.Log.d("MainActivity", "Copying content URI to cache: $uriString")
            val uri = Uri.parse(uriString)
            val inputStream = contentResolver.openInputStream(uri)
            
            if (inputStream != null) {
                // Get filename from URI
                val fileName = getFileNameFromUri(uri) ?: "temp_file_${System.currentTimeMillis()}"
                android.util.Log.d("MainActivity", "Extracted filename: $fileName")
                
                // Ensure proper extension
                val finalFileName = if (!fileName.endsWith(".pdf") && !fileName.endsWith(".epub")) {
                    val mimeType = contentResolver.getType(uri)
                    when {
                        mimeType?.contains("pdf") == true -> "$fileName.pdf"
                        mimeType?.contains("epub") == true -> "$fileName.epub"
                        else -> fileName
                    }
                } else {
                    fileName
                }
                
                // Create cache file with unique name to avoid conflicts
                val cacheFile = File(cacheDir, "shared_${System.currentTimeMillis()}_$finalFileName")
                android.util.Log.d("MainActivity", "Cache file path: ${cacheFile.absolutePath}")
                
                // Copy content to cache file
                inputStream.use { input ->
                    cacheFile.outputStream().use { output ->
                        val bytesWritten = input.copyTo(output)
                        android.util.Log.d("MainActivity", "Copied $bytesWritten bytes to cache")
                    }
                }
                
                if (cacheFile.exists() && cacheFile.length() > 0) {
                    android.util.Log.d("MainActivity", "Cache file created successfully: ${cacheFile.length()} bytes")
                    result.success(cacheFile.absolutePath)
                } else {
                    android.util.Log.e("MainActivity", "Cache file creation failed or empty")
                    result.error("COPY_ERROR", "Cache file creation failed or empty", null)
                }
            } else {
                android.util.Log.e("MainActivity", "Could not open input stream for URI: $uriString")
                result.error("COPY_ERROR", "Could not open input stream for URI: $uriString", null)
            }
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "Error copying content URI to cache", e)
            result.error("COPY_ERROR", "Error copying content URI to cache: ${e.message}", null)
        }
    }

    private fun getFileNameFromUri(uri: Uri): String? {
        var fileName: String? = null
        
        // Try to get filename from cursor
        try {
            val cursor = contentResolver.query(uri, null, null, null, null)
            cursor?.use {
                if (it.moveToFirst()) {
                    val displayNameIndex = it.getColumnIndex("_display_name")
                    if (displayNameIndex >= 0) {
                        fileName = it.getString(displayNameIndex)
                        android.util.Log.d("MainActivity", "Got filename from cursor: $fileName")
                    }
                }
            }
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "Error getting filename from cursor", e)
        }
        
        // Fallback to extracting from URI path
        if (fileName == null) {
            fileName = uri.lastPathSegment
            android.util.Log.d("MainActivity", "Got filename from URI path: $fileName")
        }
        
        // If still no proper filename, try to detect from content type
        if (fileName == null || fileName == "document" || !fileName.contains(".")) {
            try {
                val mimeType = contentResolver.getType(uri)
                android.util.Log.d("MainActivity", "Content MIME type: $mimeType")
                when {
                    mimeType?.contains("epub") == true -> fileName = "document.epub"
                    mimeType?.contains("pdf") == true -> fileName = "document.pdf"
                    else -> {
                        fileName = "shared_document"
                        android.util.Log.d("MainActivity", "Unknown MIME type, using generic filename")
                    }
                }
                if (fileName != null) {
                    android.util.Log.d("MainActivity", "Assigned filename based on MIME type: $fileName")
                }
            } catch (e: Exception) {
                android.util.Log.e("MainActivity", "Error getting MIME type", e)
                fileName = "shared_document"
            }
        }
        
        return fileName
    }
}