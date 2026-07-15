import 'package:flutter/material.dart';
import 'package:lsf/global%20variable/colors.dart';
import 'package:lsf/models/booking_model.dart';
import 'package:lsf/screens/roles/user-ui/navigation/chat/chat_screen.dart';
import 'package:lsf/screens/roles/user-ui/navigation/profile/profile_screen.dart';
import 'package:lsf/screens/roles/user-ui/service%20details/service_details_screen.dart';
import 'package:lsf/templates/service%20card/service_model.dart';
import 'package:lsf/widgets/app_map.dart';

class TrackingScreen extends StatefulWidget {
  final BookingModel booking;
  final ServiceModel? serviceModel;

  const TrackingScreen({super.key, required this.booking, this.serviceModel});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full screen interactive map
          AppMap(
            latitude: widget.booking.latitude ?? 15.9754,
            longitude: widget.booking.longitude ?? 120.5720,
            zoom: 15,
            interactive: true, // full screen, allow touch
            showPin: true,
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
          ),

          // Title
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  'Tracking Detail',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryColor,
                  ),
                ),
              ),
            ),
          ),

          // Bottom worker card
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom,
            left: 0,
            right: 0,
            child: _buildWorkerCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkerCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Worker info row
          Row(
            children: [
              // Worker avatar
              CircleAvatar(
                radius: 28,
                backgroundImage: widget.booking.workerImage != null
                    ? NetworkImage(widget.booking.workerImage!)
                    : null,
                backgroundColor: Colors.grey[200],
                child: widget.booking.workerImage == null
                    ? const Icon(Icons.person, size: 28)
                    : null,
              ),

              const SizedBox(width: 12),

              // Worker name + service
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.booking.workerName,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      widget.booking.serviceName,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Profile button
              _buildActionButton(
                icon: Icons.person_outline,
                onTap: () {
                  if (widget.serviceModel != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ServiceDetailsScreen(
                          serviceModel: widget.serviceModel!,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Service details not available'),
                      ),
                    );
                  }
                },
              ),

              // Chat button
              _buildActionButton(
                icon: Icons.chat_bubble_outline,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        workerId: widget.booking.workerId ?? 1,
                        workerName: widget.booking.workerName,
                        workerImage: widget.booking.workerImage,
                      ),
                    ),
                  );
                },
              ),

              // Call button
              _buildActionButton(icon: Icons.phone_outlined, onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primaryColor, size: 22),
      ),
    );
  }
}
