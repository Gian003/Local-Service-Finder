import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lsffend/global%20variable/colors.dart';
import 'package:lsffend/templates/service%20card/service_model.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel serviceModel;
  final VoidCallback? onTap;
  final VoidCallback? onBookMark;

  const ServiceCard({
    super.key,
    required this.serviceModel,
    this.onTap,
    this.onBookMark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(10),
            right: Radius.circular(10),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.8),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            //Image
            ClipRRect(
              borderRadius: BorderRadiusGeometry.horizontal(
                left: Radius.circular(10),
                right: Radius.circular(10),
              ),
              child: Image.network(
                serviceModel.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 10),

            //Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceModel.title,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    serviceModel.workerName,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.star,
                        color: Colors.black,
                        size: 10,
                      ),

                      const SizedBox(width: 5),

                      Text(
                        '${serviceModel.rating} (${serviceModel.reviewCount} Reviews)',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 10,
                          fontWeight: FontWeight.normal,
                        ),
                      ),

                      const SizedBox(width: 5),

                      Row(
                        children: [
                          Text(
                            '₱${serviceModel.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 10,
                              fontWeight: FontWeight.normal,
                            ),
                          ),

                          const Spacer(),

                          if (serviceModel.discountPercent != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.horizontal(
                                  left: Radius.circular(5),
                                  right: Radius.circular(5),
                                ),
                              ),
                              child: Text(
                                '${serviceModel.discountPercent!.toInt()}% Off',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),

                  Align(
                    alignment: AlignmentGeometry.topRight,
                    child: IconButton(
                      onPressed: onBookMark,
                      icon: FaIcon(FontAwesomeIcons.bookmark, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
