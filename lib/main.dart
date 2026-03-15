import 'package:flutter/material.dart';
import 'package:lsffend/main_wrapper.dart';
import 'package:lsffend/screens/verification/auth_otp_email.dart';
import 'package:lsffend/screens/navigation/profile/change_password.dart';
import 'package:lsffend/screens/navigation/profile/forgot_password.dart';

import 'screens/splash_screen.dart';
import 'package:lsffend/screens/on_boarding_screen.dart';
import 'package:lsffend/screens/authentication/login_screen.dart';
import 'package:lsffend/screens/authentication/register_screen.dart';
import 'package:lsffend/screens/navigation/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Service Finder',
      debugShowCheckedModeBanner: false,
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
        '/home': (context) => const MainWrapper(),
        '/verify': (context) => const AuthOtpEmail(),
        '/forgot-password': (context) => const ForgotPassword(),
        '/change-password': (context) => const ChangePassword(),
      },
    );
  }
}
