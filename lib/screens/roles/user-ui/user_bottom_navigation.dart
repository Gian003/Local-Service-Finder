import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lsffend/global%20variable/colors.dart';
import 'package:lsffend/screens/roles/user-ui/navigation/bookmark/bookmark_screen.dart';
import 'package:lsffend/screens/roles/user-ui/navigation/chat/conversation_list_screen.dart';
import 'package:lsffend/screens/roles/user-ui/navigation/explore/explore_screen.dart';
import 'package:lsffend/screens/roles/user-ui/navigation/home/home_screen.dart';
import 'package:lsffend/screens/roles/user-ui/navigation/profile/profile_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  MainWrapperState createState() => MainWrapperState();
}

class MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const ExploreScreen(),
    const ConversationListScreen(),
    const BookmarkScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            label: 'Home',
            icon: Icon(Icons.house_outlined),
          ),

          BottomNavigationBarItem(
            label: 'Explore',
            icon: Icon(Icons.explore_off_outlined),
          ),

          BottomNavigationBarItem(
            label: 'Chat',
            icon: Icon(Icons.chat_bubble_outline_rounded),
          ),

          BottomNavigationBarItem(
            label: 'Bookmark',
            icon: Icon(Icons.bookmark_outline_rounded),
          ),

          BottomNavigationBarItem(
            label: 'Profile',
            icon: Icon(Icons.person_off_rounded),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Colors.black,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
