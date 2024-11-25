import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_6/menu_item.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fungsi untuk mendapatkan data dari Firestore sebagai stream
  Stream<List<MenuItem>> getMenuItemsStream() {
    return _db.collection('menu')
      .snapshots() // Mendengarkan perubahan pada koleksi 'menu'
      .map((querySnapshot) {
        return querySnapshot.docs.map((doc) {
          return MenuItem.fromFirestore(doc.data()); // Mengonversi data menjadi objek MenuItem
        }).toList();
      });
  }
}
