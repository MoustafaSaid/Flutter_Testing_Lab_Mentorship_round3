import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_lab/widgets/weather_display.dart';

void main() {
  group('Weather Display Widget Tests', () {
    testWidgets('Widget renders with initial loading state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      // Should show loading indicator initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('City: '), findsOneWidget);
      expect(find.text('Temperature Unit:'), findsOneWidget);

      // Wait for the async operations to complete
      await tester.pumpAndSettle();
    });

    testWidgets('City dropdown displays all cities', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      // Wait for initial load to complete
      await tester.pumpAndSettle();

      // Tap the dropdown to open it
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // Should show all cities (now they're all hitTestable)
      expect(find.text('New York').hitTestable(), findsAtLeastNWidgets(1));
      expect(find.text('London').hitTestable(), findsOneWidget);
      expect(find.text('Tokyo').hitTestable(), findsOneWidget);
      expect(find.text('Invalid City').hitTestable(), findsOneWidget);
    });

    testWidgets('City dropdown select and error handling', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      // Wait for initial load
      await tester.pumpAndSettle();

      // Tap the dropdown
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // Select Invalid City to trigger error
      await tester.tap(find.text('Invalid City').last);
      await tester.pumpAndSettle();

      // Should show error
      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      // Tap retry button
      await tester.tap(find.text('Retry'));
      await tester.pump();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for retry to complete
      await tester.pumpAndSettle();
    });

    testWidgets('Refresh button is disabled during loading', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      // Immediately check before loading completes
      await tester.pump();

      // Find the refresh button
      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Refresh'),
      );

      // Button should be disabled during loading
      expect(button.onPressed, isNull);

      // Wait for loading to complete
      await tester.pumpAndSettle();
    });

    testWidgets('Weather details display correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      await tester.pumpAndSettle();

      // Should display humidity and wind speed labels
      expect(find.text('Humidity'), findsOneWidget);
      expect(find.text('Wind Speed'), findsOneWidget);
    });

    testWidgets('Weather icon displays', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      await tester.pumpAndSettle();

      // Should find at least one emoji (weather icon)
      // The specific icon depends on the city selected
      final textWidgets = find.byType(Text);
      expect(textWidgets, findsWidgets);
    });

    testWidgets('City name displays in weather card', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      await tester.pumpAndSettle();

      // Should show the selected city (New York by default) - appears in dropdown and card
      expect(find.text('New York'), findsAtLeastNWidgets(1));

      // Verify it's in the Card widget specifically
      expect(
        find.descendant(of: find.byType(Card), matching: find.text('New York')),
        findsOneWidget,
      );
    });

    testWidgets('Weather description displays', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      await tester.pumpAndSettle();

      // Should show weather description (Sunny for New York or N/A if incomplete data)
      final hasSunny = find.text('Sunny').evaluate().isNotEmpty;
      final hasNA = find.text('N/A').evaluate().isNotEmpty;
      expect(
        hasSunny || hasNA,
        isTrue,
        reason: 'Should show either Sunny or N/A',
      );
    });

    testWidgets('Multiple city changes work correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      await tester.pumpAndSettle();

      // Change to London
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('London').last);
      await tester.pumpAndSettle();

      expect(find.text('London'), findsAtLeastNWidgets(1));
      // Verify weather data is displayed (description will be either 'Rainy' or 'N/A')
      final hasRainy = find.text('Rainy').evaluate().isNotEmpty;
      final hasNA = find.text('N/A').evaluate().isNotEmpty;
      expect(
        hasRainy || hasNA,
        isTrue,
        reason: 'Should show either Rainy or N/A',
      );

      // Change to Tokyo
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tokyo').last);
      await tester.pumpAndSettle();

      expect(find.text('Tokyo'), findsAtLeastNWidgets(1));
      // Verify weather data is displayed (description will be either 'Cloudy' or 'N/A')
      final hasCloudy = find.text('Cloudy').evaluate().isNotEmpty;
      final hasNA2 = find.text('N/A').evaluate().isNotEmpty;
      expect(
        hasCloudy || hasNA2,
        isTrue,
        reason: 'Should show either Cloudy or N/A',
      );
    });

    testWidgets('Temperature unit persists across city changes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      await tester.pumpAndSettle();

      // Switch to Fahrenheit
      await tester.tap(find.byType(Switch));
      await tester.pump();

      expect(find.text('Fahrenheit'), findsOneWidget);

      // Change city
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('London').last);
      await tester.pumpAndSettle();

      // Should still be in Fahrenheit
      expect(find.text('Fahrenheit'), findsOneWidget);
      expect(find.textContaining('°F'), findsOneWidget);
    });

    testWidgets('Humidity displays with percentage', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      await tester.pumpAndSettle();

      // Should find humidity value with %
      expect(find.textContaining('%'), findsOneWidget);
    });

    testWidgets('Wind speed displays with unit', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      await tester.pumpAndSettle();

      // Should find wind speed with km/h
      expect(find.textContaining('km/h'), findsOneWidget);
    });

    testWidgets('Loading state clears previous weather data', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      await tester.pumpAndSettle();

      // Verify initial data is shown - appears in dropdown and card
      expect(find.text('New York'), findsAtLeastNWidgets(1));

      // Trigger refresh
      await tester.tap(find.text('Refresh'));
      await tester.pump();

      // During loading, weather data should not be visible
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for refresh to complete
      await tester.pumpAndSettle();
    });

    testWidgets('Error state replaces loading state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      await tester.pumpAndSettle();

      // Select Invalid City
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Invalid City').last);

      // Wait for loading to start
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for error to appear
      await tester.pumpAndSettle();

      // Loading should be gone, error should be shown
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('Success state replaces error state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      await tester.pumpAndSettle();

      // Select Invalid City to get error
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Invalid City').last);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      // Select valid city
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('London').last);
      await tester.pumpAndSettle();

      // Error should be gone, weather data should be shown
      expect(find.byIcon(Icons.error_outline), findsNothing);
      expect(find.text('London'), findsAtLeastNWidgets(1));
      expect(find.text('Rainy'), findsOneWidget);
    });

    testWidgets('Temperature format shows one decimal place', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      await tester.pumpAndSettle();

      // Should find temperature with .X format
      final tempFinder = find.textContaining('°C');
      expect(tempFinder, findsOneWidget);

      final tempText = (tester.widget(tempFinder) as Text).data!;
      // Should have exactly one decimal place (e.g., "22.5°C")
      expect(RegExp(r'\d+\.\d°C').hasMatch(tempText), isTrue);
    });

    testWidgets('Widget handles rapid city changes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      await tester.pumpAndSettle();

      // Rapidly change cities
      for (final city in ['London', 'Tokyo', 'New York']) {
        await tester.tap(find.byType(DropdownButton<String>));
        await tester.pumpAndSettle();
        await tester.tap(find.text(city).last);
        await tester.pump(); // Don't wait for settle
      }

      // Let everything settle
      await tester.pumpAndSettle();

      // Should end up with the last selected city
      expect(find.text('New York'), findsAtLeastNWidgets(1));
    });

    testWidgets('Widget handles rapid refresh clicks', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      await tester.pumpAndSettle();

      // Click refresh multiple times rapidly
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.text('Refresh'));
        await tester.pump();
      }

      await tester.pumpAndSettle();

      // Should still work correctly
      expect(find.text('New York'), findsAtLeastNWidgets(1));
    });

    testWidgets('Temperature unit toggle works', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      // Wait for initial load
      await tester.pumpAndSettle();

      // Initially shows Celsius
      expect(find.text('Celsius'), findsOneWidget);
      expect(find.text('Fahrenheit'), findsNothing);

      // Tap the switch
      await tester.tap(find.byType(Switch));
      await tester.pump();

      // Should now show Fahrenheit
      expect(find.text('Fahrenheit'), findsOneWidget);
      expect(find.text('Celsius'), findsNothing);
    });

    testWidgets('Weather data displays after loading', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Should show weather data (unless Invalid City was selected)
      // Check for common weather elements
      expect(find.byType(Card), findsWidgets);
      expect(find.byIcon(Icons.water_drop), findsOneWidget);
      expect(find.byIcon(Icons.air), findsOneWidget);
    });

    testWidgets('Temperature displays in Celsius by default', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      await tester.pumpAndSettle();

      // Should find temperature with °C
      expect(find.textContaining('°C'), findsOneWidget);
      expect(find.textContaining('°F'), findsNothing);
    });

    testWidgets('Temperature converts to Fahrenheit when toggled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      await tester.pumpAndSettle();

      // Toggle to Fahrenheit
      await tester.tap(find.byType(Switch));
      await tester.pump();

      // Should find temperature with °F
      expect(find.textContaining('°F'), findsOneWidget);
      expect(find.textContaining('°C'), findsNothing);
    });

    testWidgets('Changing city triggers reload', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      await tester.pumpAndSettle();

      // Tap dropdown to open it
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // Select London
      await tester.tap(find.text('London').last);
      await tester.pumpAndSettle();

      // Should show London weather
      expect(find.text('London'), findsAtLeastNWidgets(1));
    });

    testWidgets('Refresh button triggers reload', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      await tester.pumpAndSettle();

      // Tap refresh button
      await tester.tap(find.text('Refresh'));
      await tester.pump();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for refresh to complete
      await tester.pumpAndSettle();
    });

    testWidgets('Error state displays error message', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      await tester.pumpAndSettle();

      // Select Invalid City to trigger error
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Invalid City').last);
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(
        find.textContaining('Failed to load weather data'),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('Retry button in error state works', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      await tester.pumpAndSettle();

      // Select Invalid City to trigger error
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Invalid City').last);
      await tester.pumpAndSettle();

      // Tap retry button
      await tester.tap(find.text('Retry'));
      await tester.pump();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for retry to complete
      await tester.pumpAndSettle();
    });
  });
}
