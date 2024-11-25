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
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentReference userCart =
          FirebaseFirestore.instance.collection('users').doc(uid);

      DocumentSnapshot userDoc = await userCart.get();
      List<dynamic> currentCart = userDoc.get('cart') ?? [];

      bool itemExists = false;
      for (var item in currentCart) {
        if (item['name'] == name) {
          item['quantity'] += quantity;
          item['totalPrice'] = item['price'] * item['quantity'];
          itemExists = true;
          break;
        }
      }

      if (!itemExists) {
        currentCart.add({
          'img': img,
          'name': name,
          'price': price,
          'quantity': quantity,
          'totalPrice': price * quantity,
        });
      }

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

  // Hapus item spesifik dari Firestore berdasarkan nama
  static Future<void> removeItem(String itemName) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentReference userCart =
          FirebaseFirestore.instance.collection('users').doc(uid);

      DocumentSnapshot userDoc = await userCart.get();
      List<dynamic> currentCart = userDoc.get('cart') ?? [];

      // Filter item yang bukan item yang ingin dihapus
      currentCart.removeWhere((item) => item['name'] == itemName);

      // Perbarui kembali data di Firestore
      await userCart.update({'cart': currentCart});
      print("Item berhasil dihapus dari keranjang.");
    } catch (e) {
      print("Terjadi kesalahan saat menghapus item: $e");
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
