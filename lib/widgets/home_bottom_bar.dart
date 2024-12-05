import 'package:flutter/material.dart';
import 'package:flutter_application_6/screens/cart.dart';
import 'package:flutter_application_6/screens/favorite_list.dart';
import 'package:flutter_application_6/screens/home_screen.dart';
import 'package:flutter_application_6/screens/info_akun.dart';
import 'package:flutter_application_6/widgets/notifications_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class HomeBottomBar extends StatefulWidget {
  const HomeBottomBar({Key? key}) : super(key: key);

  @override
  _HomeBottomBarState createState() => _HomeBottomBarState();
}

class _HomeBottomBarState extends State<HomeBottomBar> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Konfigurasi inisialisasi untuk notifikasi
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings, // Menambahkan handler untuk notifikasi yang ditekan
    );
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

  // Fungsi untuk menangani notifikasi yang ditekan
  Future<void> onSelectNotification(String? payload) async {
    if (payload != null) {
      print("Notifikasi ditekan dengan payload: $payload");
    }

    // Misalnya, membuka halaman tertentu setelah notifikasi ditekan
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Cart()), // Contoh: buka halaman Cart
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      height: 80,
      decoration: BoxDecoration(
        color: Color(0xFF212325),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            spreadRadius: 1,
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
            child: Icon(
              Icons.home,
              color: Color(0xFFE57734),
              size: 35,
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoriteList()),
              );
            },
            child: Icon(
              Icons.favorite_outline,
              color: Color(0xFFE57734),
              size: 35,
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            },
            child: Icon(
              Icons.notifications,
              color: Color(0xFFE57734),
              size: 35,
            ),
          ),

          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Cart()),
              );
            },
            child: Icon(
              Icons.shopping_cart,
              color: Color(0xFFE57734),
              size: 35,
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountPage()),
              );
            },
            child: Icon(
              Icons.person,
              color: Color(0xFFE57734),
              size: 35,
            ),
          ),
        ],
      ),
    );
  }
}
