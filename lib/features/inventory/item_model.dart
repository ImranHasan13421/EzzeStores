class ItemModel {
  final String? id; // Nullable because Supabase generates this
  final String barcode;
  final String name;
  final double sellingPrice;
  final int currentStock;
  final int minStockLevel;

  ItemModel({
    this.id,
    required this.barcode,
    required this.name,
    required this.sellingPrice,
    this.currentStock = 0,
    this.minStockLevel = 5,
  });

  // From Supabase to Flutter
  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'],
      barcode: json['barcode'],
      name: json['name'],
      sellingPrice: (json['selling_price'] as num).toDouble(),
      currentStock: json['current_stock'] ?? 0,
      minStockLevel: json['min_stock_level'] ?? 5,
    );
  }

  // From Flutter to Supabase
  Map<String, dynamic> toJson() {
    return {
      'barcode': barcode,
      'name': name,
      'selling_price': sellingPrice,
      'current_stock': currentStock,
      'min_stock_level': minStockLevel,
    };
  }
}