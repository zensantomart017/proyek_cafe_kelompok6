import 'package:flutter/material.dart';

class CheckoutScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // Metode pembayaran
    List<String> paymentMethods = ["Dana", "GoPay", "OVO", "Bank Transfer", "Cash"];
    String selectedMethod = paymentMethods[0]; // Default metode pembayaran

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
                // Gambar produk
                Image.network(
                  img,
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error, size: 50, color: Colors.red);
                  },
                ),
                const SizedBox(width: 20),
                // Detail produk
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Price: \Rp.${price.toStringAsFixed(0)}",
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Quantity: $quantity",
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Total: \Rp.${totalPrice.toStringAsFixed(0)}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Dropdown metode pembayaran
            const Text(
              "Select Payment Method",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedMethod,
              onChanged: (String? value) {
                selectedMethod = value ?? selectedMethod;
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
            // Tombol Confirm Purchase
            ElevatedButton(
              onPressed: () {
                // Logika setelah checkout, misalnya kembali ke home
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Center(
                child: Text(
                  "Confirm Purchase",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
