import 'package:flutter/material.dart';
import 'package:lsffend/dataset/mock_service.dart';
import 'package:lsffend/global%20variable/colors.dart';
import 'package:lsffend/screens/navigation/bookmark/bookmark_card.dart';
import 'package:lsffend/screens/navigation/bookmark/bookmark_model.dart';
import 'package:lsffend/screens/navigation/bookmark/bookmark_card.dart';
import 'package:lsffend/templates/service%20card/service_card.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => BookmarkScreenState();
}

class BookmarkScreenState extends State<BookmarkScreen> {
  String _selectedTab = 'Upcoming';

  final List<String> _tabs = ['Upcoming', 'Completed', 'Cancelled', 'Saved'];

  //Filter Bookmark by status
  List<BookmarkModel> get _filteredBookmarks {
    return MockService.getBookmarks()
        .where((bookmark) => bookmark.status == _selectedTab.toLowerCase())
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
        return BookmarkCard(bookmark: bookmarks[index], onTap: () {});
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
