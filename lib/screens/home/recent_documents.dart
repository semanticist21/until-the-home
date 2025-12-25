import 'package:flutter/material.dart';

import '../../core/widgets/app_section_title.dart';

class RecentDocuments extends StatelessWidget {
  const RecentDocuments({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(
              'assets/images/icons/document_history_empty.png',
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 8),
            const AppSectionTitle(title: '최근 문서'),
          ],
        ),
        const SizedBox(height: 12),
        const _DocumentItem(title: '2024년 연간보고서.pdf', date: '오늘', type: 'PDF'),
        const _DocumentItem(title: '회의록_12월.hwp', date: '어제', type: 'HWP'),
        const _DocumentItem(title: '프로젝트 제안서.docx', date: '3일 전', type: 'DOCX'),
      ],
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
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getTypeColor(type).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              type,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: _getTypeColor(type),
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
      default:
        return Colors.grey;
    }
  }
}
