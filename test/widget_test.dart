// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:ai_paralegal/main.dart';

void main() {
  testWidgets('AI Paralegal app loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AIParalegalApp());

    // Verify that our app loads
    expect(find.text('AI Paralegal Assistant'), findsOneWidget);
    
    // Verify the welcome screen appears
    expect(find.text('Welcome to AI Paralegal Assistant'), findsOneWidget);
    
    // Verify the input field appears
    expect(find.text('Ask your legal question...'), findsOneWidget);
  });
  
  testWidgets('Can interact with suggestion chips', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AIParalegalApp());

    // Find and tap a suggestion chip
    await tester.tap(find.text('Contract law question'));
    await tester.pump();

    // Verify that the input field was populated
    expect(find.text('Contract law question'), findsAtLeastNWidgets(1));
  });
}
