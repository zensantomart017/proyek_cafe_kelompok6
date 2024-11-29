import 'package:flutter/material.dart';
import 'package:flutter_application_6/screens/cart.dart';
import 'package:flutter_application_6/screens/favorite_list.dart';
import 'package:flutter_application_6/screens/home_screen.dart';
import 'package:flutter_application_6/screens/info_akun.dart';

class HomeBottomBar extends StatelessWidget {
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
                MaterialPageRoute(
                  builder: (context) => HomeScreen()
                  )
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
                MaterialPageRoute(
                  builder: (context) => FavoriteList()
                  )
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
                MaterialPageRoute(
                  builder: (context) => HomeScreen()
                  )
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
                MaterialPageRoute(
                  builder: (context) => Cart()
                  )
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
                MaterialPageRoute(
                  builder: (context) => const AccountPage()
                  )
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
