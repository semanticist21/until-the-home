import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

enum AppButtonVariant { primary, secondary, outline, ghost, destructive }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: switch (variant) {
        AppButtonVariant.primary => FButton(
          style: FButtonStyle.primary(),
          onPress: isLoading ? null : onPressed,
          prefix: _buildPrefix(),
          child: Text(label),
        ),
        AppButtonVariant.secondary => FButton(
          style: FButtonStyle.secondary(),
          onPress: isLoading ? null : onPressed,
          prefix: _buildPrefix(),
          child: Text(label),
        ),
        AppButtonVariant.outline => FButton(
          style: FButtonStyle.outline(),
          onPress: isLoading ? null : onPressed,
          prefix: _buildPrefix(),
          child: Text(label),
        ),
        AppButtonVariant.ghost => FButton(
          style: FButtonStyle.ghost(),
          onPress: isLoading ? null : onPressed,
          prefix: _buildPrefix(),
          child: Text(label),
        ),
        AppButtonVariant.destructive => FButton(
          style: FButtonStyle.destructive(),
          onPress: isLoading ? null : onPressed,
          prefix: _buildPrefix(),
          child: Text(label),
        ),
      },
    );
  }

  Widget? _buildPrefix() {
    if (isLoading) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (icon != null) {
      return Icon(icon, size: 18);
    }

    return null;
  }
}
