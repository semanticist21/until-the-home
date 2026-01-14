import 'package:flutter/material.dart';

import '../../core/data/recent_documents_store.dart';
import '../pdf_viewer/index.dart';

bool openRecentDocumentPdf(BuildContext context, RecentDocument doc) {
  if (doc.type != 'PDF') {
    return false;
  }

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => PdfViewerScreen(assetPath: doc.path, title: doc.name),
    ),
  );
  return true;
}
