import 'package:flutter/material.dart';

import '../../core/data/recent_documents_store.dart';
import '../csv_viewer/index.dart';

bool openRecentDocumentCsv(BuildContext context, RecentDocument doc) {
  if (doc.type != 'CSV') {
    return false;
  }

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) =>
          CsvViewerScreen(filePath: doc.path, title: doc.name, isAsset: true),
    ),
  );
  return true;
}
