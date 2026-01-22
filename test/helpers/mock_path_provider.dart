import 'dart:io';

import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

/// Mock implementation of PathProviderPlatform for testing
class MockPathProviderPlatform extends PathProviderPlatform {
  MockPathProviderPlatform(this.mockDirectory);

  final Directory mockDirectory;

  @override
  Future<String?> getApplicationSupportPath() async {
    return mockDirectory.path;
  }

  @override
  Future<String?> getTemporaryPath() async {
    return mockDirectory.path;
  }

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return mockDirectory.path;
  }

  @override
  Future<String?> getExternalStoragePath() async {
    return mockDirectory.path;
  }

  @override
  Future<List<String>?> getExternalCachePaths() async {
    return [mockDirectory.path];
  }

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async {
    return [mockDirectory.path];
  }

  @override
  Future<String?> getLibraryPath() async {
    return mockDirectory.path;
  }

  @override
  Future<String?> getDownloadsPath() async {
    return mockDirectory.path;
  }
}
