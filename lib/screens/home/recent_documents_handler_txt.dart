import 'package:flutter/material.dart';

import '../../core/data/recent_documents_store.dart';
import '../txt_viewer/index.dart';

bool openRecentDocumentTxt(BuildContext context, RecentDocument doc) {
  if (doc.type != 'TXT') {
    return false;
  }

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) =>
          TxtViewerScreen(filePath: doc.path, title: doc.name, isAsset: true),
    ),
  );
  return true;
}
