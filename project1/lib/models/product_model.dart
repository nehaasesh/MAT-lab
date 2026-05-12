class Product {
  final int? id;
  final String name;
  final String category;
  final String description;

  Product({
    this.id,
    required this.name,
    required this.category,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      description: map['description'],
    );
  }
}
