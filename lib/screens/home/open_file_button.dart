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
                'ppt',
                'pptx',
                'csv',
                'txt',
              ],
            );
            final path = result?.files.single.path;
            final fileSize = result?.files.single.size ?? 0;
            appLogger.d('[OPEN_FILE_BUTTON] Selected path: $path, size: $fileSize bytes');
            if (path == null || path.isEmpty) {
              appLogger.w('[OPEN_FILE_BUTTON] No file selected');
              return;
            }

            // Check file size limit for Gotenberg conversion formats
            final fileType = _getFileType(path);
            final gotenbergFormats = ['HWP', 'HWPX', 'DOC', 'XLS', 'PPT', 'PPTX'];
            const maxSize = 25 * 1024 * 1024; // 25MB

            if (gotenbergFormats.contains(fileType) && fileSize > maxSize) {
              final sizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(1);
              appLogger.w('[OPEN_FILE_BUTTON] File too large: $sizeMB MB');
              if (!context.mounted) return;
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('파일 크기 제한'),
                  content: Text(
                    '변환 가능한 파일 크기는 25MB까지입니다.\n선택한 파일: $sizeMB MB',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('확인'),
                    ),
                  ],
                ),
              );
              return;
            }

            await RecentDocumentsStore.instance.addDocument(path);
            appLogger.i('[OPEN_FILE_BUTTON] Added to recent documents');

            // Open viewer after adding to recent documents
            final doc = RecentDocument(
              path: path,
              name: path.split('/').last,
              type: fileType,
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
                        'PDF · HWP · Office · CSV · TXT',
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
