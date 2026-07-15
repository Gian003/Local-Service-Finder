import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lsf/global%20variable/colors.dart';
import 'package:lsf/models/booking_model.dart';
import 'package:lsf/screens/booking/upcoming_booking_screen.dart';
import 'package:lsf/screens/roles/user-ui/navigation/bookmark/bookmark_card.dart';
import 'package:lsf/screens/roles/user-ui/navigation/bookmark/bookmark_model.dart';
import 'package:lsf/services/api_service.dart';
import 'package:lsf/services/local_db.dart';
import 'package:lsf/services/review_service.dart';
import 'package:lsf/widgets/offline_banner.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => BookmarkScreenState();
}

class BookmarkScreenState extends State<BookmarkScreen> {
  String _selectedTab = 'Upcoming';

  // 'Upcoming' maps to backend statuses pending + accepted
  // 'Completed', 'Cancelled' map directly
  final List<String> _tabs = ['Upcoming', 'Completed', 'Cancelled', 'Saved'];

  // Full list fetched once; tabs filter in the getter below
  List<BookingModel> _allBookings = [];
  bool _isLoading = true;
  bool _isShowingCachedData = false;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.getRequest('bookings/user', auth: true);
      if (!mounted) return;

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> list;
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map<String, dynamic>) {
          list = (decoded['data'] ?? decoded['bookings'] ?? []) as List<dynamic>;
        } else {
          list = [];
        }
        final rawBookings = list.whereType<Map<String, dynamic>>().toList();

        unawaited(LocalDb.cacheBookings('user', rawBookings));

        setState(() {
          _allBookings = rawBookings.map((json) => BookingModel.fromJson(json)).toList();
          _isShowingCachedData = false;
        });
      }
    } catch (_) {
      // Network unreachable — fall back to the last successful fetch.
      final cached = await LocalDb.getCachedBookings('user');
      if (!mounted) return;
      setState(() {
        _allBookings = cached.map((json) => BookingModel.fromJson(json)).toList();
        _isShowingCachedData = cached.isNotEmpty;
      });
    }

    if (mounted) setState(() => _isLoading = false);
  }

  // Filter in the getter so tab changes instantly without re-fetching
  List<BookingModel> get _filteredBookings {
    return _allBookings.where((b) {
      if (_selectedTab == 'Upcoming') {
        return b.status == 'pending' || b.status == 'accepted';
      }
      if (_selectedTab == 'Cancelled') {
        return b.status == 'cancelled' || b.status == 'rejected';
      }
      return b.status == _selectedTab.toLowerCase();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isShowingCachedData) const OfflineBanner(),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                'My Bookings',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryColor,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _tabs.map((tab) {
                  final bool isSelected = _selectedTab == tab;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
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
                              : Colors.white,
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(8),
                            right: Radius.circular(8),
                          ),
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
                            fontSize: 15,
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
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _selectedTab == 'Saved'
                        ? _buildSavedList()
                        : _buildBookingList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingList() {
    final bookings = _filteredBookings;

    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'No ${_selectedTab.toLowerCase()} bookings yet.',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          final bookmark = BookmarkModel(
            id: booking.id,
            serviceType: 'Service',
            serviceName: booking.serviceName,
            providerName: booking.workerName,
            imageUrl: booking.workerImage ?? '',
            date: DateTime.now(),
            status: booking.status,
          );

          return BookmarkCard(
            bookmark: bookmark,
            onTap: () {
              if (_selectedTab == 'Upcoming') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UpcomingBookingScreen(
                      booking: booking,
                    ),
                  ),
                );
              } else if (_selectedTab == 'Completed') {
                _showReviewDialog(booking);
              }
            },
          );
        },
      ),
    );
  }

  Future<void> _showReviewDialog(BookingModel booking) async {
    final workerId = booking.workerId;
    if (workerId == null) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    double rating = 5;
    final commentController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Rate ${booking.workerName}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () =>
                            setDialogState(() => rating = index + 1),
                      );
                    }),
                  ),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Share your experience (optional)',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final result = await ReviewService.submitReview(
                      bookingId: booking.id,
                      workerId: workerId,
                      rating: rating,
                      comment: commentController.text.trim().isEmpty
                          ? null
                          : commentController.text.trim(),
                    );

                    if (!dialogContext.mounted) return;
                    Navigator.pop(dialogContext);

                    final message = result['status'] == 201
                        ? 'Review submitted. Thank you!'
                        : (result['message']?.toString() ??
                              'Failed to submit review');

                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );

    commentController.dispose();
  }

  Widget _buildSavedList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'No saved services yet',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}
