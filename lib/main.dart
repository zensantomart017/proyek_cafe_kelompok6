import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_6/firebase_options.dart';
import 'package:flutter_application_6/screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Tambahkan ini untuk menginisialisasi widget sebelum menjalankan async function
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key); // Tambahkan konstruktor

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFF212325),
      ),
      home: WelcomeScreen(),
    );
  }
}
