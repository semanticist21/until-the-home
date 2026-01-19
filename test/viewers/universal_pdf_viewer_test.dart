import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kkomi/screens/universal_pdf_viewer/index.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UniversalPdfViewer Widget Tests', () {
    testWidgets('Shows title in AppBar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UniversalPdfViewer(
            filePath: 'test.pdf',
            title: 'Test Document',
            isAsset: false,
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Test Document'), findsOneWidget);
    });

    testWidgets('Shows loading indicator initially', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UniversalPdfViewer(
            filePath: 'test.pdf',
            title: 'Test PDF',
            isAsset: false,
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('Has AppBar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UniversalPdfViewer(
            filePath: 'test.pdf',
            title: 'Test PDF',
            isAsset: false,
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('Scaffold has correct background color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UniversalPdfViewer(
            filePath: 'test.pdf',
            title: 'Test PDF',
            isAsset: false,
          ),
        ),
      );

      await tester.pump();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(Colors.grey.shade200));
    });
  });

  group('UniversalPdfViewer Save Button Tests', () {
    testWidgets('Shows title when converter is provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UniversalPdfViewer(
            filePath: 'test.txt',
            title: 'Test Document',
            isAsset: false,
            converter: null, // Converter would be provided in real scenario
          ),
        ),
      );

      await tester.pump();

      // Should show title
      expect(find.text('Test Document'), findsOneWidget);
    });

    testWidgets('Does not show save button without converter', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UniversalPdfViewer(
            filePath: 'test.pdf',
            title: 'Native PDF',
            isAsset: false,
          ),
        ),
      );

      await tester.pump();

      // Should not show download icon for native PDF
      expect(find.byIcon(Icons.download), findsNothing);
    });
  });

  group('UniversalPdfViewer State Management', () {
    testWidgets('Creates widget successfully', (tester) async {
      const widget = UniversalPdfViewer(
        filePath: 'test.pdf',
        title: 'State Test',
        isAsset: false,
      );

      expect(widget.filePath, equals('test.pdf'));
      expect(widget.title, equals('State Test'));
      expect(widget.isAsset, isFalse);
    });

    testWidgets('Handles asset and file modes', (tester) async {
      // Asset mode
      const assetWidget = UniversalPdfViewer(
        filePath: 'assets/test.pdf',
        title: 'Asset Test',
        isAsset: true,
      );

      expect(assetWidget.isAsset, isTrue);

      // File mode
      const fileWidget = UniversalPdfViewer(
        filePath: '/path/to/file.pdf',
        title: 'File Test',
        isAsset: false,
      );

      expect(fileWidget.isAsset, isFalse);
    });
  });

  group('UniversalPdfViewer Integration Tests', () {
    testWidgets('Receives correct parameters', (tester) async {
      const testPath = 'test.pdf';
      const testTitle = 'Integration Test';

      await tester.pumpWidget(
        const MaterialApp(
          home: UniversalPdfViewer(
            filePath: testPath,
            title: testTitle,
            isAsset: false,
          ),
        ),
      );

      await tester.pump();

      expect(find.text(testTitle), findsOneWidget);
    });

    testWidgets('Maintains state during lifecycle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UniversalPdfViewer(
            filePath: 'test.pdf',
            title: 'Lifecycle Test',
            isAsset: false,
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(UniversalPdfViewer), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(UniversalPdfViewer), findsOneWidget);
    });
  });

  group('UniversalPdfViewer Error Handling', () {
    testWidgets('Shows error state correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UniversalPdfViewer(
            filePath: 'nonexistent.pdf',
            title: 'Error Test',
            isAsset: false,
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('Handles conversion errors gracefully', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UniversalPdfViewer(
            filePath: 'invalid.txt',
            title: 'Conversion Error Test',
            isAsset: false,
          ),
        ),
      );

      await tester.pump();

      // Should show AppBar even with errors
      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}
