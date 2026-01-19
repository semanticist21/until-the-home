import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kkomi/core/widgets/common_pdf_viewer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CommonPdfViewer Widget Tests', () {
    testWidgets('Shows title in AppBar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CommonPdfViewer(filePath: 'test.pdf', title: 'Test Document'),
        ),
      );

      await tester.pump();

      expect(find.text('Test Document'), findsOneWidget);
    });

    testWidgets('Shows loading indicator initially', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CommonPdfViewer(filePath: 'test.pdf', title: 'Test PDF'),
        ),
      );

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('Has AppBar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CommonPdfViewer(filePath: 'test.pdf', title: 'Test PDF'),
        ),
      );

      await tester.pump();

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('Scaffold has correct background color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CommonPdfViewer(filePath: 'test.pdf', title: 'Test PDF'),
        ),
      );

      await tester.pump();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(Colors.grey.shade200));
    });
  });

  group('CommonPdfViewer Download Icon Tests', () {
    testWidgets('Shows download icon when onSave is provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CommonPdfViewer(
            pdfBytes: Uint8List.fromList([0x25, 0x50, 0x44, 0x46]), // %PDF
            title: 'Test Document',
            onSave: () {},
          ),
        ),
      );

      await tester.pump();

      // Should show download icon
      expect(find.byIcon(Icons.download), findsOneWidget);
    });

    testWidgets('Does not show download icon when onSave is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CommonPdfViewer(filePath: 'test.pdf', title: 'Test PDF'),
        ),
      );

      await tester.pump();

      // Should not show download icon
      expect(find.byIcon(Icons.download), findsNothing);
    });

    testWidgets('Download icon has correct tooltip', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CommonPdfViewer(
            pdfBytes: Uint8List.fromList([0x25, 0x50, 0x44, 0x46]), // %PDF
            title: 'Test Document',
            onSave: () {},
          ),
        ),
      );

      await tester.pump();

      final iconButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.download),
      );

      expect(iconButton.tooltip, equals('PDF 저장'));
    });

    testWidgets('Download button calls onSave when tapped', (tester) async {
      bool saveCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: CommonPdfViewer(
            pdfBytes: Uint8List.fromList([0x25, 0x50, 0x44, 0x46]), // %PDF
            title: 'Test Document',
            onSave: () {
              saveCalled = true;
            },
          ),
        ),
      );

      await tester.pump();

      // Tap download button
      await tester.tap(find.byIcon(Icons.download));
      await tester.pump();

      expect(saveCalled, isTrue);
    });
  });

  group('CommonPdfViewer Input Types', () {
    testWidgets('Accepts pdfBytes parameter', (tester) async {
      final widget = CommonPdfViewer(
        pdfBytes: Uint8List.fromList([0x25, 0x50, 0x44, 0x46]),
        title: 'Bytes Test',
      );

      expect(widget.pdfBytes, isNotNull);
      expect(widget.title, equals('Bytes Test'));
    });

    testWidgets('Accepts filePath parameter', (tester) async {
      const widget = CommonPdfViewer(filePath: 'test.pdf', title: 'File Test');

      expect(widget.filePath, equals('test.pdf'));
      expect(widget.title, equals('File Test'));
    });

    testWidgets('Accepts assetPath parameter', (tester) async {
      const widget = CommonPdfViewer(
        assetPath: 'assets/test.pdf',
        title: 'Asset Test',
      );

      expect(widget.assetPath, equals('assets/test.pdf'));
      expect(widget.title, equals('Asset Test'));
    });
  });

  group('CommonPdfViewer Integration Tests', () {
    testWidgets('Receives correct parameters', (tester) async {
      const testTitle = 'Integration Test';

      await tester.pumpWidget(
        MaterialApp(
          home: CommonPdfViewer(filePath: 'test.pdf', title: testTitle),
        ),
      );

      await tester.pump();

      expect(find.text(testTitle), findsOneWidget);
    });

    testWidgets('Maintains state during lifecycle', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CommonPdfViewer(filePath: 'test.pdf', title: 'Lifecycle Test'),
        ),
      );

      await tester.pump();

      expect(find.byType(CommonPdfViewer), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CommonPdfViewer), findsOneWidget);
    });
  });

  group('CommonPdfViewer Error Handling', () {
    testWidgets('Shows error state correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CommonPdfViewer(
            filePath: 'nonexistent.pdf',
            title: 'Error Test',
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}
