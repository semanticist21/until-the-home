package com.kobbokkom.kkomi

import android.net.Uri
import android.provider.OpenableColumns
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val channelName = "kkomi.file_resolver"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "copyContentUriToCache" -> {
                        val uriString = call.argument<String>("uri")
                        val fileNameHint = call.argument<String>("fileName")
                        if (uriString.isNullOrBlank()) {
                            result.error(
                                "invalid_uri",
                                "Missing uri argument",
                                null
                            )
                            return@setMethodCallHandler
                        }
                        try {
                            val payload = copyContentUriToCache(uriString, fileNameHint)
                            result.success(payload)
                        } catch (e: Exception) {
                            result.error("copy_failed", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun copyContentUriToCache(
        uriString: String,
        fileNameHint: String?
    ): Map<String, Any?> {
        val uri = Uri.parse(uriString)
        val resolver = applicationContext.contentResolver

        var displayName: String? = null
        var size: Long? = null
        resolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME, OpenableColumns.SIZE), null, null, null)
            ?.use { cursor ->
                if (cursor.moveToFirst()) {
                    val nameIndex = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                    if (nameIndex >= 0) {
                        displayName = cursor.getString(nameIndex)
                    }
                    val sizeIndex = cursor.getColumnIndex(OpenableColumns.SIZE)
                    if (sizeIndex >= 0 && !cursor.isNull(sizeIndex)) {
                        size = cursor.getLong(sizeIndex)
                    }
                }
            }

        val resolvedName = when {
            !fileNameHint.isNullOrBlank() -> fileNameHint
            !displayName.isNullOrBlank() -> displayName
            else -> "shared_file"
        }

        val targetFile = createUniqueCacheFile(resolvedName)
        resolver.openInputStream(uri)?.use { input ->
            FileOutputStream(targetFile).use { output ->
                input.copyTo(output)
            }
        } ?: throw IllegalStateException("Unable to open input stream")

        if (size == null) {
            size = targetFile.length()
        }

        return mapOf(
            "path" to targetFile.absolutePath,
            "displayName" to resolvedName,
            "size" to size
        )
    }

    private fun createUniqueCacheFile(fileName: String): File {
        val safeName = fileName.replace(Regex("[\\\\/:*?\"<>|]"), "_")
        val cacheDir = applicationContext.cacheDir
        val baseName = safeName.substringBeforeLast('.', safeName)
        val extension = safeName.substringAfterLast('.', "")
        var candidate = File(cacheDir, safeName)
        if (!candidate.exists()) {
            return candidate
        }
        val timestamp = System.currentTimeMillis()
        val nextName = if (extension.isNotEmpty()) {
            "${baseName}_$timestamp.$extension"
        } else {
            "${baseName}_$timestamp"
        }
        candidate = File(cacheDir, nextName)
        return candidate
    }
}
