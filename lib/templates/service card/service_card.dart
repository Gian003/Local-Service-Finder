import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lsffend/global%20variable/colors.dart';
import 'package:lsffend/screens/roles/user-ui/service%20details/service_details_screen.dart';
import 'package:lsffend/templates/service%20card/service_model.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel serviceModel;
  final VoidCallback? onBookMark;

  const ServiceCard({
    super.key,
    required this.serviceModel,
    this.onBookMark, required Null Function() onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ServiceDetailsScreen(serviceModel: serviceModel)
          )
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(15),
            right: Radius.circular(15),
          ),
          border: BoxBorder.all(color: AppColors.widthColor, width: 1),
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
                width: 70,
                height: 90,
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
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'By ${serviceModel.workerName}',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Row(
                    children: [
                      Icon(
                        Icons.star_border,
                        color: AppColors.primaryColor,
                        size: 20,
                      ),

                      const SizedBox(width: 5),

                      Text(
                        '${serviceModel.rating} (${serviceModel.reviewCount} Reviews)',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 5),

                  Text(
                    '₱${serviceModel.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: onBookMark,
                  icon: Icon(Icons.bookmark_add, size: 30),
                ),

                const SizedBox(height: 25),

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
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}