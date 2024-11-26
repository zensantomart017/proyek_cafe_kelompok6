import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_6/auth/login.dart';
import 'package:flutter_application_6/cold_coffee/cold_coffee.dart';
import 'package:flutter_application_6/food/food.dart';
import 'package:flutter_application_6/snacks/snacks.dart';
import 'package:flutter_application_6/widgets/home_bottom_bar.dart';
import 'package:flutter_application_6/Hot%20Coffee/items_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<Offset> _menuAnimation;
  String namaLengkap = "";
  String email = "";
  bool isMenuOpen = false;

  final Color mainColor = const Color(0xFFE57734);
  final Color secondaryColor = const Color.fromARGB(255, 50, 54, 56);

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _menuAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadUserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        setState(() {
          namaLengkap =
              prefs.getString('namaLengkap') ?? currentUser.displayName ?? '';
          email = currentUser.email ?? '';
          if (email.isNotEmpty) {
            prefs.setString('email', email);
          }
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _toggleMenu() {
    setState(() {
      isMenuOpen = !isMenuOpen;
      if (isMenuOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _handleTabSelection() {
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              if (isMenuOpen) {
                _toggleMenu();
              }
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: _toggleMenu,
                          child: Icon(
                            Icons.sort_rounded,
                            color: Colors.white.withOpacity(0.5),
                            size: 35,
                          ),
                        ),
                        InkWell(
                          onTap: () {},
                          child: Icon(
                            Icons.notifications,
                            color: Colors.white.withOpacity(0.5),
                            size: 35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      "Sini KL Yuk",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                    width: MediaQuery.of(context).size.width,
                    height: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Find your coffee",
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          size: 30,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                  TabBar(
                    controller: _tabController,
                    labelColor: mainColor,
                    unselectedLabelColor: Colors.white.withOpacity(0.5),
                    isScrollable: true,
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(width: 3, color: mainColor),
                      insets: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    labelStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 20),
                    tabs: const [
                      Tab(text: "Hot Coffee"),
                      Tab(text: "Cold Coffee"),
                      Tab(text: "Snacks"),
                      Tab(text: "Food"),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Tampilan Berdasarkan Tab
                  SizedBox(
                    height: 500, // Tentukan tinggi sesuai kebutuhan
                    child: IndexedStack(
                      index: _tabController.index,
                      children: [
                        ItemsWidget(),
                        ColdWidget(),
                        SnacksWidget(),
                        FoodWidget(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SlideTransition(
            position: _menuAnimation,
            child: Container(
              width: 250,
              color: Colors.grey[900],
              padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: mainColor,
                    radius: 30,
                    child: Text(
                      namaLengkap.isNotEmpty ? namaLengkap[0].toUpperCase() : '',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    namaLengkap,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    email,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Divider(color: Colors.white.withOpacity(0.5)),
                  ListTile(
                    leading: const Icon(Icons.home, color: Colors.white),
                    title: const Text('Home', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      _toggleMenu();
                      Navigator.pushNamed(context, HomeScreen.routeName);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings, color: Colors.white),
                    title: const Text('Settings', style: TextStyle(color: Colors.white)),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.white),
                    title: const Text('Logout', style: TextStyle(color: Colors.white)),
                    onTap: _logout,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: HomeBottomBar(),
    );
  }
}

// Implementasikan ColdCoffeeWidget, SnacksWidget, dan DessertsWidget secara terpisah.
