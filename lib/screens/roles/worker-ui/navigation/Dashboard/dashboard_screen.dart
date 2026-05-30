import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lsf/global%20variable/colors.dart';
import 'package:lsf/services/api_service.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _recentBookings = [];
  int _totalBookings = 0;
  int _pendingCount = 0;
  double _totalEarnings = 0;
  double _rating = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final bookingsRes =
          await ApiService.getRequest('bookings/worker', auth: true);
      final profileRes =
          await ApiService.getRequest('worker-auth/profile', auth: true);

      if (!mounted) return;

      if (bookingsRes.statusCode == 200) {
        final List<dynamic> list = jsonDecode(bookingsRes.body) is List
            ? jsonDecode(bookingsRes.body)
            : (jsonDecode(bookingsRes.body)['data'] ?? []);

        final bookings = list.cast<Map<String, dynamic>>();
        setState(() {
          _totalBookings = bookings.length;
          _pendingCount =
              bookings.where((b) => b['status'] == 'pending').length;
          _totalEarnings = bookings
              .where((b) => b['status'] == 'completed')
              .fold(0.0, (sum, b) => sum + (double.tryParse(b['total_price'].toString()) ?? 0));
          _recentBookings = bookings.take(3).toList();
        });
      }

      if (profileRes.statusCode == 200) {
        final profile = jsonDecode(profileRes.body);
        final workerData = profile['worker'] ?? profile;
        setState(() {
          _rating = double.tryParse(workerData['rating']?.toString() ?? '0') ?? 0;
        });
      }
    } catch (_) {
      // silently degrade — UI shows zeros
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                setState(() => _isLoading = true);
                await _loadData();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Dashboard',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            label: 'Total Earnings',
                            value: '₱${_totalEarnings.toStringAsFixed(0)}',
                            icon: Icons.payments_outlined,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            label: 'Total Bookings',
                            value: '$_totalBookings',
                            icon: Icons.calendar_today_outlined,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            label: 'Pending',
                            value: '$_pendingCount',
                            icon: Icons.pending_outlined,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            label: 'Rating',
                            value: '${_rating.toStringAsFixed(1)} ⭐',
                            icon: Icons.star_outline,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Recent Bookings',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    if (_recentBookings.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(
                            'No bookings yet',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                      )
                    else
                      ..._recentBookings.map(
                        (b) => _buildRecentBookingCard(
                          customerName:
                              '${b['user']?['first_name'] ?? ''} ${b['user']?['last_name'] ?? ''}'
                                  .trim(),
                          service: b['service']?['title'] ?? '',
                          date: b['scheduled_at']?.toString() ?? '',
                          status: b['status']?.toString() ?? 'pending',
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
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
      ),
    );
  }

  Widget _buildRecentBookingCard({
    required String customerName,
    required String service,
    required String date,
    required String status,
  }) {
    final Color statusColor = switch (status) {
      'pending' => Colors.orange,
      'accepted' => Colors.blue,
      'completed' => Colors.green,
      _ => Colors.grey,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[200],
            child: const Icon(Icons.person, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerName.isEmpty ? 'Customer' : customerName,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  service,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
