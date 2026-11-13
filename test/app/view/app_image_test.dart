import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myalien/app/view/app_image.dart';

void main() {
  group('AppImage', () {
    testWidgets('renders placeholder when source is null or empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppImage(source: null),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders Image.memory when source is base64 data URI', (
      tester,
    ) async {
      // 1x1 transparent PNG in base64
      const transparentPngBase64 =
          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppImage(source: transparentPngBase64),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('renders custom errorWidget when base64 is malformed', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppImage(
              source: 'data:image/jpeg;base64,invalid_base64_data!!!',
              errorWidget: (context) => const Text('Custom Error Widget'),
            ),
          ),
        ),
      );

      expect(find.text('Custom Error Widget'), findsOneWidget);
    });
  });
}
