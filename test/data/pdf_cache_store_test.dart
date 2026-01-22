import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kkomi/core/data/pdf_cache_store.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../helpers/mock_path_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PdfCacheStore Tests', () {
    late Directory testCacheDir;

    setUp(() async {
      // Mock path_provider to use a test directory
      testCacheDir = await Directory.systemTemp.createTemp('pdf_cache_test_');
      PathProviderPlatform.instance = MockPathProviderPlatform(testCacheDir);

      // Reset cache directory for each test
      final cacheDir = Directory('${testCacheDir.path}/pdf_cache');
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
    });

    tearDown(() async {
      // Clean up test directory
      if (await testCacheDir.exists()) {
        await testCacheDir.delete(recursive: true);
      }
    });

    test('should save and retrieve cached PDF', () async {
      final store = PdfCacheStore.instance;
      final testPath = '/test/document.hwp';
      final testBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

      // Save to cache
      await store.savePdfToCache(testPath, testBytes);

      // Retrieve from cache
      final cachedBytes = await store.getCachedPdf(testPath);

      expect(cachedBytes, isNotNull);
      expect(cachedBytes, equals(testBytes));
    });

    test('should return null for non-existent cache', () async {
      final store = PdfCacheStore.instance;
      final testPath = '/test/nonexistent.hwp';

      final cachedBytes = await store.getCachedPdf(testPath);

      expect(cachedBytes, isNull);
    });

    test('should use same hash for same file path', () async {
      final store = PdfCacheStore.instance;
      final testPath = '/test/document.hwp';
      final testBytes1 = Uint8List.fromList([1, 2, 3]);
      final testBytes2 = Uint8List.fromList([4, 5, 6]);

      // Save first version
      await store.savePdfToCache(testPath, testBytes1);

      // Save again with different bytes (should overwrite)
      await store.savePdfToCache(testPath, testBytes2);

      // Retrieve should return the latest version
      final cachedBytes = await store.getCachedPdf(testPath);

      expect(cachedBytes, isNotNull);
      expect(cachedBytes, equals(testBytes2));
    });

    test('should remove specific cached PDF', () async {
      final store = PdfCacheStore.instance;
      final testPath = '/test/document.hwp';
      final testBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

      // Save to cache
      await store.savePdfToCache(testPath, testBytes);

      // Verify it exists
      var cachedBytes = await store.getCachedPdf(testPath);
      expect(cachedBytes, isNotNull);

      // Remove from cache
      await store.removeCachedPdf(testPath);

      // Verify it's removed
      cachedBytes = await store.getCachedPdf(testPath);
      expect(cachedBytes, isNull);
    });

    test('should cleanup old cache when exceeding 10 items', () async {
      final store = PdfCacheStore.instance;

      // Create 12 cache files with different timestamps
      for (var i = 0; i < 12; i++) {
        final testPath = '/test/document_$i.hwp';
        final testBytes = Uint8List.fromList([i, i + 1, i + 2]);
        await store.savePdfToCache(testPath, testBytes);

        // Add small delay to ensure different modification times
        await Future.delayed(const Duration(milliseconds: 10));
      }

      // Get cache stats
      final stats = await store.getCacheStats();

      // Should only have 10 files (oldest 2 should be removed)
      expect(stats['count'], equals(10));
    });

    test('should provide correct cache statistics', () async {
      final store = PdfCacheStore.instance;

      // Initially empty
      var stats = await store.getCacheStats();
      expect(stats['count'], equals(0));
      expect(stats['totalSize'], equals(0));

      // Add some cache files
      final testBytes1 = Uint8List.fromList(List.filled(1024, 1)); // 1KB
      final testBytes2 = Uint8List.fromList(List.filled(2048, 2)); // 2KB

      await store.savePdfToCache('/test/doc1.hwp', testBytes1);
      await store.savePdfToCache('/test/doc2.hwp', testBytes2);

      // Check updated stats
      stats = await store.getCacheStats();
      expect(stats['count'], equals(2));
      expect(stats['totalSize'], equals(1024 + 2048));
    });

    test('should clear all cache', () async {
      final store = PdfCacheStore.instance;

      // Add some cache files
      for (var i = 0; i < 5; i++) {
        final testPath = '/test/document_$i.hwp';
        final testBytes = Uint8List.fromList([i, i + 1, i + 2]);
        await store.savePdfToCache(testPath, testBytes);
      }

      // Verify cache exists
      var stats = await store.getCacheStats();
      expect(stats['count'], greaterThan(0));

      // Clear all cache
      await store.clearAllCache();

      // Verify cache is empty
      stats = await store.getCacheStats();
      expect(stats['count'], equals(0));
    });

    test('should handle concurrent cache operations', () async {
      final store = PdfCacheStore.instance;

      // Create multiple concurrent save operations
      final futures = <Future>[];
      for (var i = 0; i < 5; i++) {
        final testPath = '/test/concurrent_$i.hwp';
        final testBytes = Uint8List.fromList([i, i + 1, i + 2]);
        futures.add(store.savePdfToCache(testPath, testBytes));
      }

      // Wait for all operations to complete
      await Future.wait(futures);

      // Verify all were saved
      final stats = await store.getCacheStats();
      expect(stats['count'], equals(5));
    });
  });
}
