class MenuItem {
  final String description;
  final String image;
  final String name;
  final double price;

  MenuItem({
    required this.description,
    required this.image,
    required this.name,
    required this.price,
  });

  factory MenuItem.fromFirestore(Map<String, dynamic> data) {
    return MenuItem(
      description: data['description'] ?? '',
      image: data['image'] ?? '',
      name: data['name'] ?? '',
      price: data['price']?.toDouble() ?? 0.0, // Pastikan harga dalam bentuk double
    );
  }
}
