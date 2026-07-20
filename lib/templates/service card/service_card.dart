import 'package:flutter/material.dart';
import 'package:lsf/global%20variable/colors.dart';
import 'package:lsf/screens/roles/user-ui/service%20details/service_details_screen.dart';
import 'package:lsf/templates/service%20card/service_model.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel serviceModel;
  final VoidCallback? onBookMark;

  const ServiceCard({
    super.key,
    required this.serviceModel,
    this.onBookMark,
    required Null Function() onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ServiceDetailsScreen(serviceModel: serviceModel),
          ),
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
              child: serviceModel.imageUrl.isNotEmpty
                  ? Image.network(
                      serviceModel.imageUrl,
                      width: 70,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 70,
                        height: 90,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
                    )
                  : Container(
                      width: 70,
                      height: 90,
                      color: Colors.grey[200],
                      child: const Icon(Icons.build, color: Colors.grey),
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

                      Flexible(
                        child: Text(
                          '${serviceModel.rating} (${serviceModel.reviewCount} Reviews)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
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

            // Fixed width — without this, the column's natural size grows
            // or shrinks with the discount text ("5% Off" vs "100% Off"),
            // and once that plus the rest of the row exceeds the card's
            // width, the Row overflows. The amount varies by item, which is
            // exactly what showed up as inconsistent overflow while scrolling.
            SizedBox(
              width: 64,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: onBookMark,
                    icon: Icon(Icons.bookmark_add, size: 28),
                  ),

                  const SizedBox(height: 25),

                  if (serviceModel.discountPercent != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        '${serviceModel.discountPercent!.toInt()}% Off',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
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
