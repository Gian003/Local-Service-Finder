import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({super.key});

  @override
  SplashScreenWrapperState createState() => SplashScreenWrapperState();
}

class SplashScreenWrapperState extends State<SplashScreenWrapper> {
  bool _hasError = false;
  String _errorMessage = '';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Call initialization after widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    try {
      // Simulate some initialization time
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _navigateBasedOnAuth();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Initialization error: $e');
      }
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Initialization failed: ${e.toString()}';
          _isInitialized = true;
        });
      }
    }
  }

  void _navigateBasedOnAuth() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, '/onBoarding');
    });
  }

  void _retryInitializeApp() {
    setState(() {
      _hasError = false;
      _errorMessage = '';
    });
    _initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialized && !_hasError) {
      return Container();
    }

    return SplashScreen(
      hasError: _hasError,
      errorMessage: _errorMessage,
      onRetry: _retryInitializeApp,
    );
  }
}

class SplashScreen extends StatelessWidget {
  final bool hasError;
  final String errorMessage;
  final VoidCallback? onRetry;

  const SplashScreen({
    super.key,
    this.hasError = false,
    this.errorMessage = '',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLogo(),
              const SizedBox(height: 30),
              if (hasError) ..._buildErrorState() else ..._buildLoadingState(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 1),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.9 + (0.1 * value), // Scale from 0.9 to 1.0
            child: Image.asset(
              'assets/images/logo.png',
              width: 200,
              height: 200,
              filterQuality: FilterQuality.high,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.image, size: 80, color: Colors.grey),
                );
              },
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildLoadingState() {
    return [
      // Smooth Loading indicator
      TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(seconds: 1),
        builder: (context, value, child) {
          return SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
              backgroundColor: Colors.grey[300],
            ),
          );
        },
      ),
    ];
  }

  List<Widget> _buildErrorState() {
    return [
      const Icon(Icons.error_outline, size: 50, color: Colors.red),
      const SizedBox(height: 15),
      Text(
        'Oops! Something went wrong.',
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 15,
          fontWeight: FontWeight.normal,
          color: Colors.grey[700],
        ),
      ),
      const SizedBox(height: 10),
      Text(
        errorMessage,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      const SizedBox(height: 20),
      ElevatedButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
        label: const Text(
          'Retry',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 15,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E2F2B),
          foregroundColor: Colors.white,
        ),
      ),
    ];
  }
}
