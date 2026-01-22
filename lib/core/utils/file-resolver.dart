// ignore_for_file: file_names

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/pdf_cache_store.dart';
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
    appLogger.d('[FileResolver] Resolving path: $path');

    // Android content URI - 항상 복사
    if (_isContentUri(path)) {
      appLogger.d('[FileResolver] Detected content URI, copying...');
      return _copyContentUri(path, suggestedName: suggestedName);
    }

    final resolvedPath = _resolveFileUri(path);
    appLogger.d('[FileResolver] Resolved to: $resolvedPath');

    // iOS/Android 임시 디렉토리 파일 - 영구 저장소로 복사
    if (_isTemporaryPath(resolvedPath)) {
      appLogger.i('[FileResolver] Detected temporary path, copying to cache: $resolvedPath');
      return _copyFileToCache(resolvedPath, suggestedName: suggestedName);
    }

    // 일반 파일 경로 - 그대로 반환
    appLogger.d('[FileResolver] Regular file path, returning as-is');
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

  /// iOS /tmp 또는 Android /cache/ 디렉토리 체크
  /// 주의: /Library/Caches/는 영구 저장소이므로 제외
  static bool _isTemporaryPath(String path) {
    // /tmp/ (iOS 임시 디렉토리)
    if (path.contains('/tmp/')) {
      return true;
    }
    // /cache/ (Android 임시 디렉토리, 하지만 /Caches/는 제외)
    if (path.contains('/cache/') && !path.contains('/Caches/')) {
      return true;
    }
    return false;
  }

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

  /// 임시 파일을 영구 저장소로 복사 (iOS/Android) - Dart File I/O 사용
  static Future<ResolvedFile> _copyFileToCache(
    String path, {
    String? suggestedName,
  }) async {
    try {
      appLogger.d('[FileResolver] Copying file to cache: $path');

      // 소스 파일 확인
      final sourceFile = File(path);
      if (!await sourceFile.exists()) {
        throw Exception('Source file does not exist: $path');
      }

      // 캐시 디렉토리 가져오기 (Application Support 사용)
      final appSupportDir = await getApplicationSupportDirectory();
      final cacheDir = Directory('${appSupportDir.path}/file_cache');
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }
      appLogger.d('[FileResolver] Cache directory: ${cacheDir.path}');

      // 안전한 파일명 생성
      var fileName = suggestedName ?? p.basename(path);
      final safeName = fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');

      // 목적지 파일 경로 (중복 시 타임스탬프 추가)
      var destPath = p.join(cacheDir.path, safeName);
      if (await File(destPath).exists()) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final baseName = p.basenameWithoutExtension(safeName);
        final ext = p.extension(safeName);
        final uniqueName = '${baseName}_$timestamp$ext';
        destPath = p.join(cacheDir.path, uniqueName);
        appLogger.d('[FileResolver] File exists, using unique name: $uniqueName');
      }

      // 파일 복사
      appLogger.d('[FileResolver] Copying from $path to $destPath');
      final destFile = await sourceFile.copy(destPath);
      final sizeBytes = await destFile.length();

      appLogger.i('[FileResolver] File copied successfully to: $destPath (${sizeBytes} bytes)');

      // PDF 캐시 엔트리도 마이그레이션 (경로가 바뀌었으므로)
      await PdfCacheStore.instance.migrateCacheEntry(path, destPath);

      return ResolvedFile(
        path: destPath,
        displayName: p.basename(destPath),
        sizeBytes: sizeBytes,
        originalPath: path,
        wasCopied: true,
      );
    } catch (e, st) {
      appLogger.e(
        '[FileResolver] Failed to copy file to cache',
        error: e,
        stackTrace: st,
      );
      // 복사 실패 시 원본 경로 반환 (fallback)
      final displayName = suggestedName ?? p.basename(path);
      return ResolvedFile(
        path: path,
        displayName: displayName,
        sizeBytes: await _readFileSize(path),
        originalPath: path,
        wasCopied: false,
      );
    }
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
