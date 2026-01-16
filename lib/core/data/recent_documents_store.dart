import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

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
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      documents.value = [];
      return;
    }
    documents.value = decoded
        .whereType<Map>()
        .map((item) => RecentDocument.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> addDocument(String path) async {
    await load();
    final name = p.basename(path);
    final type = _extensionType(path);
    final now = DateTime.now();
    final List<RecentDocument> updated = [
      RecentDocument(path: path, name: name, type: type, openedAt: now),
      ...documents.value.where((doc) => doc.path != path),
    ];
    if (updated.length > _maxItems) {
      updated.removeRange(_maxItems, updated.length);
    }
    documents.value = updated;
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(updated.map((doc) => doc.toJson()).toList());
    await prefs.setString(_prefsKey, encoded);
  }

  Future<void> pruneMissingFiles() async {
    await load();
    final filtered = documents.value.where((doc) {
      try {
        return File(doc.path).existsSync();
      } catch (_) {
        return false;
      }
    }).toList();
    if (filtered.length == documents.value.length) {
      return;
    }
    documents.value = filtered;
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(filtered.map((doc) => doc.toJson()).toList());
    await prefs.setString(_prefsKey, encoded);
  }

  String _extensionType(String path) {
    final ext = p.extension(path).toLowerCase().replaceFirst('.', '');
    if (ext.isEmpty) {
      return 'FILE';
    }
    return ext.toUpperCase();
  }
}
