import 'package:flutter/material.dart';

class AppTextStyle {
  AppTextStyle._(); //prevent instantiation of this class

  static const TextStyle heading = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle subheading = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 18,
    fontWeight: FontWeight.normal,
  );
}
