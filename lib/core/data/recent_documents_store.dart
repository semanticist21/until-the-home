import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_logger.dart';
import 'pdf_cache_store.dart';

class RecentDocument {
  const RecentDocument({
    required this.path,
    required this.name,
    required this.type,
    required this.openedAt,
  });

  final String path;
  final String name;
  final String type;
  final DateTime openedAt;

  Map<String, dynamic> toJson() => {
    'path': path,
    'name': name,
    'type': type,
    'openedAt': openedAt.toIso8601String(),
  };

  static RecentDocument fromJson(Map<String, dynamic> json) {
    return RecentDocument(
      path: json['path'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      openedAt: DateTime.parse(json['openedAt'] as String),
    );
  }
}

class RecentDocumentsStore {
  RecentDocumentsStore._();

  static final RecentDocumentsStore instance = RecentDocumentsStore._();

  static const _prefsKey = 'recent_documents_v1';
  static const _maxItems = 10;

  final ValueNotifier<List<RecentDocument>> documents = ValueNotifier([]);
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) {
      return;
    }
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) {
      documents.value = [];
      return;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        documents.value = [];
        return;
      }
      documents.value = decoded
          .whereType<Map>()
          .map(
            (item) => RecentDocument.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } catch (e, st) {
      appLogger.e(
        '[RECENT_DOCS] Failed to decode stored documents',
        error: e,
        stackTrace: st,
      );
      documents.value = [];
    }
  }

  Future<void> addDocument(
    String path, {
    String? name,
    String? type,
    DateTime? openedAt,
  }) async {
    await load();
    final resolvedName = name?.isNotEmpty == true ? name! : p.basename(path);
    final resolvedType = type?.isNotEmpty == true
        ? type!
        : _extensionType(path);
    final now = openedAt ?? DateTime.now();
    final List<RecentDocument> updated = [
      RecentDocument(
        path: path,
        name: resolvedName,
        type: resolvedType,
        openedAt: now,
      ),
      ...documents.value.where((doc) => doc.path != path),
    ];

    // 10개 초과 시 오래된 문서 제거 및 캐시 정리
    if (updated.length > _maxItems) {
      final removedDocs = updated.sublist(_maxItems);
      for (final doc in removedDocs) {
        await PdfCacheStore.instance.removeCachedPdf(doc.path);
        appLogger.d(
          '[RECENT_DOCS] Removed cache for old document: ${doc.name}',
        );
      }
      updated.removeRange(_maxItems, updated.length);
    }

    documents.value = updated;
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(updated.map((doc) => doc.toJson()).toList());
    await prefs.setString(_prefsKey, encoded);
  }

  Future<void> removeDocument(String path) async {
    await load();
    final filtered = documents.value.where((doc) => doc.path != path).toList();
    if (filtered.length == documents.value.length) {
      return;
    }

    // 캐시 정리
    await PdfCacheStore.instance.removeCachedPdf(path);
    appLogger.d('[RECENT_DOCS] Removed cache for document: $path');

    documents.value = filtered;
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(filtered.map((doc) => doc.toJson()).toList());
    await prefs.setString(_prefsKey, encoded);
  }

  Future<void> pruneMissingFiles() async {
    await load();
    final before = documents.value.length;
    final prunedDocs = <RecentDocument>[];

    final filtered = documents.value.where((doc) {
      try {
        if (_isAssetPath(doc.path) || _isContentUri(doc.path)) {
          // Keep all assets and content URIs - don't check if accessible
          // Content URIs may have temporary permissions that are restored later
          return true;
        }
        final file = _fileFromPath(doc.path);
        if (file == null) {
          prunedDocs.add(doc);
          return false; // Invalid file path
        }
        final exists = file.existsSync();
        if (!exists) {
          appLogger.w(
            '[RECENT_DOCS] Pruning missing file: ${doc.name} at ${doc.path}',
          );
          prunedDocs.add(doc);
        }
        return exists;
      } catch (e) {
        appLogger.e('[RECENT_DOCS] Error checking file: ${doc.name}', error: e);
        prunedDocs.add(doc);
        return false;
      }
    }).toList();

    final pruned = before - filtered.length;
    if (pruned > 0) {
      // 캐시 정리 (일관성 유지)
      for (final doc in prunedDocs) {
        await PdfCacheStore.instance.removeCachedPdf(doc.path);
        appLogger.d('[RECENT_DOCS] Removed cache for pruned document: ${doc.name}');
      }

      appLogger.i('[RECENT_DOCS] Pruned $pruned missing files');
      documents.value = filtered;
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(filtered.map((doc) => doc.toJson()).toList());
      await prefs.setString(_prefsKey, encoded);
    }
  }

  String _extensionType(String path) {
    final ext = p.extension(path).toLowerCase().replaceFirst('.', '');
    if (ext.isEmpty) {
      return 'FILE';
    }
    return ext.toUpperCase();
  }

  bool _isAssetPath(String path) {
    return path.startsWith('assets/') || path.startsWith('test_samples/');
  }

  bool _isContentUri(String path) {
    return path.startsWith('content://');
  }

  File? _fileFromPath(String path) {
    if (path.startsWith('file://')) {
      final uri = Uri.tryParse(path);
      if (uri != null) {
        return File.fromUri(uri);
      }
      return null;
    }
    if (path.startsWith('/')) {
      return File(path);
    }
    if (RegExp(r'^[A-Za-z]:\\').hasMatch(path)) {
      return File(path);
    }
    return null;
  }
}
