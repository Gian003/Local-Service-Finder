import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:lsf/config/app_config.dart';
import 'package:lsf/screens/roles/user-ui/user_bottom_navigation.dart';
import 'package:lsf/screens/roles/worker-ui/worker_bottom_navigation.dart';
import 'package:lsf/screens/verification/auth_otp_email.dart';
import 'package:lsf/screens/authentication/change_password.dart';
import 'package:lsf/screens/authentication/forgot_password.dart';
import 'package:lsf/services/navigation_service.dart';

import 'screens/splash_screen.dart';
import 'package:lsf/screens/on_boarding_screen.dart';
import 'package:lsf/screens/authentication/login_screen.dart';
import 'package:lsf/screens/authentication/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Stripe.publishableKey = AppConfig.stripePublishableKey;
  await Stripe.instance.applySettings();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Service Finder',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(47, 88, 153, 100),
        ),
        useMaterial3: true,
      ),
      home: SplashScreenWrapper(),
      routes: {
        '/onBoarding': (context) => const OnBoardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => const UserBottomNavigation(),
        '/verify': (context) => const AuthOtpEmail(),
        '/forgot-password': (context) => const ForgotPassword(),
        '/change-password': (context) => const ChangePassword(),

        // Worker routes
        '/worker-home': (context) => const WorkerBottomNavigation(),
      },
    );
  }
}
