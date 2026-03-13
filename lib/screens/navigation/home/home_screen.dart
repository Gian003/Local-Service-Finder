import 'dart:async';

import 'package:flutter/material.dart' hide ImageInfo;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lsffend/dataset/dummy_data.dart';
import 'package:lsffend/global%20variable/colors.dart';
import 'package:lsffend/services/service_services.dart';
import 'package:lsffend/templates/category.dart';
import 'package:lsffend/templates/hero_layout_card.dart';
import 'package:lsffend/templates/searh_bar.dart';
import 'package:lsffend/templates/service%20card/service_card.dart';
import 'package:lsffend/templates/service%20card/service_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //Searchbar variables
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  //Carousel variables
  final CarouselController _carouselController = CarouselController(
    initialItem: 1,
  );
  Timer? _autoScrollTimer;
  int _currentCarouselIndex = 0;
  final int _carouselItemCount = ImageInfo.values.length;

  //Service List
  List<ServiceModel> _serviceList = [];
  bool _isLoading = true;

  Future<void> _loadServices() async {
    final services = await ServiceServices.getAllServices();
    setState(() {
      _serviceList = services;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadServices();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;

      if (_carouselController.hasClients) {
        _currentCarouselIndex =
            (_currentCarouselIndex + 1) % _carouselItemCount;
        _carouselController.animateToItem(_currentCarouselIndex);
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _searchController.dispose();
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              //Header
              SizedBox(
                height: 135,
                width: double.infinity,

                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'What service do you need?',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondaryColor,
                            ),
                          ),
                        ),

                        const SizedBox(width: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: FaIcon(
                                FontAwesomeIcons.cartFlatbed,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),

                            IconButton(
                              onPressed: () {},
                              icon: FaIcon(
                                FontAwesomeIcons.bell,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    _buildSearchBar(),
                  ],
                ),
              ),

              //Body

              //Carousel View
              SizedBox(
                height: 200,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollStartNotification) {
                      _autoScrollTimer?.cancel();
                    } else if (notification is ScrollEndNotification) {
                      _startAutoScroll();
                    }
                    return false;
                  },
                  child: CarouselView.weighted(
                    controller: _carouselController,
                    itemSnapping: true,
                    flexWeights: const <int>[7],
                    children: ImageInfo.values.map((ImageInfo image) {
                      return HeroLayoutCard(imageInfo: image);
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              //Category View
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Services',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'View all',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            color: AppColors.secondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ConstrainedBox(
                  //   constraints: const BoxConstraints(maxHeight: 100),
                  //   child: CarouselView.weighted(
                  //     flexWeights: const <int>[3, 3, 3],
                  //     consumeMaxWeight: false,
                  //     children: CategoryInfo.values.map((CategoryInfo info) {
                  //       return ColoredBox(
                  //         color: info.backgroundColor,
                  //         child: Center(
                  //           child: Column(
                  //             mainAxisAlignment: MainAxisAlignment.center,
                  //             children: <Widget>[
                  //               Icon(info.icon, color: info.color, size: 32),

                  //               Text(
                  //                 info.label,
                  //                 style: TextStyle(
                  //                   fontWeight: FontWeight.bold,
                  //                 ),
                  //                 overflow: TextOverflow.clip,
                  //                 softWrap: false,
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //       );
                  //     }).toList(),
                  //   ),
                  // ),
                  SizedBox(
                    height: 80,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        buildCategoryIcon(Icons.cleaning_services),
                        buildCategoryIcon(Icons.build),
                        buildCategoryIcon(Icons.local_laundry_service),
                        buildCategoryIcon(Icons.plumbing),
                        buildCategoryIcon(Icons.cleaning_services),
                        buildCategoryIcon(Icons.build),
                        buildCategoryIcon(Icons.local_laundry_service),
                        buildCategoryIcon(Icons.plumbing),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              //Recommended View
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recommended',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'View all',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            color: AppColors.secondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
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
