import 'package:flutter/material.dart';

class RecentDocuments extends StatelessWidget {
  const RecentDocuments({super.key});

  static const _mockDocuments = [
    ('2024년 연간보고서', '오늘', 'PDF'),
    ('회의록_12월', '어제', 'HWP'),
    ('프로젝트 제안서', '3일 전', 'DOCX'),
    ('매출현황_Q4', '5일 전', 'XLSX'),
    ('고객데이터_export', '1주 전', 'CSV'),
    ('인사발령_2024', '1주 전', 'PDF'),
    ('팀미팅_노트', '2주 전', 'HWP'),
    ('예산계획_2025', '2주 전', 'XLSX'),
    ('계약서_최종', '3주 전', 'DOCX'),
    ('주소록_백업', '1달 전', 'CSV'),
  ];

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
            SizedBox(
              height: 220,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: List.generate(_mockDocuments.length * 2 - 1, (index) {
                    if (index.isOdd) {
                      return Divider(height: 1, color: Colors.grey.shade200);
                    }
                    final doc = _mockDocuments[index ~/ 2];
                    return _DocumentItem(
                      title: doc.$1,
                      date: doc.$2,
                      type: doc.$3,
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentItem extends StatelessWidget {
  const _DocumentItem({
    required this.title,
    required this.date,
    required this.type,
  });

  final String title;
  final String date;
  final String type;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'PDF':
        return const Color(0xFFE53935);
      case 'HWP':
        return const Color(0xFF1E88E5);
      case 'DOCX':
        return const Color(0xFF2E7D32);
      case 'XLSX':
        return const Color(0xFF1D6F42);
      case 'CSV':
        return const Color(0xFF7B1FA2);
      default:
        return Colors.grey;
    }
  }
}
