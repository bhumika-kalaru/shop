import 'package:flutter/material.dart';

class MyBottomWidget extends StatefulWidget {
  final int currentIndex;
  final void Function(int) onTabTapped;

  MyBottomWidget({required this.currentIndex, required this.onTabTapped});

  @override
  _MyBottomWidgetState createState() => _MyBottomWidgetState();
}

class _MyBottomWidgetState extends State<MyBottomWidget> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      onTap: widget.onTabTapped,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Wishlist',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Cart',
        ),
      ],
    );
  }
}
