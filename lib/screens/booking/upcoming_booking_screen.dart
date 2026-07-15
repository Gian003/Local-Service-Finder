import 'package:flutter/material.dart';
import 'package:lsf/global%20variable/colors.dart';
import 'package:lsf/models/booking_model.dart';
import 'package:lsf/screens/booking/tracking_screen.dart';
import 'package:lsf/services/api_service.dart';
import 'package:lsf/templates/service%20card/service_model.dart';
import 'package:lsf/widgets/app_map.dart';

class UpcomingBookingScreen extends StatefulWidget {
  final BookingModel booking;
  final ServiceModel? serviceModel;

  const UpcomingBookingScreen({
    super.key,
    required this.booking,
    this.serviceModel,
  });

  @override
  State<UpcomingBookingScreen> createState() => _UpcomingBookingScreenState();
}

class _UpcomingBookingScreenState extends State<UpcomingBookingScreen> {
  void _showCancelDialog() {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Cancel Booking',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to cancel this booking?',
          style: TextStyle(fontFamily: 'Montserrat'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              final response = await ApiService.putRequest(
                'bookings/${widget.booking.id}/cancel',
                {},
                auth: true,
              );

              if (!mounted) return;

              if (response.statusCode == 200) {
                navigator.pop();
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Booking cancelled'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Failed to cancel booking. Please try again.'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Text(
          'Upcoming Booking',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.secondaryColor,
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Booking details card
            _buildBookingDetailsCard(),

            const SizedBox(height: 16),

            // Map card
            _buildMapCard(),

            const SizedBox(height: 16),

            // Service + price card
            _buildServiceCard(),

            const SizedBox(height: 24),

            // Cancel button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showCancelDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Cancel Booking',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  label: 'Service:',
                  value: widget.booking.serviceName,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  label: 'Date:',
                  value: widget.booking.date,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  label: 'Provider',
                  value: widget.booking.workerName,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  label: 'Time',
                  value: widget.booking.time,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMapCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Location header
          Row(
            children: [
              Text(
                'Location: ',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
              Expanded(
                child: Text(
                  widget.booking.address ?? 'Urdaneta City',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 13,
                  ),
                ),
              ),
              Icon(
                Icons.edit_outlined,
                size: 18,
                color: AppColors.secondaryColor,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Mini map — non-interactive
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 150,
              child: AppMap(
                latitude: widget.booking.latitude ?? 15.9754,
                longitude: widget.booking.longitude ?? 120.5720,
                zoom: 15,
                interactive: false, // mini map, no touch
                showPin: true,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Need Help?',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TrackingScreen(
                          booking: widget.booking,
                          serviceModel: widget.serviceModel,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Track',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Service',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          Text(
            widget.booking.serviceName,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Price',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                widget.booking.totalPrice.toStringAsFixed(0),
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
