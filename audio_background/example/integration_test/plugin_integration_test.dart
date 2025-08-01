import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:audio_background_example/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('verify UI elements', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify that the app bar title is correct.
      expect(find.text('Audio Background Example'), findsOneWidget);

      // Verify that the play, pause, and stop buttons are present.
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsOneWidget);
      expect(find.byIcon(Icons.stop), findsOneWidget);
    });
  });
}