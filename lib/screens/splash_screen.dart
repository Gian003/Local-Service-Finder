import 'package:flutter/material.dart';

class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({super.key});

  @override
  SplashScreenWrapperState createState() => SplashScreenWrapperState();
}

class SplashScreenWrapperState extends State<SplashScreenWrapper> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
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
            children: [],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(seconds: 1),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.9 + (0.1 * value), // Scale from 0.9 to 1.0
            child: Image.asset(
              'assets/logo.png',
              width: 200,
              height: 200,
              filterQuality: FilterQuality.high,
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildLoadingState() {
    return [
      //Smooth Loading indcator
      TweenAnimationBuilder(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(seconds: 1),
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
      Icon(Icons.error_outline, size: 50, color: Colors.red),

      SizedBox(height: 15),

      Text(
        'Oops! Something went wrong.',
        style: TextStyle(
          fontFamily: 'MOntserrat',
          fontSize: 15,
          fontWeight: FontWeight.normal,
          color: Colors.grey[700],
        ),
      ),

      SizedBox(height: 20),

      ElevatedButton.icon(
        onPressed: onRetry,
        icon: Icon(Icons.refresh),
        label: Text(
          'Retry',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 15,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF2E2F2B),
          foregroundColor: Colors.white,
        ),
      ),
    ];
  }
}
