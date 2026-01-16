import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../core/data/recent_documents_store.dart';
import '../../core/utils/app_logger.dart';
import 'recent_documents_handlers.dart';

class OpenFileButton extends StatelessWidget {
  const OpenFileButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            appLogger.i('[OPEN_FILE_BUTTON] File picker opened');
            final result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: [
                'pdf',
                'hwp',
                'hwpx',
                'doc',
                'docx',
                'xls',
                'xlsx',
                'pptx',
                'csv',
                'txt',
              ],
            );
            final path = result?.files.single.path;
            appLogger.d('[OPEN_FILE_BUTTON] Selected path: $path');
            if (path == null || path.isEmpty) {
              appLogger.w('[OPEN_FILE_BUTTON] No file selected');
              return;
            }
            await RecentDocumentsStore.instance.addDocument(path);
            appLogger.i('[OPEN_FILE_BUTTON] Added to recent documents');

            // Open viewer after adding to recent documents
            final doc = RecentDocument(
              path: path,
              name: path.split('/').last,
              type: _getFileType(path),
              openedAt: DateTime.now(),
            );
            appLogger.d(
              '[OPEN_FILE_BUTTON] Created RecentDocument - type: ${doc.type}, name: ${doc.name}',
            );

            if (!context.mounted) return;

            appLogger.d('[OPEN_FILE_BUTTON] Opening viewer...');
            if (openRecentDocument(context, doc)) {
              appLogger.i('[OPEN_FILE_BUTTON] Handler succeeded');
            } else {
              appLogger.w('[OPEN_FILE_BUTTON] No handler found');
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/icons/open_file_empty.webp',
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '파일 열기',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'PDF · HWP · HWPX · DOC · DOCX · XLS · XLSX · PPTX · CSV · TXT',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                          height: 1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getFileType(String path) {
    final ext = path.split('.').last.toLowerCase();
    return ext.toUpperCase();
  }
}
