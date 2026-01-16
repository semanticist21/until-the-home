import 'package:flutter/material.dart';

import '../../core/data/recent_documents_store.dart';
import 'recent_documents_handler_hwp.dart';

bool openRecentDocumentHwpx(BuildContext context, RecentDocument doc) {
  if (doc.type != 'HWPX') {
    return false;
  }

  return openRecentDocumentHwpLike(context, doc);
}
