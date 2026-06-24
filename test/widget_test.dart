import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:form_descan/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp(isLoggedIn: false));

    // Verify that the login dashboard structure mounts.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
