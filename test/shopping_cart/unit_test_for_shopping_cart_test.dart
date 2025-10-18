import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_lab/widgets/shopping_cart.dart';

void main() {
  group('CartItem Tests', () {
    test('CartItem calculates discount amount correctly', () {
      final item = CartItem(
        id: '1',
        name: 'Test Item',
        price: 100.0,
        quantity: 2,
        discount: 0.1, // 10%
      );

      expect(item.discountAmount, 20.0); // 100 * 0.1 * 2 = 20
    });

    test('CartItem calculates discount amount with no discount', () {
      final item = CartItem(
        id: '1',
        name: 'Test Item',
        price: 100.0,
        quantity: 2,
        discount: 0.0,
      );

      expect(item.discountAmount, 0.0);
    });

    test('CartItem calculates total price after discount', () {
      final item = CartItem(
        id: '1',
        name: 'Test Item',
        price: 100.0,
        quantity: 2,
        discount: 0.1, // 10%
      );

      // (100 * 2) - (100 * 0.1 * 2) = 200 - 20 = 180
      expect(item.totalPrice, 180.0);
    });

    test('CartItem calculates total price with 100% discount', () {
      final item = CartItem(
        id: '1',
        name: 'Test Item',
        price: 100.0,
        quantity: 1,
        discount: 1.0, // 100%
      );

      expect(item.totalPrice, 0.0);
    });

    test('CartItem calculates total price with no discount', () {
      final item = CartItem(
        id: '1',
        name: 'Test Item',
        price: 50.0,
        quantity: 3,
        discount: 0.0,
      );

      expect(item.totalPrice, 150.0);
    });
  });

  group('Shopping Cart - Add Item Tests', () {
    late ShoppingCartState cart;

    setUp(() {
      cart = ShoppingCartState();
    });

    test('Adding new item creates entry in cart', () {
      cart.addItem('1', 'iPhone', 999.99);

      expect(cart.items.length, 1);
      expect(cart.items[0].id, '1');
      expect(cart.items[0].name, 'iPhone');
      expect(cart.items[0].price, 999.99);
      expect(cart.items[0].quantity, 1);
    });

    test(
      'Adding duplicate item updates quantity instead of creating new entry',
      () {
        cart.addItem('1', 'iPhone', 999.99);
        cart.addItem('1', 'iPhone', 999.99);

        expect(cart.items.length, 1);
        expect(cart.items[0].quantity, 2);
      },
    );

    test('Adding same item multiple times increments quantity correctly', () {
      cart.addItem('1', 'iPhone', 999.99);
      cart.addItem('1', 'iPhone', 999.99);
      cart.addItem('1', 'iPhone', 999.99);

      expect(cart.items.length, 1);
      expect(cart.items[0].quantity, 3);
    });

    test('Adding different items creates separate entries', () {
      cart.addItem('1', 'iPhone', 999.99);
      cart.addItem('2', 'Galaxy', 899.99);
      cart.addItem('3', 'iPad', 1099.99);

      expect(cart.items.length, 3);
      expect(cart.items[0].id, '1');
      expect(cart.items[1].id, '2');
      expect(cart.items[2].id, '3');
    });

    test('Adding item with discount stores discount correctly', () {
      cart.addItem('1', 'iPhone', 999.99, discount: 0.15);

      expect(cart.items[0].discount, 0.15);
    });
  });

  group('Shopping Cart - Remove Item Tests', () {
    late ShoppingCartState cart;

    setUp(() {
      cart = ShoppingCartState();
      cart.addItem('1', 'iPhone', 999.99);
      cart.addItem('2', 'Galaxy', 899.99);
      cart.addItem('3', 'iPad', 1099.99);
    });

    test('Removing item removes it from cart', () {
      cart.removeItem('2');

      expect(cart.items.length, 2);
      expect(cart.items.any((item) => item.id == '2'), false);
    });

    test('Removing non-existent item does nothing', () {
      cart.removeItem('999');

      expect(cart.items.length, 3);
    });

    test('Removing all items one by one empties cart', () {
      cart.removeItem('1');
      cart.removeItem('2');
      cart.removeItem('3');

      expect(cart.items.length, 0);
    });
  });

  group('Shopping Cart - Update Quantity Tests', () {
    late ShoppingCartState cart;

    setUp(() {
      cart = ShoppingCartState();
      cart.addItem('1', 'iPhone', 999.99);
    });

    test('Updating quantity changes item quantity', () {
      cart.updateQuantity('1', 5);

      expect(cart.items[0].quantity, 5);
    });

    test('Updating quantity to zero removes item', () {
      cart.updateQuantity('1', 0);

      expect(cart.items.length, 0);
    });

    test('Updating quantity to negative removes item', () {
      cart.updateQuantity('1', -1);

      expect(cart.items.length, 0);
    });

    test('Updating non-existent item does nothing', () {
      cart.updateQuantity('999', 5);

      expect(cart.items.length, 1);
      expect(cart.items[0].quantity, 1);
    });

    test('Incrementing quantity works correctly', () {
      cart.updateQuantity('1', 2);
      cart.updateQuantity('1', 3);

      expect(cart.items[0].quantity, 3);
    });
  });

  group('Shopping Cart - Clear Cart Tests', () {
    late ShoppingCartState cart;

    setUp(() {
      cart = ShoppingCartState();
      cart.addItem('1', 'iPhone', 999.99);
      cart.addItem('2', 'Galaxy', 899.99);
      cart.addItem('3', 'iPad', 1099.99);
    });

    test('Clear cart removes all items', () {
      cart.clearCart();

      expect(cart.items.length, 0);
      expect(cart.totalItems, 0);
    });

    test('Clear cart on empty cart does nothing', () {
      cart.clearCart();
      cart.clearCart();

      expect(cart.items.length, 0);
    });
  });

  group('Shopping Cart - Calculation Tests', () {
    late ShoppingCartState cart;

    setUp(() {
      cart = ShoppingCartState();
    });

    test('Subtotal calculates correctly with single item', () {
      cart.addItem('1', 'iPhone', 100.0);

      expect(cart.subtotal, 100.0);
    });

    test('Subtotal calculates correctly with multiple quantities', () {
      cart.addItem('1', 'iPhone', 100.0);
      cart.addItem('1', 'iPhone', 100.0);
      cart.addItem('1', 'iPhone', 100.0);

      expect(cart.subtotal, 300.0);
    });

    test('Subtotal calculates correctly with multiple items', () {
      cart.addItem('1', 'iPhone', 100.0);
      cart.addItem('2', 'Galaxy', 80.0);
      cart.addItem('3', 'iPad', 120.0);

      expect(cart.subtotal, 300.0);
    });

    test('Subtotal is zero for empty cart', () {
      expect(cart.subtotal, 0.0);
    });

    test('Total discount calculates correctly with single discounted item', () {
      cart.addItem('1', 'iPhone', 100.0, discount: 0.1);

      expect(cart.totalDiscount, 10.0);
    });

    test('Total discount calculates correctly with multiple quantities', () {
      cart.addItem('1', 'iPhone', 100.0, discount: 0.1);
      cart.updateQuantity('1', 3);

      // 100 * 0.1 * 3 = 30
      expect(cart.totalDiscount, 30.0);
    });

    test('Total discount calculates correctly with mixed items', () {
      cart.addItem('1', 'iPhone', 100.0, discount: 0.1); // 10 discount
      cart.addItem('2', 'Galaxy', 80.0, discount: 0.25); // 20 discount
      cart.addItem('3', 'iPad', 120.0, discount: 0.0); // 0 discount

      expect(cart.totalDiscount, 30.0);
    });

    test('Total discount is zero when no discounts applied', () {
      cart.addItem('1', 'iPhone', 100.0);
      cart.addItem('2', 'Galaxy', 80.0);

      expect(cart.totalDiscount, 0.0);
    });

    test('Total discount with 100% discount', () {
      cart.addItem('1', 'iPhone', 100.0, discount: 1.0);

      expect(cart.totalDiscount, 100.0);
    });

    test('Total amount calculates correctly without discount', () {
      cart.addItem('1', 'iPhone', 100.0);

      expect(cart.totalAmount, 100.0);
    });

    test('Total amount calculates correctly with discount', () {
      cart.addItem('1', 'iPhone', 100.0, discount: 0.1);

      // 100 - 10 = 90
      expect(cart.totalAmount, 90.0);
    });

    test(
      'Total amount calculates correctly with multiple items and discounts',
      () {
        cart.addItem('1', 'iPhone', 100.0, discount: 0.1); // 90 after discount
        cart.addItem('2', 'Galaxy', 80.0, discount: 0.25); // 60 after discount
        cart.addItem('3', 'iPad', 120.0); // 120 no discount

        // Total: 90 + 60 + 120 = 270
        expect(cart.totalAmount, 270.0);
      },
    );

    test('Total amount is zero for empty cart', () {
      expect(cart.totalAmount, 0.0);
    });

    test('Total amount with 100% discount is zero', () {
      cart.addItem('1', 'iPhone', 100.0, discount: 1.0);

      expect(cart.totalAmount, 0.0);
    });

    test('Total items counts correctly', () {
      cart.addItem('1', 'iPhone', 100.0);
      cart.addItem('2', 'Galaxy', 80.0);
      cart.addItem('1', 'iPhone', 100.0);

      expect(cart.totalItems, 3); // 2 iPhones + 1 Galaxy
    });

    test('Total items is zero for empty cart', () {
      expect(cart.totalItems, 0);
    });
  });

  group('Shopping Cart - Edge Cases', () {
    late ShoppingCartState cart;

    setUp(() {
      cart = ShoppingCartState();
    });

    test('Item with price 0', () {
      cart.addItem('1', 'Free Item', 0.0);

      expect(cart.subtotal, 0.0);
      expect(cart.totalAmount, 0.0);
    });

    test('Item with very large price', () {
      cart.addItem('1', 'Expensive', 999999.99);

      expect(cart.subtotal, 999999.99);
    });

    test('Item with very small discount', () {
      cart.addItem('1', 'iPhone', 100.0, discount: 0.001);

      expect(cart.totalDiscount, 0.1);
      expect(cart.totalAmount, 99.9);
    });

    test('Item with 100% discount and multiple quantities', () {
      cart.addItem('1', 'Free Item', 100.0, discount: 1.0);
      cart.updateQuantity('1', 10);

      expect(cart.subtotal, 1000.0);
      expect(cart.totalDiscount, 1000.0);
      expect(cart.totalAmount, 0.0);
    });

    test('Multiple items with same price but different discounts', () {
      cart.addItem('1', 'Item A', 100.0, discount: 0.1);
      cart.addItem('2', 'Item B', 100.0, discount: 0.2);
      cart.addItem('3', 'Item C', 100.0, discount: 0.5);

      expect(cart.subtotal, 300.0);
      expect(cart.totalDiscount, 80.0); // 10 + 20 + 50
      expect(cart.totalAmount, 220.0);
    });

    test('Adding and removing items maintains correct calculations', () {
      cart.addItem('1', 'iPhone', 100.0, discount: 0.1); // 10% off → 90
      cart.addItem('2', 'Galaxy', 80.0, discount: 0.2); // 20% off → 64
      cart.addItem('3', 'iPad', 120.0); // no discount → 120

      expect(cart.totalAmount, 274.0);

      cart.removeItem('2');

      expect(cart.totalAmount, 210.0); // 90 + 120
    });

    test('Updating quantity multiple times maintains correct calculations', () {
      cart.addItem('1', 'iPhone', 100.0, discount: 0.1);

      cart.updateQuantity('1', 2);
      expect(cart.totalAmount, 180.0);

      cart.updateQuantity('1', 5);
      expect(cart.totalAmount, 450.0);

      cart.updateQuantity('1', 1);
      expect(cart.totalAmount, 90.0);
    });

    test('Complex scenario with multiple operations', () {
      // Add items
      cart.addItem('1', 'iPhone', 100.0, discount: 0.1);
      cart.addItem('2', 'Galaxy', 80.0, discount: 0.2);
      cart.addItem('1', 'iPhone', 100.0, discount: 0.1);

      expect(cart.items.length, 2);
      expect(cart.totalItems, 3);
      expect(cart.subtotal, 280.0); // 200 + 80
      expect(cart.totalDiscount, 36.0); // 20 + 16
      expect(cart.totalAmount, 244.0);

      // Update quantity
      cart.updateQuantity('2', 2);
      expect(cart.totalAmount, 308.0);

      // Remove item
      cart.removeItem('1');
      expect(cart.totalAmount, 128.0); // Only Galaxy with qty 2
    });
  });
}
