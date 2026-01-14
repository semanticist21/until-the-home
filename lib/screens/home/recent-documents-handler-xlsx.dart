import 'package:flutter/material.dart';

import '../../core/data/recent_documents_store.dart';
import '../docx_viewer/index.dart';

bool openRecentDocumentXlsx(BuildContext context, RecentDocument doc) {
  if (doc.type != 'XLSX') {
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
