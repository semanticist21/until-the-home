import 'package:flutter/material.dart';

import '../../core/widgets/app_section_title.dart';
import 'body_card.dart';
import 'open_file_button.dart';
import 'recent_documents.dart';

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const AppSectionTitle(title: '요약'),
          const SizedBox(height: 10),
          const BodyCard(),
          const SizedBox(height: 24),
          const AppSectionTitle(title: '문서'),
          const SizedBox(height: 10),
          const RecentDocuments(),
          const SizedBox(height: 12),
          const OpenFileButton(),
          const Spacer(),
        ],
      ),
    );
  }
}
