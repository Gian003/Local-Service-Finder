import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lsf/dataset/mock_service.dart';
import 'package:lsf/global%20variable/colors.dart';
import 'package:lsf/screens/roles/user-ui/service%20details/service_details_screen.dart';
import 'package:lsf/templates/searh_bar.dart';
import 'package:lsf/templates/service%20card/service_card.dart';
import 'package:lsf/templates/service%20card/service_model.dart';

class ExploreScreen extends StatefulWidget {
  final String? initialCategory;

  const ExploreScreen({super.key, this.initialCategory});

  @override
  ExploreScreenState createState() => ExploreScreenState();
}

class ExploreScreenState extends State<ExploreScreen> {
  //Searchbar variables
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  late List<ServiceModel> _serviceList;
  late List<ServiceModel> _fullServiceList;

  String _selectedFilter = 'Popular';
  List<String> _selectedCategories = [];

  final List<String> _filterOptions = [
    'Popular',
    'Newest',
    'Most Expensive',
    'Lowest Price',
  ];

  @override
  void initState() {
    super.initState();
    _fullServiceList = List.from(MockService.getServices());
    _serviceList = List.from(_fullServiceList);

    if (widget.initialCategory != null) {
      _selectedCategories = [widget.initialCategory!];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _applyFiltering();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFiltering() {
    List<ServiceModel> result = List.from(_fullServiceList);

    //Apply search filter
    if (_searchQuery.isNotEmpty) {
      result = result
          .where(
            (sort) =>
                sort.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                sort.workerName.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    //Apply category filter
    if (_selectedCategories.isNotEmpty) {
      result = result
          .where((sort) => _selectedCategories.contains(sort.category))
          .toList();
    }

    //Apply sort filter
    setState(() {
      switch (_selectedFilter) {
        case 'Popular':
          result.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
          break;
        case 'Newest':
          result.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
          break;
        case 'Most Expensive':
          result.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'Lowest Price':
          result.sort((a, b) => a.price.compareTo(b.price));
          break;
      }

      _serviceList = result;
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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

                  Text('Category'),

                  const SizedBox(height: 5),

                  Wrap(
                    spacing: 8,
                    children:
                        [
                          'cleaning',
                          'plumbing',
                          'repair',
                          'electrician',
                          'roofing',
                        ].map((category) {
                          final isSelected = _selectedCategories.contains(
                            category,
                          );

                          return FilterChip(
                            label: Text(category),
                            selected: isSelected,
                            selectedColor: AppColors.primaryColor.withValues(
                              alpha: 0.2,
                            ),
                            onSelected: (value) {
                              setModalState(() {
                                if (value) {
                                  _selectedCategories.add(category);
                                } else {
                                  _selectedCategories.remove(category);
                                }
                              });
                            },
                          );
                        }).toList(),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => {
                        Navigator.pop(context),
                        _applyFiltering(),
                      },
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
                    _applyFiltering();
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
              Center(
                child: Text(
                  'Explore',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 48),

              _buildSearchBar(),

              const SizedBox(height: 15),

              _buildFilterRow(),

              const SizedBox(height: 15),

              _serviceList.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Text(
                        'No Services Found',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _serviceList.length,
                      itemBuilder: (context, index) {
                        return ServiceCard(
                          serviceModel: _serviceList[index],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ServiceDetailsScreen(
                                  serviceModel: _serviceList[index],
                                ),
                              ),
                            );
                          },
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
          _applyFiltering();
        });
      },
      onClear: () {
        setState(() {
          _searchQuery = '';
          _searchController.clear();
          _applyFiltering();
        });
      },
    );
  }
}
