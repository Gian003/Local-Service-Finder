import 'package:flutter/material.dart';
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
      ),
    );
  }
}
