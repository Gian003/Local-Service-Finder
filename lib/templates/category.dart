import 'package:flutter/material.dart';

enum CategoryInfo {
  camera('Cameras', Icons.video_call, Colors.white, Color(0xffECEFFD)),
  lighting('Lighting', Icons.lightbulb, Colors.white, Color(0xffFAEEDF)),
  climate('Climate', Icons.thermostat, Colors.white, Color(0xffFAEDE7)),
  wifi('Wifi', Icons.wifi, Colors.white, Color(0xffE5F4E0)),
  media('Media', Icons.library_music, Colors.white, Color(0xffECEFFD)),
  security(
    'Security',
    Icons.crisis_alert,
    Color(0xff794C01),
    Color(0xffFAEEDF),
  ),
  safety(
    'Safety',
    Icons.medical_services,
    Color(0xff2251C5),
    Color(0xffECEFFD),
  ),
  more('', Icons.add, Color(0xff201D1C), Color(0xffE3DFD8));

  const CategoryInfo(this.label, this.icon, this.color, this.backgroundColor);
  final String label;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
}
