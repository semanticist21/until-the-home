import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/app_logger.dart';

/// PDF 변환 결과를 캐시하는 저장소
///
/// - 최근 문서 10개만 유지 (RecentDocumentsStore와 동기화)
/// - getApplicationSupportDirectory 사용 (앱 삭제 시까지 유지)
/// - 파일 경로 해시로 캐시 파일명 생성
class PdfCacheStore {
  PdfCacheStore._();
  static final PdfCacheStore instance = PdfCacheStore._();

  static const int _maxCacheCount = 10;
  static const String _cacheDirName = 'pdf_cache';

  Directory? _cacheDir;

  /// 캐시 디렉토리 초기화
  Future<Directory> _getCacheDir() async {
    // 캐시 디렉토리가 존재하는지 확인 (테스트 환경 대응)
    if (_cacheDir != null && await _cacheDir!.exists()) {
      return _cacheDir!;
    }

    final appSupportDir = await getApplicationSupportDirectory();
    _cacheDir = Directory('${appSupportDir.path}/$_cacheDirName');

    if (!await _cacheDir!.exists()) {
      await _cacheDir!.create(recursive: true);
      appLogger.i(
        '[PdfCacheStore] Cache directory created: ${_cacheDir!.path}',
      );
    }

    return _cacheDir!;
  }

  /// 파일 경로를 해시하여 캐시 파일명 생성
  String _getCacheFileName(String filePath) {
    final bytes = utf8.encode(filePath);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// 캐시된 PDF 가져오기
  Future<Uint8List?> getCachedPdf(String filePath) async {
    try {
      final cacheDir = await _getCacheDir();
      final cacheFileName = _getCacheFileName(filePath);
      final cacheFile = File('${cacheDir.path}/$cacheFileName.pdf');

      if (await cacheFile.exists()) {
        appLogger.d('[PdfCacheStore] Cache hit: $filePath');
        return await cacheFile.readAsBytes();
      }

      appLogger.d('[PdfCacheStore] Cache miss: $filePath');
      return null;
    } catch (e, st) {
      appLogger.e(
        '[PdfCacheStore] Error reading cache',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// PDF를 캐시에 저장
  Future<void> savePdfToCache(String filePath, Uint8List pdfBytes) async {
    try {
      final cacheDir = await _getCacheDir();
      final cacheFileName = _getCacheFileName(filePath);
      final cacheFile = File('${cacheDir.path}/$cacheFileName.pdf');

      await cacheFile.writeAsBytes(pdfBytes);
      appLogger.i(
        '[PdfCacheStore] Cached PDF: $filePath (${pdfBytes.length} bytes)',
      );

      // 캐시 개수 제한 확인 및 정리
      await _cleanupOldCache();
    } catch (e, st) {
      appLogger.e(
        '[PdfCacheStore] Error saving cache',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// 특정 파일의 캐시 삭제
  Future<void> removeCachedPdf(String filePath) async {
    try {
      final cacheDir = await _getCacheDir();
      final cacheFileName = _getCacheFileName(filePath);
      final cacheFile = File('${cacheDir.path}/$cacheFileName.pdf');

      if (await cacheFile.exists()) {
        await cacheFile.delete();
        appLogger.i('[PdfCacheStore] Removed cache: $filePath');
      }
    } catch (e, st) {
      appLogger.e(
        '[PdfCacheStore] Error removing cache',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// 오래된 캐시 정리 (최근 10개만 유지)
  Future<void> _cleanupOldCache() async {
    try {
      final cacheDir = await _getCacheDir();
      final files = await cacheDir.list().toList();

      // PDF 파일만 필터링
      final pdfFiles = files
          .whereType<File>()
          .where((f) => f.path.endsWith('.pdf'))
          .toList();

      if (pdfFiles.length <= _maxCacheCount) {
        return;
      }

      // 수정 시간 기준 정렬 (오래된 것부터)
      pdfFiles.sort((a, b) {
        final aStat = a.statSync();
        final bStat = b.statSync();
        return aStat.modified.compareTo(bStat.modified);
      });

      // 오래된 파일 삭제
      final filesToDelete = pdfFiles.take(pdfFiles.length - _maxCacheCount);
      for (final file in filesToDelete) {
        await file.delete();
        appLogger.d('[PdfCacheStore] Deleted old cache: ${file.path}');
      }

      appLogger.i(
        '[PdfCacheStore] Cleanup completed: ${filesToDelete.length} files removed',
      );
    } catch (e, st) {
      appLogger.e(
        '[PdfCacheStore] Error during cleanup',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// 모든 캐시 삭제
  Future<void> clearAllCache() async {
    try {
      final cacheDir = await _getCacheDir();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        _cacheDir = null;
        appLogger.i('[PdfCacheStore] All cache cleared');
      }
    } catch (e, st) {
      appLogger.e(
        '[PdfCacheStore] Error clearing cache',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// 캐시 엔트리를 다른 경로로 복사 (파일 경로 변경 시 사용)
  Future<void> migrateCacheEntry(String oldPath, String newPath) async {
    try {
      final cacheDir = await _getCacheDir();
      final oldCacheFileName = _getCacheFileName(oldPath);
      final newCacheFileName = _getCacheFileName(newPath);
      final oldCacheFile = File('${cacheDir.path}/$oldCacheFileName.pdf');
      final newCacheFile = File('${cacheDir.path}/$newCacheFileName.pdf');

      if (await oldCacheFile.exists() && !await newCacheFile.exists()) {
        await oldCacheFile.copy(newCacheFile.path);
        await oldCacheFile.delete();
        appLogger.i(
          '[PdfCacheStore] Migrated cache: $oldPath → $newPath',
        );
      }
    } catch (e, st) {
      appLogger.w(
        '[PdfCacheStore] Failed to migrate cache entry',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// 캐시 통계 정보
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final cacheDir = await _getCacheDir();
      final files = await cacheDir.list().toList();
      final pdfFiles = files
          .whereType<File>()
          .where((f) => f.path.endsWith('.pdf'))
          .toList();

      int totalSize = 0;
      for (final file in pdfFiles) {
        totalSize += await file.length();
      }

      return {
        'count': pdfFiles.length,
        'totalSize': totalSize,
        'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
      };
    } catch (e, st) {
      appLogger.e(
        '[PdfCacheStore] Error getting stats',
        error: e,
        stackTrace: st,
      );
      return {'count': 0, 'totalSize': 0, 'totalSizeMB': '0.00'};
    }
  }
}
