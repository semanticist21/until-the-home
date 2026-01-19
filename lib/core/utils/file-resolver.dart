// ignore_for_file: file_names

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import 'app_logger.dart';

class ResolvedFile {
  const ResolvedFile({
    required this.path,
    required this.displayName,
    required this.sizeBytes,
    required this.originalPath,
    required this.wasCopied,
  });

  final String path;
  final String displayName;
  final int? sizeBytes;
  final String originalPath;
  final bool wasCopied;
}

class FileResolver {
  FileResolver._();

  static const MethodChannel _channel = MethodChannel('kkomi.file_resolver');

  static Future<ResolvedFile> resolve(
    String path, {
    String? suggestedName,
  }) async {
    if (_isContentUri(path)) {
      return _copyContentUri(path, suggestedName: suggestedName);
    }

    final resolvedPath = _resolveFileUri(path);
    final displayName = suggestedName ?? p.basename(resolvedPath);
    final sizeBytes = await _readFileSize(resolvedPath);

    return ResolvedFile(
      path: resolvedPath,
      displayName: displayName.isEmpty ? 'shared_file' : displayName,
      sizeBytes: sizeBytes,
      originalPath: path,
      wasCopied: false,
    );
  }

  static bool _isContentUri(String path) => path.startsWith('content://');

  static String _resolveFileUri(String path) {
    if (!path.startsWith('file://')) {
      return path;
    }
    try {
      return Uri.parse(path).toFilePath();
    } catch (e, st) {
      appLogger.w(
        '[FileResolver] Failed to parse file URI: $path',
        error: e,
        stackTrace: st,
      );
      return path;
    }
  }

  static Future<ResolvedFile> _copyContentUri(
    String path, {
    String? suggestedName,
  }) async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      'copyContentUriToCache',
      {'uri': path, 'fileName': suggestedName},
    );

    if (result == null || result['path'] == null) {
      throw Exception('공유된 파일을 복사할 수 없습니다.');
    }

    final copiedPath = result['path'] as String;
    final displayName = (result['displayName'] as String?) ?? suggestedName;
    final sizeRaw = result['size'];
    final sizeBytes = sizeRaw is int
        ? sizeRaw
        : sizeRaw is num
        ? sizeRaw.toInt()
        : null;

    return ResolvedFile(
      path: copiedPath,
      displayName: displayName?.isNotEmpty == true
          ? displayName!
          : p.basename(copiedPath),
      sizeBytes: sizeBytes,
      originalPath: path,
      wasCopied: true,
    );
  }

  static Future<int?> _readFileSize(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) {
        return null;
      }
      return await file.length();
    } catch (e, st) {
      appLogger.w(
        '[FileResolver] Failed to read file size: $path',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }
}
