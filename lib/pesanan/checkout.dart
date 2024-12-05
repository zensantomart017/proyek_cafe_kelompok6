import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class CheckoutScreen extends StatefulWidget {
  final String img;
  final String name;
  final double price;
  final int quantity;
  final double totalPrice;

  const CheckoutScreen({
    required this.img,
    required this.name,
    required this.price,
    required this.quantity,
    required this.totalPrice,
    Key? key,
  }) : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  String selectedMethod = "Dana"; // Default payment method

  @override
  void initState() {
    super.initState();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  }

  // Fungsi untuk menyimpan data ke Firestore dengan `uid`
  Future<void> saveOrder() async {
  try {
    // Ambil UID pengguna dari Firebase Authentication
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      throw "Pengguna tidak ditemukan.";
    }

    // Data pesanan yang akan disimpan
    Map<String, dynamic> orderData = {
      'userName': 'Nama Pengguna', 
      'name': widget.name, // Nama produk
      'img': widget.img, // Gambar produk
      'price': widget.price, // Harga produk
      'quantity': widget.quantity, // Jumlah
      'totalPrice': widget.totalPrice, // Total harga
      'orderDate': Timestamp.now(), // Tanggal pemesanan
      'paymentMethod': selectedMethod, // Metode pembayaran
      'status': 'processing', // Status default "processing"
    };

    // Simpan data pesanan ke dalam koleksi global 'pesanan'
    DocumentReference orderRef = await FirebaseFirestore.instance
        .collection('pesanan')
        .add(orderData);
    debugPrint('Pesanan berhasil disimpan ke koleksi pesanan.');

    // Menambahkan ID pesanan ke data yang disimpan dalam subkoleksi 'orders'
    orderData['orderId'] = orderRef.id; // Menambahkan ID pesanan ke data

    // Simpan data pesanan ke dalam subkoleksi 'orders' milik pengguna
    await FirebaseFirestore.instance
        .collection('users') // Koleksi utama
        .doc(uid) // Dokumen pengguna berdasarkan UID
        .collection('orders') // Subkoleksi pesanan
        .add(orderData);

    debugPrint('Pesanan berhasil disimpan ke subkoleksi orders pengguna.');
  } catch (e) {
    debugPrint('Gagal menyimpan pesanan: $e');
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

  @override
  Widget build(BuildContext context) {
    List<String> paymentMethods = ["Dana", "GoPay", "OVO", "Bank Transfer", "Cash"];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.network(
                  widget.img,
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error, size: 50, color: Colors.red);
                  },
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Price: \Rp.${widget.price.toStringAsFixed(0)}",
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Quantity: ${widget.quantity}",
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Total: \Rp.${widget.totalPrice.toStringAsFixed(0)}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              "Select Payment Method",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedMethod,
              onChanged: (String? value) {
                setState(() {
                  selectedMethod = value ?? selectedMethod;
                });
              },
              items: paymentMethods
                  .map((method) => DropdownMenuItem(
                        value: method,
                        child: Text(method),
                      ))
                  .toList(),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const Spacer(),
            ElevatedButton(
  onPressed: () async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await saveOrder(); // Simpan data pesanan ke Firestore
      await showNotification(); // Tampilkan notifikasi
      Navigator.pop(context); // Tutup loading dialog
      Navigator.pop(context); // Kembali ke halaman sebelumnya
    } catch (e) {
      Navigator.pop(context); // Tutup loading dialog
      debugPrint('Error: $e');
    }
  },
  child: const Text("Confirm Purchase"),
),
          ],
        ),
      ),
    );
  }
}
