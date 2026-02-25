import 'package:flutter/material.dart';

Widget buildBottomNavigation(Icon icon) {
  return Scaffold(
    bottomNavigationBar: BottomNavigationBar(
      items: [
        BottomNavigationBarItem(icon: icon, label: 'Home'),
        BottomNavigationBarItem(icon: icon, label: 'Explore'),
        BottomNavigationBarItem(icon: icon, label: 'Chat'),
        BottomNavigationBarItem(icon: icon, label: 'Bookmark'),
        BottomNavigationBarItem(icon: icon, label: 'Profile'),
      ],
    ),
  );
}
