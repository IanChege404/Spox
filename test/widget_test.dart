import 'package:flutter_test/flutter_test.dart';
import 'package:spotify_clone/main.dart';
import 'helpers/test_helpers.dart';

void main() {
  setUp(() {
    setupMockGetIt();
  });

  tearDown(() {
    tearDownMockGetIt();
  });

  testWidgets('App builds without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app builds without throwing errors
    expect(find.byType(MyApp), findsOneWidget);
  });
}
