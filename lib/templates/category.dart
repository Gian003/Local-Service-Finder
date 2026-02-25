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

Widget buildCategoryIcon(IconData icon) {
  return Padding(
    padding: const EdgeInsets.all(5.0),
    child: TextButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        iconSize: 30,
        minimumSize: Size(80, 80),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.horizontal(
            left: Radius.circular(5),
            right: Radius.circular(5),
          ),
          side: BorderSide(width: 1, color: Color.fromARGB(255, 216, 218, 220)),
        ),
      ),
      child: Icon(icon),
    ),
  );
}
