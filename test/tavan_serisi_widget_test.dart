import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:halkaarzbilgi/core/widgets/tavan_serisi_widget.dart';

void main() {
  testWidgets('TavanSerisiWidget renders only completed days (no empty days)',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TavanSerisiWidget(
            totalDays: 8,
            completedDays: 5,
          ),
        ),
      ),
    );

    // Initial frame
    await tester.pump();

    // Verify title and day label
    expect(find.text('Tavan serisi'), findsOneWidget);
    expect(find.text('5 Gün'), findsOneWidget);
    expect(find.text('Günler'), findsOneWidget);

    // Days 1 through 5 should exist
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);

    // Empty days (6, 7, 8) must NOT exist
    expect(find.text('6'), findsNothing);
    expect(find.text('7'), findsNothing);
    expect(find.text('8'), findsNothing);

    // Let sequential timer animations finish
    await tester.pumpAndSettle();
  });

  testWidgets('TavanSerisiWidget renders informative message when completedDays is 0',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TavanSerisiWidget(
            totalDays: 0,
            completedDays: 0,
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Tavan serisi'), findsOneWidget);
    expect(find.text('0 Gün'), findsOneWidget);
    expect(
        find.text('Tavan serisi bulunmuyor veya sona erdi'), findsOneWidget);
    expect(find.text('Günler'), findsNothing);
    expect(find.text('1'), findsNothing);
  });
}
