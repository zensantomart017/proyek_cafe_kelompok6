import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_6/widgets/home_bottom_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AccountPage extends StatefulWidget {
  static const String routeName = '/account';

  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String namaLengkap = "";
  String email = "";
  bool isEditing = false;
  final TextEditingController _namaController = TextEditingController();
  final Color mainColor = const Color(0xFFE57734);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      SharedPreferences prefs = await SharedPreferences.getInstance();

      setState(() {
        namaLengkap = prefs.getString('namaLengkap') ?? currentUser?.displayName ?? '';
        email = currentUser?.email ?? '';
        _namaController.text = namaLengkap;
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _updateProfile() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await currentUser.updateDisplayName(_namaController.text);
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('namaLengkap', _namaController.text);

      setState(() {
        namaLengkap = _namaController.text;
        isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: ${e.toString()}")),
      );
    }
  }

  Future<List<String>> _fetchLanguages() async {
    const String url = 'https://restcountries.com/v3.1/all';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        final languages = data
            .map((country) => country['languages']?.values ?? [])
            .expand((lang) => lang)
            .toSet()
            .toList();
        languages.sort();
        return languages.cast<String>();
      } else {
        throw Exception('Failed to load languages');
      }
    } catch (e) {
      print('Error fetching languages: $e');
      return [];
    }
  }

  Widget _buildEditableField({required String label, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: const Text(
          'Account Information',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            ),
        ),
        centerTitle: true,
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.save, color: Colors.white),
              onPressed: _updateProfile,
            )
          else
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () => setState(() => isEditing = true),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.orange,
                    child: Text(
                      namaLengkap.isNotEmpty ? namaLengkap[0].toUpperCase() : '',
                      style: const TextStyle(
                        fontSize: 48,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Nama Lengkap dan Email
            if (!isEditing)
              Column(
                children: [
                  Text(
                    namaLengkap,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    email,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  _buildEditableField(label: "Full Name", controller: _namaController),
                  const SizedBox(height: 20),
                  Text(
                    "Email",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    email,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),

            const SizedBox(height: 20),

            // Pengaturan
            ListTile(
              leading: const Icon(Icons.language, color: Colors.orange),
              title: const Text('Language', style: TextStyle(color: Colors.white)),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
              onTap: () async {
                final languages = await _fetchLanguages();
                if (languages.isNotEmpty) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Languages'),
                      content: SizedBox(
                        width: double.maxFinite,
                        child: ListView.builder(
                          itemCount: languages.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(languages[index]),
                              onTap: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Selected language: ${languages[index]}')),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to load languages')),
                  );
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: HomeBottomBar(),
    );
  }
}
