import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lsffend/global%20variable/colors.dart';
import 'package:lsffend/screens/roles/user-ui/navigation/bookmark/bookmark_screen.dart';
import 'package:lsffend/screens/roles/user-ui/navigation/chat/conversation_list_screen.dart';
import 'package:lsffend/screens/roles/user-ui/navigation/explore/explore_screen.dart';
import 'package:lsffend/screens/roles/user-ui/navigation/home/home_screen.dart';
import 'package:lsffend/screens/roles/user-ui/navigation/profile/profile_screen.dart';

class UserBottomNavigation extends StatefulWidget {
  const UserBottomNavigation({super.key});

  @override
  UserBottomNavigationState createState() => UserBottomNavigationState();
}

class UserBottomNavigationState extends State<UserBottomNavigation> {
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
            icon: FaIcon(FontAwesomeIcons.house),
          ),

          BottomNavigationBarItem(
            label: 'Explore',
            icon: FaIcon(FontAwesomeIcons.binoculars),
          ),

          BottomNavigationBarItem(
            label: 'Chat',
            icon: FaIcon(FontAwesomeIcons.comment),
          ),

          BottomNavigationBarItem(
            label: 'Bookmark',
            icon: FaIcon(FontAwesomeIcons.bookmark),
          ),

          BottomNavigationBarItem(
            label: 'Profile',
            icon: FaIcon(FontAwesomeIcons.user),
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
