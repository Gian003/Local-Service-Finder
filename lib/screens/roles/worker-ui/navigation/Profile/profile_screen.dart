import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lsf/config/app_config.dart';
import 'package:lsf/global%20variable/colors.dart';
import 'package:lsf/services/api_service.dart';
import 'package:lsf/services/auth_service.dart';

class WorkerProfileScreen extends StatefulWidget {
  const WorkerProfileScreen({super.key});

  @override
  WorkerProfileScreenState createState() => WorkerProfileScreenState();
}

class WorkerProfileScreenState extends State<WorkerProfileScreen> {
  Map<String, dynamic>? _worker;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorker();
  }

  Future<void> _loadWorker() async {
    if (AppConfig.offlineMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      setState(() {
        _worker = {
          'name': 'John Reyes',
          'email': 'john@lsf.com',
          'category': 'Cleaning',
          'rating': 4.8,
          'review_count': 150,
          'is_available': true,
          'profile_photo': null,
          'bio': 'Professional cleaning specialist with 5+ years experience.',
        };
        _isLoading = false;
      });
      return;
    }

    final response = await ApiService.getRequest('worker-auth/me', auth: true);
    if (!mounted) return;
    if (response.statusCode == 200) {
      setState(() {
        _worker = jsonDecode(response.body);
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  final List<Map<String, dynamic>> _menuSections = [
    {
      'section': 'Account',
      'items': [
        {
          'icon': Icons.person_outline,
          'label': 'Edit Profile',
          'route': '/worker-edit-profile',
        },
        {
          'icon': Icons.lock_outline,
          'label': 'Change Password',
          'route': '/change-password',
        },
        {
          'icon': Icons.notifications_outlined,
          'label': 'Notifications',
          'route': '/notifications',
        },
      ],
    },
    {
      'section': 'Business',
      'items': [
        {
          'icon': Icons.star_outline,
          'label': 'My Reviews',
          'route': '/worker-reviews',
        },
        {
          'icon': Icons.payments_outlined,
          'label': 'Earnings',
          'route': '/worker-earnings',
        },
      ],
    },
    {
      'section': 'Legal',
      'items': [
        {
          'icon': Icons.description_outlined,
          'label': 'Terms of Service',
          'route': '/terms',
        },
        {
          'icon': Icons.privacy_tip_outlined,
          'label': 'Privacy Policy',
          'route': '/privacy',
        },
      ],
    },
    {
      'section': 'Personal',
      'items': [
        {
          'icon': Icons.logout,
          'label': 'Log Out',
          'route': null,
          'isLogout': true,
        },
      ],
    },
  ];

  void _handleLogout() {
    final navigator = Navigator.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Log Out',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(fontFamily: 'Montserrat'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await AuthService.logout(role: 'worker');
              navigator.pushReplacementNamed('/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: const Center(
                    child: Text(
                      'Profile',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryColor,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Worker info
                        _buildWorkerHeader(),

                        const Divider(thickness: 1, height: 1),

                        // Stats row
                        _buildStatsRow(),

                        const Divider(thickness: 1, height: 1),

                        const SizedBox(height: 10),

                        // Menu sections
                        ..._menuSections.map(
                          (section) => _buildMenuSection(section),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildWorkerHeader() {
    final name = _worker?['name'] ?? 'Worker';
    final email = _worker?['email'] ?? '';
    final category = _worker?['category'] ?? '';
    final photo = _worker?['profile_photo'];
    final isAvail = _worker?['is_available'] ?? false;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundImage: photo != null ? NetworkImage(photo) : null,
                backgroundColor: Colors.grey[200],
                child: photo == null
                    ? Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'W',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryColor,
                        ),
                      )
                    : null,
              ),
              // Online/offline indicator
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isAvail ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  email,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 11,
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Availability toggle
          Column(
            children: [
              Text(
                isAvail ? 'Available' : 'Offline',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 11,
                  color: isAvail ? Colors.green : Colors.grey,
                ),
              ),
              Switch(
                value: isAvail,
                activeThumbColor: Colors.green,
                onChanged: (val) async {
                  setState(() => _worker?['is_available'] = val);
                  await ApiService.putRequest(
                    'worker-auth/availability',
                    {'is_available': val},
                    auth: true,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStat('Rating', '${_worker?['rating'] ?? 0} ⭐'),
          _buildDivider(),
          _buildStat('Reviews', '${_worker?['review_count'] ?? 0}'),
          _buildDivider(),
          _buildStat('Bookings', '24'),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 30, width: 1, color: Colors.grey[300]);
  }

  Widget _buildMenuSection(Map<String, dynamic> section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 16, bottom: 4),
          child: Text(
            section['section'],
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
        ),
        ...List<Map<String, dynamic>>.from(
          section['items'],
        ).map((item) => _buildMenuItem(item)),
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
              fontSize: 15,
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
