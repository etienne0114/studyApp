import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_scheduler/app.dart';

void main() {
  testWidgets('App should build without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StudySchedulerApp());

    // Verify that the app builds successfully
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Custom button should render correctly', (WidgetTester tester) async {
    // Create a test widget with a custom button
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Test Button'),
            ),
          ),
        ),
      ),
    );

    // Find the button
    final buttonFinder = find.byType(ElevatedButton);
    expect(buttonFinder, findsOneWidget);

    // Find the text
    expect(find.text('Test Button'), findsOneWidget);
  });

  testWidgets('TextField validation should work', (WidgetTester tester) async {
    String? errorText;
    
    // Create a widget with a form and text field
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            autovalidateMode: AutovalidateMode.always,
            child: TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Field cannot be empty';
                }
                return null;
              },
              onChanged: (value) {
                // This will be called when the text changes
              },
              decoration: InputDecoration(
                errorText: errorText,
                labelText: 'Test Field',
              ),
            ),
          ),
        ),
      ),
    );

    // Initially the form should not show an error
    expect(find.text('Field cannot be empty'), findsNothing);

    // Enter text and then delete it
    await tester.enterText(find.byType(TextFormField), 'hello');
    await tester.pump();
    expect(find.text('Field cannot be empty'), findsNothing);

    // Clear the text
    await tester.enterText(find.byType(TextFormField), '');
    await tester.pump();
    
    // Now validation should show an error
    expect(find.text('Field cannot be empty'), findsOneWidget);
  });
}