import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'body.dart';
import 'header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary50,
      body: SafeArea(
        child: Column(
          children: [
            Header(onSettingsTap: () {}),
            const Expanded(child: Body()),
          ],
        ),
      ),
    );
  }
}
