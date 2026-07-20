import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lsf/global%20variable/colors.dart';
import 'package:lsf/screens/roles/user-ui/navigation/bookmark/bookmark_screen.dart';
import 'package:lsf/screens/roles/user-ui/navigation/chat/conversation_list_screen.dart';
import 'package:lsf/screens/roles/user-ui/navigation/explore/explore_screen.dart';
import 'package:lsf/screens/roles/user-ui/navigation/home/home_screen.dart';
import 'package:lsf/screens/roles/user-ui/navigation/profile/profile_screen.dart';
import 'package:lsf/services/api_service.dart';
import 'package:showcaseview/showcaseview.dart';

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

  // Keys must be stable across rebuilds, so these live as instance fields
  // rather than being created inside build().
  final _homeKey = GlobalKey();
  final _exploreKey = GlobalKey();
  final _chatKey = GlobalKey();
  final _bookmarkKey = GlobalKey();
  final _profileKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    ShowcaseView.register();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeStartTour());
  }

  Future<void> _maybeStartTour() async {
    final seen = await ApiService.hasSeenNavTour(role: 'customer');
    if (seen || !mounted) return;

    ShowcaseView.get().startShowCase(
      [_homeKey, _exploreKey, _chatKey, _bookmarkKey, _profileKey],
    );
    await ApiService.markNavTourSeen(role: 'customer');
  }

  @override
  void dispose() {
    ShowcaseView.get().unregister();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            label: 'Home',
            icon: Showcase(
              key: _homeKey,
              title: 'Home',
              description: 'Browse services and find what you need right here.',
              child: const FaIcon(FontAwesomeIcons.house),
            ),
          ),

          BottomNavigationBarItem(
            label: 'Explore',
            icon: Showcase(
              key: _exploreKey,
              title: 'Explore',
              description: 'Search and filter every available service.',
              child: const FaIcon(FontAwesomeIcons.binoculars),
            ),
          ),

          BottomNavigationBarItem(
            label: 'Chat',
            icon: Showcase(
              key: _chatKey,
              title: 'Chat',
              description: 'Message your service provider in real time.',
              child: const FaIcon(FontAwesomeIcons.comment),
            ),
          ),

          BottomNavigationBarItem(
            label: 'Bookmark',
            icon: Showcase(
              key: _bookmarkKey,
              title: 'Bookmark',
              description: 'Track your upcoming and past bookings.',
              child: const FaIcon(FontAwesomeIcons.bookmark),
            ),
          ),

          BottomNavigationBarItem(
            label: 'Profile',
            icon: Showcase(
              key: _profileKey,
              title: 'Profile',
              description: 'Manage your account, addresses, and settings.',
              child: const FaIcon(FontAwesomeIcons.user),
            ),
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
