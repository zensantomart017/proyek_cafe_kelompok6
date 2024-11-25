import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_application_6/screens/single_item_screen.dart';
import 'package:flutter_application_6/firestore_service.dart';
import 'package:flutter_application_6/menu_item.dart';

class ItemsWidget extends StatefulWidget {
  @override
  _ItemsWidgetState createState() => _ItemsWidgetState();
}

class _ItemsWidgetState extends State<ItemsWidget> {
  // Ganti Future dengan Stream
  late Stream<List<MenuItem>> _itemsStream;

  @override
  void initState() {
    super.initState();
    _itemsStream = FirestoreService().getMenuItemsStream(); // Mengambil stream dari Firestore
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MenuItem>>(
      stream: _itemsStream,
      builder: (context, snapshot) {
        // Menampilkan loading spinner saat data sedang dimuat
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        // Menampilkan pesan error jika ada masalah saat mengambil data
        else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        // Menampilkan pesan ketika tidak ada data yang tersedia
        else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No items available."));
        }

        // Setelah data berhasil dimuat, tampilkan dalam grid
        else {
          final items = snapshot.data!;

          return SingleChildScrollView( // Membungkus GridView dengan SingleChildScrollView untuk menangani overflow
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Dua item per baris
                crossAxisSpacing: 8.0, // Spasi antar item
                mainAxisSpacing: 8.0, // Spasi antar baris
                childAspectRatio: (150 / 195), // Rasio aspek setiap item grid
              ),
              shrinkWrap: true, // Pastikan grid hanya mengambil ruang yang diperlukan
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];

                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 13),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xFF212325),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        spreadRadius: 1,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SingleItemScreen(
                                item.image,
                                item.name,
                                item.price,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          child: Image.network(
                            item.image,
                            width: 120,
                            height: 120,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              } else {
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                (loadingProgress.expectedTotalBytes ?? 1)
                                            : null
                                        : null,
                                  ),
                                );
                              }
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.error,
                                size: 50,
                                color: Colors.red,
                              );
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.description,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white60,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Rp.${item.price}",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE57734),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                CupertinoIcons.add,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}
