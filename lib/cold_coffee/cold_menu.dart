class ColdItem {
  final String description;
  final String image;
  final String name;
  final double price;

  ColdItem({
    required this.description,
    required this.image,
    required this.name,
    required this.price,
  });

  factory ColdItem.fromFirestore(Map<String, dynamic> data) {
    return ColdItem(
      description: data['description'] ?? '',
      image: data['image'] ?? '',
      name: data['name'] ?? '',
      price: data['price']?.toDouble() ?? 0.0, // Pastikan harga dalam bentuk double
    );
  }
}
