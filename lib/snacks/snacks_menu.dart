class SnacksItem {
  final String description;
  final String image;
  final String name;
  final double price;

  SnacksItem({
    required this.description,
    required this.image,
    required this.name,
    required this.price,
  });

  factory SnacksItem.fromFirestore(Map<String, dynamic> data) {
    return SnacksItem(
      description: data['description'] ?? '',
      image: data['image'] ?? '',
      name: data['name'] ?? '',
      price: data['price']?.toDouble() ?? 0.0, // Pastikan harga dalam bentuk double
    );
  }
}
