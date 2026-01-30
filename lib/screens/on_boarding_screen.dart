import 'package:flutter/material.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  OnBoardingScreenState createState() => OnBoardingScreenState();
}

class OnBoardingScreenState extends State<OnBoardingScreen> {
  final List<OnBoardingPage> _pages = [
    OnBoardingPage(
      imagePath: 'assets/images/onboarding1.png',
      title: 'Welcome to LSF',
      description: 'We provide professional service at a friendly price.',
    ),
    OnBoardingPage(
      imagePath: 'assets/images/onboarding2.png',
      title: 'Professional Service',
      description:
          'Deliver expert service with reliability and care to every home',
    ),
    OnBoardingPage(
      imagePath: 'assets/images/onboarding3.png',
      title: 'Easy Booking',
      description: 'Book your service, relax, and enjoy a spotless home!',
    ),
  ];

  int _currentPageIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  void _nextPage() {
    if (_currentPageIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPageIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnBoarding() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.centerRight,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _skipOnBoarding,
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(10),
                      right: Radius.circular(10),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Skip',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(width: 10),

                          Icon(Icons.skip_next_sharp, color: Color(0xFF2E2F2B)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            //PageView for onboarding pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  // Update the current page index when the page changes
                  setState(() {
                    _currentPageIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return OnBoardingPageWidget(page: _pages[index]);
                },
              ),
            ),

            //Row Widget to display the navigation buttons
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //Previous Button shows only if not on the first page
                    if (_currentPageIndex > 0)
                      IconButton(
                        onPressed: _previousPage,
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Color(0xFF2E2F2B),
                        ),
                      )
                    else
                      SizedBox(width: 50),

                    //Pagiantion Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pages.length, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          width: index == _currentPageIndex ? 20 : 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: index == _currentPageIndex
                                ? const Color(0xFF2F5899)
                                : Colors.grey[300],
                            borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(5),
                              right: Radius.circular(5),
                            ),
                          ),
                        );
                      }),
                    ),

                    //Next Button shows only if not on the last page
                    if (_currentPageIndex < _pages.length - 1)
                      IconButton(
                        onPressed: _nextPage,
                        icon: Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFF2E2F2B),
                        ),
                      )
                    else
                      SizedBox(width: 50),
                  ],
                ),

                const SizedBox(height: 15),

                //Continue Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F5899),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.horizontal(
                          left: Radius.circular(10),
                          right: Radius.circular(10),
                        ),
                      ),
                    ),
                    child: Text(
                      _currentPageIndex < _pages.length - 1
                          ? 'Next'
                          : 'Get Started',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OnBoardingPage {
  final String imagePath;
  final String title;
  final String description;

  const OnBoardingPage({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}

class OnBoardingPageWidget extends StatelessWidget {
  final OnBoardingPage page;

  const OnBoardingPageWidget({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Image.asset(
              page.imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey[200],
                  child: Icon(Icons.image, size: 100, color: Colors.grey[400]),
                );
              },
            ),
          ),

          const SizedBox(height: 30),

          Text(
            page.title,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 15),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              page.description,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
