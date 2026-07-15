import 'package:flutter/material.dart';

/// Shown wherever a screen has fallen back to locally cached data because
/// the network request failed.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.amber[100],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.cloud_off, size: 16, color: Colors.amber[900]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "You're offline — showing saved data",
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12,
                color: Colors.amber[900],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
