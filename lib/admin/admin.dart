import 'package:flutter/material.dart';
import 'package:flutter_application_6/admin/food.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Asumsi FoodScreen ada di sini

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tombol Pesanan
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PesananScreen(),
                  ),
                );
              },
               child: const Text('Pesanan'),
            ),
            const SizedBox(height: 20),
            // Tombol Produk
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProdukScreen(),
                  ),
                );
              },
              child: const Text('Produk'),
            ),
          ],
        ),
      ),
    );
  }
}
class PesananScreen extends StatelessWidget {
  const PesananScreen({super.key});

  // Fungsi untuk menghapus pesanan dari Firestore tanpa menggunakan UID
  Future<void> selesaiPesanan(String orderId) async {
    try {
      // Hapus pesanan berdasarkan ID pesanan dari koleksi 'pesanan' global
      await FirebaseFirestore.instance.collection('pesanan').doc(orderId).delete();
      debugPrint('Pesanan dengan ID $orderId berhasil dihapus dari koleksi pesanan.');
    } catch (e) {
      debugPrint('Gagal menghapus pesanan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Mengambil data pesanan dari koleksi 'pesanan'
        stream: FirebaseFirestore.instance.collection('pesanan').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan saat mengambil data.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Tidak ada pesanan.'));
          }

          // Debugging: Print the number of orders fetched
          debugPrint('Jumlah pesanan: ${snapshot.data!.docs.length}');

          // Ambil data pesanan dari Firestore
          var orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index];
              var orderId = order.id;
              var userName = order['userName'] ?? 'Unknown User';
              var name = order['name'];
              var price = order['price'];
              var quantity = order['quantity'];
              var totalPrice = order['totalPrice'];
              var img = order['img'];

              // Debugging: Print the fetched order details
              debugPrint('Order $orderId: $name, $userName, $price, $quantity');

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        img,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.error, size: 50, color: Colors.red);
                        },
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nama Produk       : $name',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('Nama Pelanggan : $userName'),
                            Text('Harga                    : \Rp.${price.toStringAsFixed(0)}'),
                            Text('Jumlah                 : $quantity'),
                            Text('Total                     : \Rp.${totalPrice.toStringAsFixed(0)}'),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () async {
                          // Hapus pesanan saat tombol ditekan
                          await selesaiPesanan(orderId); // Menggunakan hanya orderId
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


class ProdukScreen extends StatefulWidget {
  const ProdukScreen({super.key});

  @override
  State<ProdukScreen> createState() => _ProdukScreenState();
}

class _ProdukScreenState extends State<ProdukScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // 4 tab sesuai kebutuhan
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: const [
          FoodScreen(), // Widget untuk kategori Food
        ],
      ),
    );
  }
}