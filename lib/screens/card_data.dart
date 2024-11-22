import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartData {
  // Tambahkan item ke Firestore
  static Future<void> addItem({
    required String img,
    required String name,
    required double price,
    required int quantity,
  }) async {
    try {
      // Mendapatkan user ID
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // Referensi ke dokumen user
      DocumentReference userCart =
          FirebaseFirestore.instance.collection('users').doc(uid);

      // Ambil data cart yang sudah ada
      DocumentSnapshot userDoc = await userCart.get();
      List<dynamic> currentCart = userDoc.get('cart') ?? [];

      // Periksa apakah item sudah ada di cart
      bool itemExists = false;
      for (var item in currentCart) {
        if (item['name'] == name) {
          // Perbarui quantity dan total price jika item sudah ada
          item['quantity'] += quantity;
          item['totalPrice'] = item['price'] * item['quantity'];
          itemExists = true;
          break;
        }
      }

      // Jika item tidak ada, tambahkan item baru
      if (!itemExists) {
        currentCart.add({
          'img': img,
          'name': name,
          'price': price,
          'quantity': quantity,
          'totalPrice': price * quantity,
        });
      }

      // Simpan kembali data ke Firestore
      await userCart.update({'cart': currentCart});
      print("Item berhasil ditambahkan ke keranjang.");
    } catch (e) {
      print("Terjadi kesalahan: $e");
    }
  }

  // Ambil semua item dari Firestore
  static Future<List<dynamic>> getItems() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return userDoc.get('cart') ?? [];
    } catch (e) {
      print("Terjadi kesalahan saat mengambil data keranjang: $e");
      return [];
    }
  }

  // Hapus semua item dari cart
  static Future<void> clearCart() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'cart': []});
      print("Keranjang berhasil dikosongkan.");
    } catch (e) {
      print("Terjadi kesalahan saat menghapus data keranjang: $e");
    }
  }
}
