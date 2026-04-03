import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lsffend/config/app_config.dart';
import 'package:lsffend/global%20variable/colors.dart';
import 'package:lsffend/services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userPRofile;
  bool _isLoading = true;

  Future<void> _loadUSer() async {
    // Simulate loading user profile data
    if (AppConfig.offlineMode) {
      await Future.delayed(const Duration(seconds: 3));
      setState(() {
        _userPRofile = {
          'first_name': 'John',
          'last_name': 'Doe',
          'email': 'user@gmail.com',
          'profile_photo': null,
        };
        _isLoading = false;
      });
      return;
    }

    //Real API call to load user profile data
    final response = await ApiService.getRequest(
      'user-auth/get-current-user',
      auth: true,
    );
    if (response.statusCode == 200) {
      setState(() {
        _userPRofile = jsonDecode(response.body);
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUSer();
  }

  //Profile sections
  final List<Map<String, dynamic>> _profileSections = [
    {
      'section': 'General',
      'items': [
        {
          'icon': Icons.person_outline,
          'label': 'My Profile',
          'route': '/edit-profile',
        },
        {
          'icon': Icons.notifications_outlined,
          'label': 'Notifications',
          'route': '/notifications',
        },
        {
          'icon': Icons.bookmark_outline,
          'label': 'Bookmarks',
          'route': '/bookmarks',
        },
      ],
    },

    {
      'section': 'Legal',
      'items': [
        {
          'icon': Icons.description_outlined,
          'label': 'Terms of Service',
          'route': '/terms-of-service',
        },
        {
          'icon': Icons.privacy_tip_outlined,
          'label': 'Privacy Policy',
          'route': '/privacy-policy',
        },
        {
          'icon': Icons.help_outline,
          'label': 'Help & Support',
          'route': '/help-support',
        },
      ],
    },

    {
      'section': 'Personal',
      'items': [
        {
          'icon': Icons.bug_report_outlined,
          'label': 'Report a Bug',
          'route': '/report-bug',
        },

        {
          'icon': Icons.logout_outlined,
          'label': 'Logout',
          'route': null,
          'isLogout': true,
        },
      ],
    },
  ];

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Logout',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontFamily: 'Montserrat', fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'Montserrat', fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Logout',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'My Profile',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 50),
              ],
            ),
          ),
      
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [ 
                  _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildUserHeader(),

                          const Divider(thickness: 1, height:1),

                          const SizedBox(height: 10),

                          ..._profileSections.map(
                            (section) => _buildMenuSection(section)
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    final firstName = _userPRofile?['first_name'] ?? 'User';
    final lastName = _userPRofile?['last_name'] ?? '';
    final email = _userPRofile?['email'] ?? '';
    final profilePhoto = _userPRofile?['profile_photo'];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundImage: profilePhoto != null
                ? NetworkImage(profilePhoto)
                : null,
            backgroundColor: Colors.grey[200],
            child: profilePhoto == null
                ? Text(
                    firstName.isNotEmpty ? firstName[0].toUpperCase() : 'User',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  )
                : null,
          ),

          const SizedBox(width: 16),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$firstName $lastName',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(Map<String, dynamic> section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, left: 20, bottom: 4),
          child: Text(
            section['section'],
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),

        ...List<Map<String, dynamic>>.from(
          section['items'],
        ).map((item) => _buildMenuSection(section)),
      ],
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item) {
    final bool isLogout = item['isLogout'] ?? false;

    return Column(
      children: [
        ListTile(
          onTap: () {
            if (isLogout) {
              _handleLogout();
            } else if (item['route'] != null) {
              Navigator.pushNamed(context, item['route']);
            }
          },
          leading: Icon(
            item['icon'],
            color: isLogout ? Colors.red : Colors.black,
            size: 22,
          ),
          title: Text(
            item['label'],
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: isLogout ? Colors.red : Colors.black,
            ),
          ),
          trailing: isLogout
              ? null
              : Icon(Icons.chevron_right, color: Colors.grey[400]),
        ),
        const Divider(height: 1, indent: 20),
      ],
    );
  }
}
