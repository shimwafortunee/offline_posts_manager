// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_posts_manager/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.text('Offline Posts Manager'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}