import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lsf/global%20variable/colors.dart';
import 'package:lsf/services/api_service.dart';

class WorkerBookingsScreen extends StatefulWidget {
  const WorkerBookingsScreen({super.key});

  @override
  WorkerBookingsScreenState createState() => WorkerBookingsScreenState();
}

class WorkerBookingsScreenState extends State<WorkerBookingsScreen> {
  String _selectedTab = 'Pending';
  bool _isLoading = true;
  List<Map<String, dynamic>> _bookings = [];

  final List<String> _tabs = ['Pending', 'Accepted', 'Completed', 'Rejected', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() => _isLoading = true);
    try {
      final response =
          await ApiService.getRequest('bookings/worker', auth: true);
      if (!mounted) return;
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> list =
            decoded is List ? decoded : (decoded['data'] ?? []);
        setState(() => _bookings = list.cast<Map<String, dynamic>>());
      }
    } catch (_) {
      // silently degrade
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredBookings => _bookings
      .where((b) => b['status'] == _selectedTab.toLowerCase())
      .toList();

  Future<void> _updateBookingStatus(int bookingId, String action) async {
    try {
      final response = await ApiService.putRequest(
        'bookings/$bookingId/$action',
        {},
        auth: true,
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        await _fetchBookings();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to $action booking')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error while trying to $action booking')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'My Bookings',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _fetchBookings,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _tabs.map((tab) {
                  final isSelected = _selectedTab == tab;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = tab),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryColor
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Text(
                          tab,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 15),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredBookings.isEmpty
                    ? Center(
                        child: Text(
                          'No ${_selectedTab.toLowerCase()} bookings',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            color: Colors.grey[500],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _filteredBookings.length,
                        itemBuilder: (context, index) {
                          return _buildBookingCard(
                              _filteredBookings[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final int bookingId = booking['id'] ?? 0;
    final String status = booking['status']?.toString() ?? '';
    final String customerName =
        '${booking['user']?['first_name'] ?? ''} ${booking['user']?['last_name'] ?? ''}'
            .trim();
    final String serviceName = booking['service']?['title'] ?? '';
    final String date = booking['scheduled_at']?.toString() ?? '';
    final double price =
        double.tryParse(booking['total_price']?.toString() ?? '0') ?? 0;
    final String? imageUrl = booking['user']?['profile_photo'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage:
                    imageUrl != null ? NetworkImage(imageUrl) : null,
                backgroundColor: Colors.grey[200],
                radius: 25,
                child: imageUrl == null
                    ? const Icon(Icons.person, color: Colors.grey)
                    : null,
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
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      serviceName,
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
              Text(
                '₱${price.toStringAsFixed(0)}',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),

          if (status == 'pending') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        _updateBookingStatus(bookingId, 'reject'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Reject',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        _updateBookingStatus(bookingId, 'accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Accept',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],

          if (status == 'accepted') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    _updateBookingStatus(bookingId, 'complete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Mark Complete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
