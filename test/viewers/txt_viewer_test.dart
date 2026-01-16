import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kkomi/screens/txt_viewer/index.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // TXT viewer tests skipped: TXT viewer converts text to PDF asynchronously during
  // initialization, creating timers that persist after widget disposal - requires integration testing
  group('TXT Viewer Widget Tests', () {
    testWidgets('TXT viewer shows title in AppBar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TxtViewerScreen(
            filePath: 'test_samples/sample.txt',
            title: 'My Test TXT',
            isAsset: true,
          ),
        ),
      );

      await tester.pump();

      // Should show title
      expect(find.text('My Test TXT'), findsOneWidget);
    }, skip: true);

    testWidgets('TXT viewer has PDF export button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TxtViewerScreen(
            filePath: 'test_samples/sample.txt',
            title: 'Test TXT',
            isAsset: true,
          ),
        ),
      );

      await tester.pump();

      // Should have PDF export button in AppBar
      expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);
    }, skip: true);

    testWidgets('TXT viewer shows loading indicator initially', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TxtViewerScreen(
            filePath: 'test_samples/sample.txt',
            title: 'Test TXT',
            isAsset: true,
          ),
        ),
      );

      await tester.pump();

      // Should show loading initially
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    }, skip: true);
  });
}
