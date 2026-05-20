import 'package:flutter/material.dart';

class HeroLayoutCard extends StatelessWidget {
  final ImageInfo imageInfo;

  const HeroLayoutCard({super.key, required this.imageInfo});

  @override
  Widget build(BuildContext context) {
    final double height = 200;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          'https://flutter.github.io/assets-for-api-docs/assets/material/${imageInfo.url}',
          fit: BoxFit.cover,
        ),

        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black54],
            ),
          ),
        ),

        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: height - 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  imageInfo.title,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 5),

                Text(
                  imageInfo.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

enum ImageInfo {
  image0(
    'Cleaning Service',
    '20% Off | Book Now',
    'content_based_color_scheme_1.png',
  ),
  image1(
    'Home Repair',
    '15% Off | Book Now',
    'content_based_color_scheme_2.png',
  ),
  image2(
    'Gardening Service',
    '10% Off | Book Now',
    'content_based_color_scheme_3.png',
  ),
  image3(
    'Plumbing Service',
    '10% Off | Book Now',
    'content_based_color_scheme_4.png',
  ),
  image4(
    'Electrical Service',
    '10% Off | Book Now',
    'content_based_color_scheme_5.png',
  ),
  image5(
    'Painting Service',
    '10% Off | Book Now',
    'content_based_color_scheme_6.png',
  );

  const ImageInfo(this.title, this.subtitle, this.url);
  final String title;
  final String subtitle;
  final String url;
}
