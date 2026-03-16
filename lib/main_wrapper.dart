import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lsffend/global%20variable/colors.dart';
import 'package:lsffend/screens/navigation/chat/conversation_list_screen.dart';
import 'package:lsffend/screens/navigation/explore/explore_screen.dart';
import 'package:lsffend/screens/navigation/home/home_screen.dart';

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
    const Placeholder(),
    const Placeholder(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            label: 'Home',
            icon: FaIcon(FontAwesomeIcons.house, color: Colors.black),
          ),

          BottomNavigationBarItem(
            label: 'Explore',
            icon: FaIcon(FontAwesomeIcons.compass, color: Colors.black),
          ),

          BottomNavigationBarItem(
            label: 'Chat',
            icon: FaIcon(FontAwesomeIcons.comment, color: Colors.black),
          ),

          BottomNavigationBarItem(
            label: 'Bookmark',
            icon: FaIcon(FontAwesomeIcons.bookmark, color: Colors.black),
          ),

          BottomNavigationBarItem(
            label: 'Profile',
            icon: FaIcon(FontAwesomeIcons.user, color: Colors.black),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
