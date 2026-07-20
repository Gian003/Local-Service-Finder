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
      case 'accepted':
        return Colors.orange;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get _statusLabel {
    if (bookmark.status.isEmpty) return 'Unknown';
    return bookmark.status[0].toUpperCase() + bookmark.status.substring(1);
  }

  //Date label per status
  String get _dateLabel {
    final date = bookmark.date;
    if (date == null) return 'Date unavailable';

    final formatted = '${date.day}/${date.month}/${date.year}'
        '${bookmark.time.isNotEmpty ? ' · ${bookmark.time}' : ''}';

    switch (bookmark.status) {
      case 'completed':
        return 'Completed on $formatted';
      case 'cancelled':
      case 'rejected':
        return 'Cancelled on $formatted';
      default:
        return 'Scheduled for $formatted';
    }
  }

  String get _categoryLabel {
    final type = bookmark.serviceType;
    if (type.isEmpty) return 'Service';
    return type[0].toUpperCase() + type.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: bookmark.imageUrl.isNotEmpty
                  ? Image.network(
                      bookmark.imageUrl,
                      width: 84,
                      height: 84,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _imageFallback(),
                    )
                  : _imageFallback(),
            ),

            const SizedBox(width: 12),

            //Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          bookmark.serviceName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _statusLabel,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 3),

                  Text(
                    _categoryLabel,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondaryColor,
                    ),
                  ),

                  const SizedBox(height: 6),

                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 11),
                      children: [
                        TextSpan(
                          text: 'Provider: ',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        TextSpan(
                          text: bookmark.providerName,
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _dateLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      if (bookmark.price > 0)
                        Text(
                          '₱${bookmark.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      width: 84,
      height: 84,
      color: Colors.grey.shade100,
      child: Icon(Icons.home_repair_service, color: Colors.grey.shade400, size: 32),
    );
  }
}
