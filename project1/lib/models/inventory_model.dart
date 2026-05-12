class Inventory {
  final int? id;
  final int shopId;
  final int productId;
  final String status; // 'Available', 'Limited', 'Out of Stock'
  final DateTime lastUpdated;

  Inventory({
    this.id,
    required this.shopId,
    required this.productId,
    required this.status,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shop_id': shopId,
      'product_id': productId,
      'status': status,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  factory Inventory.fromMap(Map<String, dynamic> map) {
    return Inventory(
      id: map['id'],
      shopId: map['shop_id'],
      productId: map['product_id'],
      status: map['status'],
      lastUpdated: DateTime.parse(map['last_updated']),
    );
  }
}
