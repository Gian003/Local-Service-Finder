import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'package:lsffend/screens/on_boarding_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Service Finder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(47, 88, 153, 100),
        ),
      ),
      home: SplashScreenWrapper(),
      routes: {'/onBoarding': (context) => const OnBoardingScreen()},
    );
  }
}
