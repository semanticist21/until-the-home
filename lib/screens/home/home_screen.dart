import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../core/widgets/app_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          AppHeader(
            onSettingsTap: () {
              // TODO: Navigate to settings
            },
          ),
          const Expanded(child: SizedBox.shrink()),
        ],
      ),
    );
  }
}
