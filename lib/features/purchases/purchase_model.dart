class PurchaseModel {
  final String? id;
  final String itemBarcode;
  final int quantityBought;
  final double totalCost;
  final double amountPaid;

  // Calculate this locally before sending to Supabase
  double get amountDue => totalCost - amountPaid;

  PurchaseModel({
    this.id,
    required this.itemBarcode,
    required this.quantityBought,
    required this.totalCost,
    required this.amountPaid,
  });

  Map<String, dynamic> toJson() {
    return {
      'item_barcode': itemBarcode,
      'quantity_bought': quantityBought,
      'total_cost': totalCost,
      'amount_paid': amountPaid,
      'amount_due': amountDue,
    };
  }
}