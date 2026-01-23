import 'package:flutter/material.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
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

  final int _currentPageIndex = 0;
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

  // void skipOnBoarding() {
  //   Navigator.pushNamed(context, '/home');
  // }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
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
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
