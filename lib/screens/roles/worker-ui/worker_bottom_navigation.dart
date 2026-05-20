import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lsf/global%20variable/colors.dart';
import 'package:lsf/screens/roles/user-ui/navigation/chat/conversation_list_screen.dart';
import 'package:lsf/screens/roles/worker-ui/navigation/Booking/booking_screen.dart';
import 'package:lsf/screens/roles/worker-ui/navigation/Dashboard/dashboard_screen.dart';
import 'package:lsf/screens/roles/worker-ui/navigation/Profile/profile_screen.dart';
import 'package:lsf/screens/roles/worker-ui/navigation/Services/services_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            label: 'Dashboard',
            icon: FaIcon(FontAwesomeIcons.chartLine),
          ),

          BottomNavigationBarItem(
            label: 'Bookings',
            icon: FaIcon(FontAwesomeIcons.calendarCheck),
          ),

          BottomNavigationBarItem(
            label: 'Services',
            icon: FaIcon(FontAwesomeIcons.briefcase),
          ),

          BottomNavigationBarItem(
            label: 'Chat',
            icon: FaIcon(FontAwesomeIcons.comment),
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
