import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lsffend/dataset/dummy_data.dart';
import 'package:lsffend/global%20variable/colors.dart';
import 'package:lsffend/templates/searh_bar.dart';
import 'package:lsffend/templates/service%20card/service_card.dart';
import 'package:lsffend/templates/service%20card/service_model.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  ExploreScreenState createState() => ExploreScreenState();
}

class ExploreScreenState extends State<ExploreScreen> {
  //Searchbar variables
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  late List<ServiceModel> _serviceList;

  String _selectedFilter = 'Popular';

  final List<String> _filterOptions = [
    'Popular',
    'Newest',
    'Most Expensive',
    'Lowest Price',
  ];

  @override
  void initState() {
    super.initState();
    _serviceList = List.from(DummyData().serviceList);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFiltering() {
    setState(() {
      switch (_selectedFilter) {
        case 'Popular':
          DummyData().serviceList.sort(
            (a, b) => b.reviewCount.compareTo(a.reviewCount),
          );
          break;
        case 'Newest':
          // Sort by newest
          break;
        case 'Most Expensive':
          DummyData().serviceList.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'Lowest Price':
          DummyData().serviceList.sort((a, b) => a.price.compareTo(b.price));
          break;
      }
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Text('Catefory'),

              const SizedBox(height: 5),

              Wrap(
                spacing: 8,
                children: ['Cleaning', 'PLumbing', 'Repair', 'Laundry'].map((
                  category,
                ) {
                  return FilterChip(
                    label: Text(category),
                    onSelected: (value) {},
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.horizontal(
                        left: Radius.circular(10),
                        right: Radius.circular(10),
                      ),
                    ),
                  ),
                  child: Text(
                    'Apply',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          //Filter Button
          OutlinedButton.icon(
            onPressed: () {
              _showFilterBottomSheet();
            },
            icon: FaIcon(FontAwesomeIcons.sliders, size: 15),
            label: const Text(
              'Filter',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 15,
                fontWeight: FontWeight.normal,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              foregroundColor: Colors.black,
              side: BorderSide(color: Colors.grey, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.horizontal(
                  left: Radius.circular(10),
                  right: Radius.circular(10),
                ),
              ),
            ),
          ),

          const SizedBox(width: 15),

          //Sort Options Buttons
          ..._filterOptions.map((option) {
            final bool isSelected = _selectedFilter == option;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _selectedFilter = option;
                    _applyFiltering;
                  });
                },
                style: TextButton.styleFrom(
                  backgroundColor: isSelected
                      ? AppColors.primaryColor
                      : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.horizontal(
                      left: Radius.circular(10),
                      right: Radius.circular(10),
                    ),
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back),
                  ),

                  const SizedBox(width: 100),

                  Text(
                    'Explore',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondaryColor,
                    ),
                  ),
                ],
              ),

              _buildSearchBar(),

              const SizedBox(height: 15),

              _buildFilterRow(),

              const SizedBox(height: 15),

              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _serviceList.length,
                itemBuilder: (context, index) {
                  return ServiceCard(
                    serviceModel: _serviceList[index],
                    onTap: () {},
                    onBookMark: () {},
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return CustomSearchBar(
      controller: _searchController,
      hintText: 'Search for service...',
      onSearch: (query) {
        setState(() {
          _searchQuery = query;
        });
      },
      onClear: () {
        setState(() {
          _searchQuery = '';
          _searchController.clear();
        });
      },
    );
  }
}
