import 'package:flutter/material.dart';
import 'package:lsffend/screens/roles/user-ui/navigation/chat/conversation_list_screen.dart';

class WorkerBottomNavigation extends StatefulWidget {
  const WorkerBottomNavigation({super.key});

  @override
  WorkerBottomNavigationState createState() => WorkerBottomNavigationState();
}

class WorkerBottomNavigationState extends State<WorkerBottomNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const Placeholder(),
    const Placeholder(),
    const Placeholder(),
    const ConversationListScreen(),
    const Placeholder(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens.elementAt(_selectedIndex),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.house_outlined),
            selectedIcon: Icon(Icons.house_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_off_outlined),
            selectedIcon: Icon(Icons.explore_off_outlined),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_outline_rounded),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline_rounded),
            selectedIcon: Icon(Icons.bookmark_outline_rounded),
            label: 'Bookmark',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_off_rounded),
            selectedIcon: Icon(Icons.person_off_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
