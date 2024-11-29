import 'package:flutter/material.dart';
import 'package:flutter_application_6/screens/Favorite_Item.dart';
import 'package:flutter_application_6/widgets/home_bottom_bar.dart';

class FavoriteList extends StatefulWidget {
  @override
  State<FavoriteList> createState() => _FavoriteListState();
}

class _FavoriteListState extends State<FavoriteList> {
  final Color mainColor = const Color(0xFFE57734);

  // Menyimpan daftar item favorit yang diambil dari Firestore
  List<dynamic> favoriteItems = [];

  @override
  void initState() {
    super.initState();
    _loadFavoriteItems();
  }

  // Memuat daftar favorit dari Firestore
  Future<void> _loadFavoriteItems() async {
    List<dynamic> items = await FavoriteData.getItems();
    setState(() {
      favoriteItems = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Your Favorites List", 
        style: TextStyle(
          color: Colors.white, 
          fontSize: 20,
          fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: mainColor,
      ),
      body: favoriteItems.isEmpty
          ? const Center(
              child: Text(
                "Tidak ada item favorit",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: favoriteItems.length,
              itemBuilder: (context, index) {
                final item = favoriteItems[index]; // Ambil item favorit
                return Card(
                  elevation: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gambar item
                      Expanded(
                        child: Image.network(
                          item['img'],
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.error,
                              size: 50,
                              color: Colors.red,
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '\Rp.${item['price'].toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            // Menghapus item favorit berdasarkan nama
                            await FavoriteData.removeItem(item['name']);
                            // Memuat ulang daftar favorit setelah penghapusan
                            _loadFavoriteItems();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            minimumSize: const Size(double.infinity, 40),
                          ),
                          child: const Text(
                            'Hapus',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: HomeBottomBar(),
    );
  }
}
