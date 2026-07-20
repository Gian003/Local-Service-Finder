import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lsf/global%20variable/colors.dart';
import 'package:lsf/screens/roles/user-ui/navigation/chat/conversation_list_screen.dart';
import 'package:lsf/screens/roles/worker-ui/navigation/Booking/booking_screen.dart';
import 'package:lsf/screens/roles/worker-ui/navigation/Dashboard/dashboard_screen.dart';
import 'package:lsf/screens/roles/worker-ui/navigation/Profile/profile_screen.dart';
import 'package:lsf/screens/roles/worker-ui/navigation/Services/services_screen.dart';
import 'package:lsf/services/api_service.dart';
import 'package:showcaseview/showcaseview.dart';

class WorkerBottomNavigation extends StatefulWidget {
  const WorkerBottomNavigation({super.key});

  @override
  WorkerBottomNavigationState createState() => WorkerBottomNavigationState();
}

class WorkerBottomNavigationState extends State<WorkerBottomNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashBoardScreen(),
    const WorkerBookingsScreen(),
    const WorkerServicesScreen(),
    const ConversationListScreen(),
    const WorkerProfileScreen(),
  ];

  // Keys must be stable across rebuilds, so these live as instance fields
  // rather than being created inside build().
  final _dashboardKey = GlobalKey();
  final _bookingsKey = GlobalKey();
  final _servicesKey = GlobalKey();
  final _chatKey = GlobalKey();
  final _profileKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    ShowcaseView.register();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeStartTour());
  }

  Future<void> _maybeStartTour() async {
    final seen = await ApiService.hasSeenNavTour(role: 'worker');
    if (seen || !mounted) return;

    ShowcaseView.get().startShowCase(
      [_dashboardKey, _bookingsKey, _servicesKey, _chatKey, _profileKey],
    );
    await ApiService.markNavTourSeen(role: 'worker');
  }

  @override
  void dispose() {
    ShowcaseView.get().unregister();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            label: 'Dashboard',
            icon: Showcase(
              key: _dashboardKey,
              title: 'Dashboard',
              description: 'See your stats and recent activity at a glance.',
              child: const FaIcon(FontAwesomeIcons.chartLine),
            ),
          ),

          BottomNavigationBarItem(
            label: 'Bookings',
            icon: Showcase(
              key: _bookingsKey,
              title: 'Bookings',
              description: 'Accept, reject, and manage job requests here.',
              child: const FaIcon(FontAwesomeIcons.calendarCheck),
            ),
          ),

          BottomNavigationBarItem(
            label: 'Services',
            icon: Showcase(
              key: _servicesKey,
              title: 'Services',
              description: 'Add and edit the services you offer, with photos and video.',
              child: const FaIcon(FontAwesomeIcons.briefcase),
            ),
          ),

          BottomNavigationBarItem(
            label: 'Chat',
            icon: Showcase(
              key: _chatKey,
              title: 'Chat',
              description: 'Message your customers in real time.',
              child: const FaIcon(FontAwesomeIcons.comment),
            ),
          ),

          BottomNavigationBarItem(
            label: 'Profile',
            icon: Showcase(
              key: _profileKey,
              title: 'Profile',
              description: 'Manage your account and availability.',
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
