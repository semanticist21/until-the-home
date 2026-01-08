import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../core/data/recent_documents_store.dart';
import '../pdf_viewer/index.dart';

class RecentDocuments extends StatefulWidget {
  const RecentDocuments({super.key});

  @override
  State<RecentDocuments> createState() => _RecentDocumentsState();
}

class _RecentDocumentsState extends State<RecentDocuments> {
  @override
  void initState() {
    super.initState();
    // TODO: 개발 테스트용 - 배포 전 제거
    RecentDocumentsStore.instance.loadSampleData();
    // RecentDocumentsStore.instance.load();
    // RecentDocumentsStore.instance.pruneMissingFiles();
  }

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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/icons/document_history_empty.webp',
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '최근 문서',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<List<RecentDocument>>(
              valueListenable: RecentDocumentsStore.instance.documents,
              builder: (context, documents, _) {
                if (documents.isEmpty) {
                  return Container(
                    height: 120,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.insert_drive_file_outlined,
                          color: Colors.grey.shade300,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '최근에 연 문서가 없어요',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '파일 열기로 문서를 추가해보세요',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return SizedBox(
                  height: 134,
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      children: List.generate(documents.length * 2 - 1, (
                        index,
                      ) {
                        if (index.isOdd) {
                          return Divider(
                            height: 1,
                            color: Colors.grey.shade200,
                          );
                        }
                        final doc = documents[index ~/ 2];
                        return _DocumentItem(
                          title: doc.name,
                          date: _formatDate(doc.openedAt),
                          type: doc.type,
                          onTap: () => _onDocumentTap(context, doc),
                        );
                      }),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onDocumentTap(BuildContext context, RecentDocument doc) {
    if (doc.type == 'PDF') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PdfViewerScreen(assetPath: doc.path, title: doc.name),
        ),
      );
    }
  }
}

class _DocumentItem extends StatelessWidget {
  const _DocumentItem({
    required this.title,
    required this.date,
    required this.type,
    this.onTap,
  });

  final String title;
  final String date;
  final String type;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 44,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTypeColor(type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  type,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _getTypeColor(type),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              date,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'PDF':
        return const Color(0xFFE53935);
      case 'HWP':
      case 'HWPX':
        return const Color(0xFF1E88E5);
      case 'DOC':
      case 'DOCX':
        return const Color(0xFF2E7D32);
      case 'XLS':
      case 'XLSX':
        return const Color(0xFF1D6F42);
      case 'PPT':
      case 'PPTX':
        return const Color(0xFFD84315);
      case 'RTF':
        return const Color(0xFF5E35B1);
      case 'TXT':
        return const Color(0xFF546E7A);
      case 'CSV':
        return const Color(0xFF7B1FA2);
      default:
        return Colors.grey;
    }
  }
}

String _formatDate(DateTime openedAt) {
  return timeago.format(openedAt, locale: 'ko');
}
