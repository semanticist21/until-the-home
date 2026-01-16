import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_section_title.dart';
import 'body_card.dart';
import 'open_file_button.dart';
import 'recent_documents.dart';

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const AppSectionTitle(title: '요약'),
          const SizedBox(height: 10),
          const BodyCard(),
          const SizedBox(height: 24),
          AppSectionTitle(
            title: '문서',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, size: 14, color: AppColors.neutral500),
                const SizedBox(width: 4),
                Text(
                  '일부 파일은 변환 시 서버로 전송됩니다',
                  style: TextStyle(fontSize: 11, color: AppColors.neutral500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const RecentDocuments(),
          const SizedBox(height: 12),
          const OpenFileButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
