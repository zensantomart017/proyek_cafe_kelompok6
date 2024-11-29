import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteData {
  // Tambahkan item ke favorit
  static Future<void> addItem({
    required String img,
    required String name,
    required double price,
  }) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentReference userFavorites =
          FirebaseFirestore.instance.collection('users').doc(uid);

      DocumentSnapshot userDoc = await userFavorites.get();
      List<dynamic> currentFavorites = userDoc.get('favorites') ?? [];

      // Cek apakah item sudah ada dalam daftar favorit
      bool itemExists = false;
      for (var item in currentFavorites) {
        if (item['name'] == name) {
          itemExists = true;
          break;
        }
      }

      // Jika item belum ada, tambahkan ke favorit
      if (!itemExists) {
        currentFavorites.add({
          'img': img,
          'name': name,
          'price': price,
        });
        await userFavorites.update({'favorites': currentFavorites});
        print("Item berhasil ditambahkan ke favorit.");
      }
    } catch (e) {
      print("Terjadi kesalahan: $e");
    }
  }

  // Ambil semua item favorit dari Firestore
  static Future<List<dynamic>> getItems() async {
  try {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    // Cek apakah dokumen pengguna ada
    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      
      // Cek apakah field 'favorites' ada
      if (userData.containsKey('favorites')) {
        return userData['favorites']; // Ambil data 'favorites'
      } else {
        // Jika tidak ada field 'favorites', buat field tersebut sebagai array kosong
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'favorites': [],
        });
        return []; // Mengembalikan array kosong
      }
    } else {
      // Jika dokumen tidak ada, buat dokumen baru dengan field 'favorites'
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'favorites': [],
      });
      return []; // Mengembalikan array kosong
    }
  } catch (e) {
    print("Terjadi kesalahan saat mengambil data favorit: $e");
    return [];
  }
}

  // Hapus item favorit berdasarkan nama
  static Future<void> removeItem(String itemName) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentReference userFavorites =
          FirebaseFirestore.instance.collection('users').doc(uid);

      DocumentSnapshot userDoc = await userFavorites.get();
      List<dynamic> currentFavorites = userDoc.get('favorites') ?? [];

      // Filter item yang bukan item yang ingin dihapus
      currentFavorites.removeWhere((item) => item['name'] == itemName);

      // Perbarui data favorit di Firestore
      await userFavorites.update({'favorites': currentFavorites});
      print("Item berhasil dihapus dari favorit.");
    } catch (e) {
      print("Terjadi kesalahan saat menghapus item favorit: $e");
    }
  }

  // Hapus semua item dari daftar favorit
  static Future<void> clearFavorites() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'favorites': []});
      print("Favorit berhasil dikosongkan.");
    } catch (e) {
      print("Terjadi kesalahan saat menghapus data favorit: $e");
    }
  }
}
