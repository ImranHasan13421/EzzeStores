class CartItem {
  final String barcode;
  final String name;
  final double price;
  int quantity;
  final int maxStock; // So we don't sell more than we have!

  CartItem({
    required this.barcode,
    required this.name,
    required this.price,
    this.quantity = 1,
    required this.maxStock,
  });

  // Calculate total price for this specific row in the cart
  double get totalPrice => price * quantity;
}