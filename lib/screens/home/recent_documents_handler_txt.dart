import 'package:flutter/material.dart';

import '../../core/data/recent_documents_store.dart';
import '../txt_viewer/index.dart';

bool _isAssetPath(String path) {
  return path.startsWith('test_samples/') || path.startsWith('assets/');
}

bool openRecentDocumentTxt(BuildContext context, RecentDocument doc) {
  if (doc.type != 'TXT') {
    return false;
  }

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => TxtViewerScreen(
        filePath: doc.path,
        title: doc.name,
        isAsset: _isAssetPath(doc.path),
      ),
    ),
  );
  return true;
}
