import 'package:flutter/material.dart';
import 'package:lsf/screens/roles/user-ui/navigation/bookmark/bookmark_model.dart';
import 'package:lsf/global variable/colors.dart';

class BookmarkCard extends StatelessWidget {
  final BookmarkModel bookmark;
  final VoidCallback? onTap;

  const BookmarkCard({super.key, required this.bookmark, this.onTap});

  Color get _statusColor {
    switch (bookmark.status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  //Date label per status
  String get _dateLabel {
    switch (bookmark.status) {
      case 'completed':
        return 'Upcoming on ${bookmark.date.day}/${bookmark.date.month}/${bookmark.date.year}';
      case 'pending':
        return 'Upcoming on ${bookmark.date.day}/${bookmark.date.month}/${bookmark.date.year}';
      case 'cancelled':
        return 'Cancelled on ${bookmark.date.day}/${bookmark.date.month}/${bookmark.date.year}';
      default:
        return bookmark.date.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(12),
            right: Radius.circular(12),
          ),
          
        ),
        child: Row(
          children: [
            //Image
            ClipRRect(
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(12),
                right: Radius.circular(12),
              ),
              child: Image.network(
                bookmark.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 12),

            //Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bookmark.serviceType,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondaryColor,
                    ),
                  ),

                  Text(
                    bookmark.serviceName,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey[700],
                    ),
                  ),

                  const SizedBox(height: 2),

                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 11),
                      children: [
                        TextSpan(
                          text: 'Service Provider: ',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        TextSpan(
                          text: bookmark.providerName,
                          style: TextStyle(
                            color: AppColors.secondaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    _dateLabel,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 11,
                      color: _statusColor,
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
