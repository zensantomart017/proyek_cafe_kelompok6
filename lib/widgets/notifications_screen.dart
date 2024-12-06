import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_6/widgets/home_bottom_bar.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);
  final Color mainColor = const Color(0xFFE57734);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: const Text(
          'Daftar Pesanan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<User?>(  // Mengambil data pengguna yang sedang login
        future: Future.value(FirebaseAuth.instance.currentUser),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!authSnapshot.hasData) {
            return const Center(
              child: Text('Pengguna tidak ditemukan.'),
            );
          }

          final String uid = authSnapshot.data!.uid;

          return StreamBuilder<QuerySnapshot>( // Stream data pesanan berdasarkan user
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .collection('orders')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('Tidak ada pesanan yang sedang diproses.'),
                );
              }

              final orders = snapshot.data!.docs;

              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index].data() as Map<String, dynamic>;
                  final productName = order['name'] ?? 'Nama Produk Tidak Ditemukan';
                  final quantity = order['quantity'] ?? 0;
                  final totalPrice = order['totalPrice'] ?? 0;
                  final imageUrl = order['img'] ?? '';
                  final status = order['status'] ?? 'unknown';

                  String statusText = status == 'processing' ? 'Pesanan Diproses' : 'Pesanan Selesai';
                  Color statusColor = status == 'processing' ? Colors.orange : Colors.green;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                    child: ListTile(
                      leading: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.error, color: Colors.red);
                              },
                            )
                          : const Icon(Icons.shopping_cart, size: 50, color: Colors.grey),
                      title: Text(
                        productName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Jumlah: $quantity'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Rp.${totalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: HomeBottomBar(),
    );
  }
}
