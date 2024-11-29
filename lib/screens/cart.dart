import 'package:flutter/material.dart';
import 'package:flutter_application_6/screens/card_data.dart';
import 'package:flutter_application_6/widgets/home_bottom_bar.dart';

class Cart extends StatefulWidget {
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  List<dynamic> items = []; // Menyimpan item dari keranjang
  bool isLoading = true; // Status loading
  final Color mainColor = const Color(0xFFE57734);

  @override
  void initState() {
    super.initState();
    loadCartItems(); // Memuat data saat widget diinisialisasi
  }

  // Fungsi untuk memuat data dari CartData
  Future<void> loadCartItems() async {
    setState(() {
      isLoading = true;
    });

    // Ambil item dari CartData
    List<dynamic> fetchedItems = await CartData.getItems();

    setState(() {
      items = fetchedItems;
      isLoading = false;
    });
  }

  // Fungsi untuk menghapus item dari keranjang
  Future<void> removeItem(String itemName) async {
    try {
      // Hapus dari Firestore
      await CartData.removeItem(itemName);
      // Perbarui UI
      setState(() {
        items.removeWhere((item) => item['name'] == itemName);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Item '$itemName' berhasil dihapus dari keranjang."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Gagal menghapus item dari keranjang."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hitung total harga
    double totalPrice = items.fold(
      0.0,
      (sum, item) => sum + item['totalPrice'],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Your Cart",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            ),
        ),
        centerTitle: true,
        backgroundColor: mainColor,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : items.isEmpty
              ? Center(
                  child: Text(
                    "Cart is empty",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              margin: const EdgeInsets.only(bottom: 15),
                              elevation: 5,
                              shadowColor: Colors.black.withOpacity(0.2),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        item['img'], // Gambar dari item
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.error,
                                            size: 50,
                                            color: Colors.red,
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['name'],
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            "Qty: ${item['quantity']}",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            "Total: \Rp.${item['totalPrice'].toStringAsFixed(2)}",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => removeItem(item['name']),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total Price",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            "\Rp.${totalPrice.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  const Text("Checkout is under construction!"),
                              backgroundColor: Colors.blue,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: Colors.green,
                        ),
                        child: const Text(
                          "Proceed to Checkout",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                bottomNavigationBar: HomeBottomBar(),
    );
  }
}
