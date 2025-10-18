import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_lab/widgets/shopping_cart.dart';

void main() {
  group('Shopping Cart Widget Tests', () {
    testWidgets('Cart displays empty state initially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ShoppingCart())),
      );

      expect(find.text('Cart is empty'), findsOneWidget);
      expect(find.text('Total Items: 0'), findsOneWidget);
      expect(find.text('Subtotal: \$0.00'), findsOneWidget);
      expect(find.text('Total Amount: \$0.00'), findsOneWidget);
    });

    testWidgets('Adding item shows it in the cart', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ShoppingCart())),
      );

      await tester.tap(find.text('Add iPhone'));
      await tester.pump();

      expect(find.text('Cart is empty'), findsNothing);
      expect(find.text('Apple iPhone'), findsOneWidget);
      expect(find.text('Total Items: 1'), findsOneWidget);
    });

    testWidgets('Adding duplicate item increases quantity', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ShoppingCart())),
      );

      await tester.tap(find.text('Add iPhone'));
      await tester.pump();
      await tester.tap(find.text('Add iPhone Again'));
      await tester.pump();

      expect(find.text('Apple iPhone'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Total Items: 2'), findsOneWidget);
    });

    testWidgets('Adding different items creates separate entries', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ShoppingCart())),
      );

      await tester.tap(find.text('Add iPhone'));
      await tester.pump();
      await tester.tap(find.text('Add Galaxy'));
      await tester.pump();
      await tester.tap(find.text('Add iPad'));
      await tester.pump();

      expect(find.text('Apple iPhone'), findsOneWidget);
      expect(find.text('Samsung Galaxy'), findsOneWidget);
      expect(find.text('iPad Pro'), findsOneWidget);
      expect(find.text('Total Items: 3'), findsOneWidget);
    });

    testWidgets('Subtotal calculates correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ShoppingCart())),
      );

      await tester.tap(find.text('Add iPhone'));
      await tester.pump();

      expect(find.text('Subtotal: \$999.99'), findsOneWidget);
    });

    testWidgets('Discount displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ShoppingCart())),
      );

      await tester.tap(find.text('Add iPhone'));
      await tester.pump();

      expect(find.text('Discount: 10%'), findsOneWidget);
    });

    testWidgets('Total amount calculates with discount', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ShoppingCart())),
      );

      await tester.tap(find.text('Add iPhone'));
      await tester.pump();

      expect(find.text('Total Amount: \$899.99'), findsOneWidget);
    });

    testWidgets('Incrementing quantity updates totals', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ShoppingCart())),
      );

      await tester.tap(find.text('Add iPhone'));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.text('2'), findsOneWidget);
      expect(find.text('Total Items: 2'), findsOneWidget);
      expect(find.text('Subtotal: \$1999.98'), findsOneWidget);
    });

    testWidgets('Decrementing quantity updates totals', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ShoppingCart())),
      );

      await tester.tap(find.text('Add iPhone'));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('Total Items: 1'), findsOneWidget);
    });

    testWidgets('Decrementing quantity to zero removes item', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ShoppingCart())),
      );

      await tester.tap(find.text('Add iPhone'));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      expect(find.text('Apple iPhone'), findsNothing);
      expect(find.text('Cart is empty'), findsOneWidget);
    });

    testWidgets('Delete button removes item', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ShoppingCart())),
      );

      await tester.tap(find.text('Add iPhone'));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      expect(find.text('Apple iPhone'), findsNothing);
      expect(find.text('Cart is empty'), findsOneWidget);
    });

    testWidgets('Clear cart button removes all items', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ShoppingCart())),
      );

      await tester.tap(find.text('Add iPhone'));
      await tester.pump();
      await tester.tap(find.text('Add Galaxy'));
      await tester.pump();
      await tester.tap(find.text('Add iPad'));
      await tester.pump();

      expect(find.text('Total Items: 3'), findsOneWidget);

      await tester.tap(find.text('Clear Cart'));
      await tester.pump();

      expect(find.text('Cart is empty'), findsOneWidget);
      expect(find.text('Total Items: 0'), findsOneWidget);
    });

    testWidgets('Multiple quantities display correct totals', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ShoppingCart())),
      );

      await tester.tap(find.text('Add iPhone'));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.text('3'), findsOneWidget);
      expect(find.text('Total Items: 3'), findsOneWidget);
      expect(find.text('Subtotal: \$2999.97'), findsOneWidget);
    });

    testWidgets('Item with no discount shows correct price', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ShoppingCart())),
      );

      await tester.tap(find.text('Add iPad'));
      await tester.pump();

      // iPad has no discount, so discount percentage should not be shown on the item
      // But summary will show "Total Discount: -$0.00"
      expect(find.text('Discount: 0%'), findsNothing);
      expect(find.text('Subtotal: \$1099.99'), findsOneWidget);
      expect(find.text('Total Amount: \$1099.99'), findsOneWidget);
      expect(find.text('Total Discount: -\$0.00'), findsOneWidget);
    });

    testWidgets('Mixed items with and without discounts calculate correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ShoppingCart())),
      );

      await tester.tap(find.text('Add iPhone'));
      await tester.pump();
      await tester.tap(find.text('Add iPad'));
      await tester.pump();

      expect(find.text('Subtotal: \$2099.98'), findsOneWidget);
      expect(find.text('Total Amount: \$1999.98'), findsOneWidget);
    });

    testWidgets('Discount amount displays on items', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ShoppingCart())),
      );

      await tester.tap(find.text('Add Galaxy'));
      await tester.pump();

      expect(find.text('Discount: 15%'), findsOneWidget);
      expect(find.textContaining('Discount Amount: -\$135.00'), findsOneWidget);
    });

    testWidgets('Item total displays correctly with discount', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ShoppingCart())),
      );

      await tester.tap(find.text('Add Galaxy'));
      await tester.pump();

      expect(find.textContaining('Item Total: \$764.99'), findsOneWidget);
    });

    testWidgets('Total discount shows in summary', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ShoppingCart())),
      );

      await tester.tap(find.text('Add iPhone'));
      await tester.pump();
      await tester.tap(find.text('Add Galaxy'));
      await tester.pump();

      expect(find.textContaining('Total Discount: -\$'), findsOneWidget);
    });

    testWidgets('Adding items in different order produces same result', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ShoppingCart())),
      );

      await tester.tap(find.text('Add iPhone'));
      await tester.pump();
      await tester.tap(find.text('Add Galaxy'));
      await tester.pump();
      await tester.tap(find.text('Add iPhone Again'));
      await tester.pump();

      expect(find.text('Apple iPhone'), findsOneWidget);
      expect(find.text('Samsung Galaxy'), findsOneWidget);
      expect(find.text('Total Items: 3'), findsOneWidget);
    });

    testWidgets('Removing middle item from list works correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ShoppingCart())),
      );

      await tester.tap(find.text('Add iPhone'));
      await tester.pump();
      await tester.tap(find.text('Add Galaxy'));
      await tester.pump();
      await tester.tap(find.text('Add iPad'));
      await tester.pump();

      final deleteButtons = find.byIcon(Icons.delete);
      await tester.tap(deleteButtons.at(1));
      await tester.pump();

      expect(find.text('Apple iPhone'), findsOneWidget);
      expect(find.text('Samsung Galaxy'), findsNothing);
      expect(find.text('iPad Pro'), findsOneWidget);
      expect(find.text('Total Items: 2'), findsOneWidget);
    });

    testWidgets('Price formatting is correct', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ShoppingCart())),
      );

      await tester.tap(find.text('Add iPhone'));
      await tester.pump();

      expect(find.text('Price: \$999.99 each'), findsOneWidget);
      expect(find.text('Subtotal: \$999.99'), findsOneWidget);
    });

    testWidgets('Quantity controls work correctly for multiple items', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ShoppingCart())),
      );

      await tester.tap(find.text('Add iPhone'));
      await tester.pump();
      await tester.tap(find.text('Add Galaxy'));
      await tester.pump();

      final addButtons = find.byIcon(Icons.add);
      await tester.tap(addButtons.first);
      await tester.pump();

      await tester.tap(addButtons.last);
      await tester.pump();

      expect(find.text('Total Items: 4'), findsOneWidget);
    });

    testWidgets('Cart state persists across multiple operations', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ShoppingCart())),
      );

      await tester.tap(find.text('Add iPhone'));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      await tester.tap(find.text('Add Galaxy'));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.remove).first);
      await tester.pump();

      await tester.tap(find.text('Add iPad'));
      await tester.pump();

      expect(find.text('Total Items: 3'), findsOneWidget);
      expect(find.text('Apple iPhone'), findsOneWidget);
      expect(find.text('Samsung Galaxy'), findsOneWidget);
      expect(find.text('iPad Pro'), findsOneWidget);
    });
  });
}
