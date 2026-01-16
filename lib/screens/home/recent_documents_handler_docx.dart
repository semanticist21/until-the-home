import 'package:flutter/material.dart';

import '../../core/data/recent_documents_store.dart';
import '../docx_viewer/index.dart';

bool openRecentDocumentDocx(BuildContext context, RecentDocument doc) {
  if (doc.type != 'DOCX') {
    return false;
  }

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) =>
          DocxViewerScreen(filePath: doc.path, title: doc.name, isAsset: true),
    ),
  );
  return true;
}
