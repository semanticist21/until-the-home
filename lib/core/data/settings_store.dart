import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_logger.dart';

/// App settings store with SharedPreferences persistence
class SettingsStore {
  SettingsStore._();

  static final SettingsStore instance = SettingsStore._();

  static const String _keyPreferNativeViewer = 'prefer_native_viewer';

  SharedPreferences? _prefs;

  /// Prefer native viewer for Office documents (iOS/Android system apps)
  final ValueNotifier<bool> preferNativeViewer = ValueNotifier<bool>(true);

  /// Initialize settings store
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
    appLogger.i('[SETTINGS_STORE] Initialized');
  }

  /// Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    final savedValue = _prefs?.getBool(_keyPreferNativeViewer);
    preferNativeViewer.value = savedValue ?? true; // Default: true
    appLogger.i(
      '[SETTINGS_STORE] Loaded - preferNativeViewer: ${preferNativeViewer.value} '
      '(saved: $savedValue, default: true)',
    );
  }

  /// Set native viewer preference
  Future<void> setPreferNativeViewer(bool value) async {
    preferNativeViewer.value = value;
    await _prefs?.setBool(_keyPreferNativeViewer, value);
    appLogger.i('[SETTINGS_STORE] Set preferNativeViewer: $value');
  }
}
