import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits_ai_agent/main.dart';

void main() {
  testWidgets('App renders splash screen', (tester) async {
    await tester.pumpWidget(const HabitsAIApp());

    // The splash screen shows the app title and a loading indicator
    expect(find.text('HABITS AI'), findsOneWidget);
    expect(find.text('Building better habits with AI'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
