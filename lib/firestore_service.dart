import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_6/Hot%20Coffee/menu_item.dart';
import 'package:flutter_application_6/cold_coffee/cold_menu.dart';
import 'package:flutter_application_6/snacks/snacks_menu.dart';
import 'package:flutter_application_6/food/food_menu.dart';


class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fungsi untuk mendapatkan data dari koleksi 'menu'
  Stream<List<MenuItem>> getMenuItemsStream() {
    return _db.collection('menu')
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return MenuItem.fromFirestore(doc.data()); // Mengonversi data menjadi objek MenuItem
      }).toList();
    });
  }

  // Fungsi untuk mendapatkan data dari koleksi 'cold'
  Stream<List<ColdItem>> getColdItemsStream() {
    return _db.collection('cold')
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return ColdItem.fromFirestore(doc.data()); // Mengonversi data menjadi objek ColdItem
      }).toList();
    });
  }
  Stream<List<SnacksItem>> getSnacksItemsStream(){
    return _db.collection('snack')
      .snapshots()
      .map((QuerySnapshot){
        return QuerySnapshot.docs.map((doc){
          return SnacksItem.fromFirestore(doc.data());
        }).toList();
      });
  }
  Stream<List<FoodItem>> getFoodItemsStream(){
    return _db.collection('food')
      .snapshots()
      .map((QuerySnapshot){
        return QuerySnapshot.docs.map((doc){
          return FoodItem.fromFirestore(doc.data());
        }).toList();
      });
  }
}
