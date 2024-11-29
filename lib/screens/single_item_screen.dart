import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_6/screens/Favorite_Item.dart';
import 'package:flutter_application_6/screens/card_data.dart';
import 'package:flutter_application_6/screens/checkout.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import Cart Data

class SingleItemScreen extends StatefulWidget {
  final String img; // The image URL
  final String name; // Name of the item
  final double price; // Price of the item

  const SingleItemScreen(this.img, this.name, this.price, {Key? key}) : super(key: key);

  @override
  _SingleItemScreenState createState() => _SingleItemScreenState();
}

class _SingleItemScreenState extends State<SingleItemScreen> {
  int _quantity = 1; // Initial quantity
  late double _totalPrice; // Total price based on quantity
  late bool _isFavorite = false; // Variable to track favorite status

  @override
  void initState() {
    super.initState();
    _totalPrice = widget.price * _quantity;
    _loadFavoriteStatus();
  }

  _loadFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFavorite = prefs.getBool('favorite_${widget.name}') ?? false;
    });
  }

  _saveFavoriteStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('favorite_${widget.name}', value);
  }

  void _updateQuantity(int newQuantity) {
    setState(() {
      _quantity = newQuantity;
      _totalPrice = widget.price * _quantity;
    });
  }

void _toggleFavorite() {
  setState(() {
    _isFavorite = !_isFavorite;

    if (_isFavorite) {
      FavoriteData.addItem(
        img: widget.img,
        name: widget.name,
        price: widget.price,
      ).then((_) {
        print('${widget.name} ditambahkan ke favorit');
      });
    } else {
      FavoriteData.removeItem(widget.name).then((_) {
        print('${widget.name} dihapus dari favorit');
        // Ganti dengan getItems untuk memuat favorit yang terbaru jika diperlukan
        FavoriteData.getItems().then((favorites) {
          // Lakukan sesuatu dengan data favorit yang baru di sini, jika diperlukan
          print("Favorit terbaru: $favorites");
        });
      });
    }

      // Simpan status favorit
      _saveFavoriteStatus(_isFavorite);
    });

    // Tampilkan notifikasi kepada pengguna
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite 
          ? '${widget.name} ditambahkan ke favorit' 
          : '${widget.name} dihapus dari favorit'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _addToCart() async {
    try {
      await CartData.addItem(
        img: widget.img,  // Pass the image URL
        name: widget.name,
        price: widget.price,
        quantity: _quantity,
      );

      // Show snackbar notification when item is added to cart
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.name} has been added to the cart!'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Show snackbar if an error occurs
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _goToCheckout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          img: widget.img,
          name: widget.name,
          price: widget.price,
          quantity: _quantity,
          totalPrice: _totalPrice,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context, _isFavorite),
                ),
                const SizedBox(height: 30),
                // Image of the item
                Center(
                  child: Image.network(
                    widget.img, // Use the image URL here
                    width: MediaQuery.of(context).size.width * 0.8,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.error,
                        size: 50,
                        color: Colors.red,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),
                // Item name and price
                Text(
                  widget.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Price: \Rp.${widget.price.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                // Quantity selector and total price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (_quantity > 1) {
                              _updateQuantity(_quantity - 1);
                            }
                          },
                          child: const Icon(
                            CupertinoIcons.minus_circle,
                            color: Colors.white,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            '$_quantity',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _updateQuantity(_quantity + 1);
                          },
                          child: const Icon(
                            CupertinoIcons.plus_circle,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "Total: \Rp.${_totalPrice.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Add to Cart button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: _addToCart,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text("Add to Cart"),
                    ),
                    IconButton(
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: _toggleFavorite,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _goToCheckout,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    backgroundColor: Colors.green, // Warna hijau untuk tombol checkout
                  ),
                  child: const Text(
                    "Checkout Now",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}