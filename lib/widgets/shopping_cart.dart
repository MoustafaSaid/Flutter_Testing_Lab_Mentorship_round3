import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  int quantity;
  final double discount; // Discount percentage (0.0 to 1.0)

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.discount = 0.0,
  });

  // Calculate the discount amount for this item
  double get discountAmount {
    return price * discount * quantity;
  }

  // Calculate the total price after discount for this item
  double get totalPrice {
    return (price * quantity) - discountAmount;
  }
}

class ShoppingCart extends StatefulWidget {
  const ShoppingCart({super.key});

  @override
  State<ShoppingCart> createState() => ShoppingCartState();
}

class ShoppingCartState extends State<ShoppingCart> {
  final List<CartItem> items = [];

  void addItem(String id, String name, double price, {double discount = 0.0}) {
    // Check if item already exists
    final existingIndex = items.indexWhere((item) => item.id == id);

    if (existingIndex != -1) {
      // Item exists, increment quantity
      items[existingIndex].quantity++;
    } else {
      // Item doesn't exist, add new item
      items.add(CartItem(id: id, name: name, price: price, discount: discount));
    }
    if (mounted) {
      setState(() {});
    }
  }

  void removeItem(String id) {
    items.removeWhere((item) => item.id == id);

    if (mounted) {
      setState(() {});
    }
  }

  void updateQuantity(String id, int newQuantity) {
    final index = items.indexWhere((item) => item.id == id);
    if (index != -1) {
      if (newQuantity <= 0) {
        items.removeAt(index);
      } else {
        items[index].quantity = newQuantity;
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  void clearCart() {
    items.clear();

    if (mounted) {
      setState(() {});
    }
  }

  // Subtotal before any discounts
  double get subtotal {
    double total = 0;
    for (var item in items) {
      total += item.price * item.quantity;
    }
    return total;
  }

  // Total discount amount
  double get totalDiscount {
    double discount = 0;
    for (var item in items) {
      discount += item.discountAmount;
    }
    return discount;
  }

  // Final amount after applying discounts
  double get totalAmount {
    return subtotal - totalDiscount;
  }

  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            children: [
              ElevatedButton(
                onPressed: () =>
                    addItem('1', 'Apple iPhone', 999.99, discount: 0.1),
                child: const Text('Add iPhone'),
              ),
              ElevatedButton(
                onPressed: () =>
                    addItem('2', 'Samsung Galaxy', 899.99, discount: 0.15),
                child: const Text('Add Galaxy'),
              ),
              ElevatedButton(
                onPressed: () => addItem('3', 'iPad Pro', 1099.99),
                child: const Text('Add iPad'),
              ),
              ElevatedButton(
                onPressed: () =>
                    addItem('1', 'Apple iPhone', 999.99, discount: 0.1),
                child: const Text('Add iPhone Again'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Items: $totalItems'),
                    ElevatedButton(
                      onPressed: clearCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Clear Cart'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Subtotal: \$${subtotal.toStringAsFixed(2)}'),
                Text(
                  'Total Discount: -\$${totalDiscount.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.green),
                ),
                const Divider(),
                Text(
                  'Total Amount: \$${totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          items.isEmpty
              ? const Center(child: Text('Cart is empty'))
              : ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];

                    return Card(
                      child: ListTile(
                        title: Text(item.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price: \$${item.price.toStringAsFixed(2)} each',
                            ),
                            if (item.discount > 0) ...[
                              Text(
                                'Discount: ${(item.discount * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(color: Colors.green),
                              ),
                              Text(
                                'Discount Amount: -\$${item.discountAmount.toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.green),
                              ),
                            ],
                            Text(
                              'Item Total: \$${item.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () =>
                                  updateQuantity(item.id, item.quantity - 1),
                              icon: const Icon(Icons.remove),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('${item.quantity}'),
                            ),
                            IconButton(
                              onPressed: () =>
                                  updateQuantity(item.id, item.quantity + 1),
                              icon: const Icon(Icons.add),
                            ),
                            IconButton(
                              onPressed: () => removeItem(item.id),
                              icon: const Icon(Icons.delete),
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
