import 'package:flutter/material.dart';

class AppProgress extends StatelessWidget {
  const AppProgress({
    super.key,
    required this.value,
    this.height = 8,
    this.borderRadius = 8,
    this.backgroundColor,
    this.color = const Color(0xFF4CAF50),
  });

  final double value;
  final double height;
  final double borderRadius;
  final Color? backgroundColor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: LinearProgressIndicator(
        value: value,
        minHeight: height,
        backgroundColor: backgroundColor ?? Colors.grey.shade200,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
