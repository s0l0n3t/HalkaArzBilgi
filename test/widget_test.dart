import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halkaarzbilgi/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app wrapped in ProviderScope and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: App(),
      ),
    );

    // Verify that the app builds without errors.
    expect(find.byType(App), findsOneWidget);
  });
}
