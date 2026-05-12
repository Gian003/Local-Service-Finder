import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lsffend/dataset/mock_service.dart';
import 'package:lsffend/global%20variable/colors.dart';
import 'package:lsffend/models/booking_model.dart';
import 'package:lsffend/screens/booking/upcoming_booking_screen.dart';
import 'package:lsffend/screens/roles/user-ui/navigation/bookmark/bookmark_card.dart';
import 'package:lsffend/screens/roles/user-ui/navigation/bookmark/bookmark_model.dart';
import 'package:lsffend/services/api_service.dart';
import 'package:lsffend/templates/service%20card/service_card.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => BookmarkScreenState();
}

class BookmarkScreenState extends State<BookmarkScreen> {
  String _selectedTab = 'Upcoming';

  final List<String> _tabs = ['Upcoming', 'Completed', 'Cancelled', 'Saved'];

  // List<BookmarkModel> _filteredBookmarks = [];

  // @override
  // void initState() {
  //   super.initState();
  //   _loadBookings();
  // }

  // Future<void> _loadBookings() async {
  //   final response = await ApiService.getRequest('/bookings/user', auth: true);
  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body) as List;
  //     setState(() {
  //       _filteredBookmarks = data
  //           .map((json) => BookingModel.fromJson(json))
  //           .where((booking) => booking.status == _selectedTab.toLowerCase())
  //           .map(
  //             (booking) => BookmarkModel(
  //               id: booking.id,
  //               serviceType: 'Service',
  //               serviceName: booking.serviceName,
  //               providerName: booking.workerName,
  //               imageUrl: booking.workerImage ?? 'https://picsum.photos/200',
  //               date: DateTime.now(),
  //               status: booking.status,
  //             ),
  //           )
  //           .toList();
  //     });
  //   }
  // }

  //Filter Bookmark by status
  List<BookmarkModel> get _filteredBookmarks {
    return MockService.getBookings()
        .where((booking) => booking.status == _selectedTab.toLowerCase())
        .map(
          (booking) => BookmarkModel(
            id: booking.id,
            serviceType: 'Service',
            serviceName: booking.serviceName,
            providerName: booking.workerName,
            imageUrl: 'https://picsum.photos/200',
            date: DateTime.now(),
            status: booking.status,
          ),
        )
        .toList();
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
                const SizedBox(width: 50),
              ],
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
                      onTap: () {
                        setState(() {
                          _selectedTab = tab;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryColor
                              : Colors.transparent,
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

          //Content
          Expanded(
            child: Padding(
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
    final bookmarks = _filteredBookmarks;

    if (bookmarks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 60, color: Colors.grey[400]),

            const SizedBox(height: 12),

            Text(
              'Mo ${_selectedTab.toLowerCase()} bookings yet.',
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

    return ListView.builder(
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        return BookmarkCard(
          bookmark: bookmarks[index],
          onTap: () {
            if (bookmarks[index].status == 'upcoming') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UpcomingBookingScreen(
                    booking: BookingModel(
                      id: bookmarks[index].id,
                      serviceName: bookmarks[index].serviceName,
                      workerName: bookmarks[index].providerName,
                      date: '03-09-2025',
                      time: '9-11 AM',
                      totalPrice: 800,
                      status: 'upcoming',
                      address: 'Urdaneta City',
                      latitude: 15.9754,
                      longitude: 120.5720,
                    ),
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildSavedList() {
    final saved = MockService.getServices();

    if (saved.isEmpty) {
      return Center(
        child: Column(
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

    return ListView.builder(
      itemCount: saved.length,
      itemBuilder: (context, index) {
        return ServiceCard(
          serviceModel: saved[index],
          onTap: () {},
          onBookMark: () {},
        );
      },
    );
  }
}
