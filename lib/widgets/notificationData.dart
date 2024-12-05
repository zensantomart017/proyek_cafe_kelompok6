import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationData {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  NotificationData() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  }

  // Fungsi untuk menyimpan pesanan ke Firestore tanpa menggunakan subkoleksi
  static Future<void> saveOrder({
    required String img,
    required String name,
    required double price,
    required int quantity,
    required double totalPrice,
    required String selectedMethod,
  }) async {
    try {
      // Ambil UID pengguna dari Firebase Authentication
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // Simpan data pesanan ke dalam dokumen pengguna
      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('users').doc(uid);

      DocumentSnapshot userSnapshot = await userDoc.get();
      List<dynamic> currentOrders = userSnapshot.get('orders') ?? [];

      currentOrders.add({
        'img': img,
        'name': name,
        'price': price,
        'quantity': quantity,
        'totalPrice': totalPrice,
        'orderDate': Timestamp.now(),
        'paymentMethod': selectedMethod,
        'status': 'processing', // Status default "processing"
      });

      // Update data pesanan di Firestore
      await userDoc.update({'orders': currentOrders});
      print("Pesanan berhasil disimpan ke Firestore.");
    } catch (e) {
      print("Terjadi kesalahan saat menyimpan pesanan: $e");
    }
  }

  // Fungsi untuk menampilkan notifikasi
  Future<void> showNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'order_channel_id',
      'Order Notifications',
      channelDescription: 'Pesanan sedang diproses',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      0, // ID notifikasi
      'Pesanan Diproses',
      'Pesanan Anda sedang diproses.',
      notificationDetails,
      payload: 'Pesanan Diproses', // Optional payload
    );
  }

  // Ambil semua pesanan dari Firestore
  static Future<List<dynamic>> getOrders() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return userDoc.get('orders') ?? [];
    } catch (e) {
      print("Terjadi kesalahan saat mengambil data pesanan: $e");
      return [];
    }
  }

  // Hapus pesanan spesifik dari Firestore berdasarkan nama
  static Future<void> removeOrder(String orderName) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('users').doc(uid);

      DocumentSnapshot userSnapshot = await userDoc.get();
      List<dynamic> currentOrders = userSnapshot.get('orders') ?? [];

      // Filter pesanan yang bukan yang ingin dihapus
      currentOrders.removeWhere((order) => order['name'] == orderName);

      // Update data pesanan di Firestore
      await userDoc.update({'orders': currentOrders});
      print("Pesanan berhasil dihapus.");
    } catch (e) {
      print("Terjadi kesalahan saat menghapus pesanan: $e");
    }
  }

  // Hapus semua pesanan dari Firestore
  static Future<void> clearOrders() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'orders': []});
      print("Semua pesanan berhasil dihapus.");
    } catch (e) {
      print("Terjadi kesalahan saat menghapus semua pesanan: $e");
    }
  }
}
