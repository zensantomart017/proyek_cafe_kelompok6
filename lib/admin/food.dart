import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_6/admin/cold.dart';
import 'package:flutter_application_6/admin/hot_coffee.dart';
import 'package:flutter_application_6/admin/snakcs.dart';

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Color mainColor = Colors.lightBlue;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  // Fungsi Create
  Future<void> addProduct(String name, String description, String image, double price) async {
    try {
      await FirebaseFirestore.instance.collection('food').add({
        'name': name,
        'description': description,
        'image': image,
        'price': price,
      });
      debugPrint('Produk berhasil ditambahkan!');
    } catch (e) {
      debugPrint('Error saat menambahkan produk: $e');
    }
  }

  // Fungsi Update
  Future<void> updateProduct(String id, String name, String description, String image, double price) async {
    try {
      await FirebaseFirestore.instance.collection('food').doc(id).update({
        'name': name,
        'description': description,
        'image': image,
        'price': price,
      });
      debugPrint('Produk berhasil diperbarui!');
    } catch (e) {
      debugPrint('Error saat memperbarui produk: $e');
    }
  }

  // Fungsi Delete
  Future<void> deleteProduct(String id) async {
    try {
      await FirebaseFirestore.instance.collection('food').doc(id).delete();
      debugPrint('Produk berhasil dihapus!');
    } catch (e) {
      debugPrint('Error saat menghapus produk: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.lightBlue,
        appBar: AppBar(
          backgroundColor: mainColor,
          title: const Text(
          'Produk',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: "Food"),
              Tab(text: "Hot Coffee"),
              Tab(text: "Snacks"),
              Tab(text: "Cold Coffee"),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.add,
                color: Colors.white,
                ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AddProductDialog(onAdd: addProduct),
                );
              },
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            buildProductList(),
            HotScreen(),
            SnacksScreen(),
            ColdScreen(),
          ],
        ),
      ),
    );
  }

  Widget buildProductList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('food').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Terjadi kesalahan saat memuat data.'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Tidak ada produk tersedia.'));
        }

        final products = snapshot.data!.docs;

        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            final id = product.id;
            final name = product['name'] ?? 'Nama tidak tersedia';
            final description = product['description'] ?? 'Deskripsi tidak tersedia';
            final image = product['image'] ?? 'https://via.placeholder.com/150';
            final price = product['price'] ?? 0;

            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: Image.network(
                  image,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error), // Icon jika gambar gagal dimuat
                ),
                title: Text(name),
                subtitle: Text('$description\nHarga: Rp $price'),
                isThreeLine: true,
                trailing: PopupMenuButton(
                  onSelected: (value) {
                    if (value == 'update') {
                      showDialog(
                        context: context,
                        builder: (context) => UpdateProductDialog(
                          id: id,
                          currentName: name,
                          currentDescription: description,
                          currentImage: image,
                          currentPrice: price.toDouble(),
                          onUpdate: updateProduct,
                        ),
                      );
                    } else if (value == 'delete') {
                      deleteProduct(id);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'update', child: Text('Update')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Dialog untuk menambahkan produk baru
class AddProductDialog extends StatefulWidget {
  final Future<void> Function(String, String, String, double) onAdd;

  const AddProductDialog({super.key, required this.onAdd});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String description = '';
  String image = '';
  double price = 0.0;
  final Color mainColor = Colors.lightBlue;

  @override
Widget build(BuildContext context) {
  return AlertDialog(
    backgroundColor: mainColor,
    title: const Text(
      'Tambah Produk',
      style: TextStyle(color: Colors.white), // Warna teks putih
    ),
    content: Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Nama',
              labelStyle: TextStyle(color: Colors.white), // Warna label putih
            ),
            style: const TextStyle(color: Colors.white), // Warna input teks putih
            validator: (value) => value == null || value.isEmpty ? 'Nama tidak boleh kosong' : null,
            onSaved: (value) => name = value ?? '',
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Deskripsi',
              labelStyle: TextStyle(color: Colors.white),
            ),
            style: const TextStyle(color: Colors.white),
            validator: (value) => value == null || value.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
            onSaved: (value) => description = value ?? '',
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'URL Gambar',
              labelStyle: TextStyle(color: Colors.white),
            ),
            style: const TextStyle(color: Colors.white),
            validator: (value) => value == null || value.isEmpty ? 'URL gambar tidak boleh kosong' : null,
            onSaved: (value) => image = value ?? '',
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Harga',
              labelStyle: TextStyle(color: Colors.white),
            ),
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
            validator: (value) => value == null || value.isEmpty ? 'Harga tidak boleh kosong' : null,
            onSaved: (value) => price = double.tryParse(value ?? '0') ?? 0.0,
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text(
          'Batal',
          style: TextStyle(color: Colors.white), // Warna teks putih
        ),
      ),
      TextButton(
        onPressed: () {
          if (_formKey.currentState?.validate() ?? false) {
            _formKey.currentState?.save();
            widget.onAdd(name, description, image, price);
            Navigator.pop(context);
          }
        },
        child: const Text(
          'Tambah',
          style: TextStyle(color: Colors.white), // Warna teks putih
        ),
      ),
    ],
  );
}
}

// Dialog untuk memperbarui produk
class UpdateProductDialog extends StatefulWidget {
  final String id;
  final String currentName;
  final String currentDescription;
  final String currentImage;
  final double currentPrice;
  final Future<void> Function(String, String, String, String, double) onUpdate;

  const UpdateProductDialog({
    super.key,
    required this.id,
    required this.currentName,
    required this.currentDescription,
    required this.currentImage,
    required this.currentPrice,
    required this.onUpdate,
  });

  @override
  State<UpdateProductDialog> createState() => _UpdateProductDialogState();
}

class _UpdateProductDialogState extends State<UpdateProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String description;
  late String image;
  late double price;
  final Color mainColor = const Color(0xFF006994);

  @override
  void initState() {
    super.initState();
    name = widget.currentName;
    description = widget.currentDescription;
    image = widget.currentImage;
    price = widget.currentPrice;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: mainColor,
      title: const Text('Update Produk'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: name,
                decoration: const InputDecoration(labelText: 'Nama'),
                onSaved: (value) => name = value ?? '',
              ),
              TextFormField(
                initialValue: description,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                onSaved: (value) => description = value ?? '',
              ),
              TextFormField(
                initialValue: image,
                decoration: const InputDecoration(labelText: 'URL Gambar'),
                onSaved: (value) => image = value ?? '',
              ),
              TextFormField(
                initialValue: price.toString(),
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
                onSaved: (value) => price = double.tryParse(value ?? '0') ?? 0.0,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                _formKey.currentState?.save();
                widget.onUpdate(widget.id, name, description, image, price);
                Navigator.pop(context);
              }
            },
            child: const Text('Perbarui'),
          ),
        ],
      );
    }
  }
