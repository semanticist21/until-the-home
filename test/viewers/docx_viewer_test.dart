import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kkomi/screens/docx_viewer/index.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DOCX Viewer Widget Tests', () {
    // DOCX viewer tests skipped: docx_file_viewer library creates timers during
    // initialization that persist after widget disposal - requires integration testing
    testWidgets(
      'DOCX viewer can be instantiated',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: DocxViewerScreen(
              filePath: 'test_samples/sample.docx',
              title: 'Test DOCX',
              isAsset: true,
            ),
          ),
        );

        // Just verify the widget can be created
        expect(find.byType(DocxViewerScreen), findsOneWidget);
      },
      skip: true,
    );
  });
}
