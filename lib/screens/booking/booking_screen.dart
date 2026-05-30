import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lsf/config/app_config.dart';
import 'package:lsf/dataset/mock_service.dart';
import 'package:lsf/global%20variable/colors.dart';
import 'package:lsf/models/booking_model.dart';
import 'package:lsf/screens/roles/user-ui/navigation/bookmark/bookmark_screen.dart';
import 'package:lsf/services/api_service.dart';
import 'package:lsf/services/booking_service.dart';
import 'package:lsf/services/response_handler.dart';
import 'package:lsf/templates/service%20card/service_model.dart';

class BookingScreen extends StatefulWidget {
  final ServiceModel service;

  const BookingScreen({super.key, required this.service});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _currentStep = 0; // 0=Date&Time, 1=Address, 2=Payment

  // Step 1 state
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTime;
  final List<String> _timeSlots = [
    '07:00 AM',
    '08:00 AM',
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
  ];

  // Step 2 state
  Map<String, dynamic>? _selectedAddress;
  final List<Map<String, dynamic>> _addresses = [];

  // Step 3 state
  String? _selectedPayment;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'id': 'cash', 'label': 'Cash Payment', 'icon': '💵'},
    {'id': 'paypal', 'label': 'PayPal', 'icon': '🅿️'},
    {'id': 'google_pay', 'label': 'Google Pay', 'icon': '🔵'},
    {'id': 'card', 'label': 'Credit/Debit Card', 'icon': '💳'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  void _saveAddress(String label, String address, String city) async {
    final response = await ApiService.postRequest('addresses', {
      'label': label,
      'address': address,
      'city': city,
      'is_default': false,
    }, auth: true);

    if (response.statusCode == 201) {
      final data = ResponseHandler.parseJson(response.body);
      setState(() {
        _addresses.add(data['address']);
      });
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to save address')));
      debugPrint('Failed to save address: ${response.statusCode}');
    }
  }

  void _fetchAddresses() async {
    final response = await ApiService.getRequest('addresses', auth: true);
    if (response.statusCode == 200) {
      final List<dynamic> data = ResponseHandler.parseJsonArray(response.body);
      setState(() {
        _addresses.clear();
        _addresses.addAll(data.cast<Map<String, dynamic>>());
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch addresses')),
      );
      debugPrint('Failed to fetch addresses: ${response.statusCode}');
    }
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
          'Booking',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.secondaryColor,
          ),
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [
          // Step indicator
          _buildStepIndicator(),

          const SizedBox(height: 20),

          // Step content
          Expanded(
            child: _currentStep == 0
                ? _buildDateTimeStep()
                : _currentStep == 1
                ? _buildAddressStep()
                : _buildPaymentStep(),
          ),

          // Bottom buttons
          _buildBottomButtons(),
        ],
      ),
    );
  }

  // Step indicator
  Widget _buildStepIndicator() {
    final steps = ['Date & Time', 'Address', 'Payment'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isDone = index < _currentStep;
          final isActive = index == _currentStep;
          return Expanded(
            child: Row(
              children: [
                // Circle
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isDone || isActive
                        ? AppColors.primaryColor
                        : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isActive ? Colors.white : Colors.grey[600],
                            ),
                          ),
                  ),
                ),

                const SizedBox(width: 4),

                // Label
                Expanded(
                  child: Text(
                    steps[index],
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 11,
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isActive ? Colors.black : Colors.grey[500],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Connector line
                if (index < steps.length - 1)
                  Container(width: 10, height: 1, color: Colors.grey[300]),
              ],
            ),
          );
        }),
      ),
    );
  }

  // STEP 1: Date & Time
  Widget _buildDateTimeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Date:',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 12),

          // Calendar
          _buildCalendar(),

          const SizedBox(height: 20),

          const Text(
            'Select Time:',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 12),

          // Time slots
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _timeSlots.length,
              itemBuilder: (context, index) {
                final slot = _timeSlots[index];
                final isSelected = _selectedTime == slot;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTime = slot),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryColor
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      slot,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final firstDayOfMonth = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      1,
    );
    final daysInMonth = DateTime(
      _selectedDate.year,
      _selectedDate.month + 1,
      0,
    ).day;
    // Monday = 1, so offset = weekday - 1
    final startOffset = firstDayOfMonth.weekday - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Month navigation
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() {
                  _selectedDate = DateTime(
                    _selectedDate.year,
                    _selectedDate.month - 1,
                    1,
                  );
                }),
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  '${_monthName(_selectedDate.month)} ${_selectedDate.year}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() {
                  _selectedDate = DateTime(
                    _selectedDate.year,
                    _selectedDate.month + 1,
                    1,
                  );
                }),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),

          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']
                .map(
                  (day) => SizedBox(
                    width: 36,
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 8),

          // Day grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
            ),
            itemCount: startOffset + daysInMonth,
            itemBuilder: (context, index) {
              if (index < startOffset) return const SizedBox();

              final day = index - startOffset + 1;
              final date = DateTime(
                _selectedDate.year,
                _selectedDate.month,
                day,
              );
              final isSelected =
                  date.day == _selectedDate.day &&
                  date.month == _selectedDate.month &&
                  date.year == _selectedDate.year;
              final isPast = date.isBefore(
                DateTime.now().subtract(const Duration(days: 1)),
              );

              return GestureDetector(
                onTap: isPast
                    ? null
                    : () => setState(() => _selectedDate = date),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryColor
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                        color: isSelected
                            ? Colors.white
                            : isPast
                            ? Colors.grey[300]
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month];
  }

  // STEP 2: Address + Service Summary
  Widget _buildAddressStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Address',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 12),

          // Add new address button
          GestureDetector(
            onTap: _showAddAddressSheet,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Add new Address',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Saved addresses
          ..._addresses.map((addr) {
            final isSelected = _selectedAddress?['id'] == addr['id'];
            return GestureDetector(
              onTap: () => setState(() => _selectedAddress = addr),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryColor
                        : Colors.grey[200]!,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      addr['label'],
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      addr['address'],
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? AppColors.primaryColor
                                : Colors.transparent,
                            border: Border.all(color: AppColors.primaryColor),
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () async {},
                          child: Text(
                            'Edit',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: AppColors.secondaryColor,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () async {},
                          child: const Text(
                            'Delete',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.red,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 16),

          // Service details
          const Text(
            'Service Details',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildDetailRow('Category', widget.service.category ?? ''),
                _buildDetailRow('Service', widget.service.title),
                _buildDetailRow('Service Provider', widget.service.workerName),
                _buildDetailRow(
                  'Date and Time',
                  '${_selectedDate.day}-${_selectedDate.month}-'
                      '${_selectedDate.year}/${_selectedTime ?? ''}',
                ),
                _buildDetailRow('Working Hours', '2 Hours'),
                _buildDetailRow(
                  'Total Amount',
                  '₱ ${widget.service.price.toStringAsFixed(0)}',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Apply coupon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.discount_outlined, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Apply Coupon',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Payment details
          const Text(
            'Payment Details',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 8),

          _buildDetailRow('Tips (Helpers)', '₱ 100'),
          _buildDetailRow('Coupon Discount', '₱ 200'),

          const Divider(),

          _buildDetailRow(
            'Total',
            '₱ ${(widget.service.price + 100 - 200).toStringAsFixed(0)}',
            isBold: true,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddAddressSheet() {
    final labelController = TextEditingController();
    final addressController = TextEditingController();
    final cityController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add New Address',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: labelController,
              decoration: InputDecoration(
                labelText: 'Label (e.g. Home, Work)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: 'Full Address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: cityController,
              decoration: InputDecoration(
                labelText: 'City',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (labelController.text.isEmpty ||
                      addressController.text.isEmpty) {
                    return;
                  }
                  _saveAddress(
                    labelController.text,
                    addressController.text,
                    cityController.text,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Save Address',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 3: Payment
  Widget _buildPaymentStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose Your Payment Methods',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 16),

          ..._paymentMethods.map((method) {
            final isSelected = _selectedPayment == method['id'];
            return GestureDetector(
              onTap: () => setState(() => _selectedPayment = method['id']),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryColor
                        : Colors.grey[200]!,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(method['icon'], style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        method['label'],
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryColor
                              : Colors.grey[400]!,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Bottom buttons
  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Step 2 shows Make Your Payment button
          if (_currentStep == 1)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedAddress == null
                    ? null
                    : () {
                        setState(() => _currentStep = 2);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Make Your Payment',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            Row(
              children: [
                // Reset / Back button
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _currentStep -= 1),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Reset',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                if (_currentStep > 0) const SizedBox(width: 12),

                // Next / Confirm button
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleNextButton,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _currentStep == 2 ? 'Confirm' : 'Next',
                            style: const TextStyle(
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
        ],
      ),
    );
  }

  Future<int?> _ensureAddressExists() async {
    if (_selectedAddress == null) return null;

    // Try to create address in DB
    final response = await ApiService.postRequest('addresses', {
      'label': _selectedAddress!['label'] ?? 'Home',
      'address': _selectedAddress!['address'] ?? 'Urdaneta City',
      'city': _selectedAddress!['city'] ?? 'Pangasinan',
    }, auth: true);

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['address']['id'];
    }
    return null;
  }

  Future<void> _handleNextButton() async {
    // Step 1 validation
    if (_currentStep == 0) {
      if (_selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a time slot')),
        );
        return;
      }
      setState(() => _currentStep = 1);
      return;
    }

    // Step 3 — Confirm & Pay
    if (_currentStep == 2) {
      final token = await ApiService.getToken();
      debugPrint('Token before booking: $token');

      if (!mounted) return;

      if (token == null && !AppConfig.offlineMode) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expired. Please login again.'),
            backgroundColor: Colors.red,
          ),
        );
        // Redirect to login
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }
      if (_selectedPayment == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a payment method')),
        );
        return;
      }

      setState(() => _isLoading = true);

      if (AppConfig.offlineMode) {
        await Future.delayed(const Duration(seconds: 1));

        final newBooking = BookingModel(
          id: DateTime.now().millisecondsSinceEpoch,
          serviceName: widget.service.title,
          workerName: widget.service.workerName,
          workerImage: widget.service.workerImage,
          date:
              '${_selectedDate.day}-${_selectedDate.month}-${_selectedDate.year}',
          time: _selectedTime ?? '',
          totalPrice: widget.service.price,
          status: 'upcoming',
          address: _selectedAddress?['address'] ?? 'Urdaneta City',
          latitude: 15.9754,
          longitude: 120.5720,
          workerId: widget.service.workerId ?? 1,
        );

        MockService.addBooking(newBooking);

        setState(() => _isLoading = false);
        if (!mounted) return;
        _showSuccessDialog();
        return;
      }

      // Online — Stripe flow
      if (_selectedPayment == 'card') {
        final amountInCentavos = (widget.service.price * 100).toInt();
        final clientSecret = await BookingService.createPaymentIntent(
          amount: amountInCentavos,
          serviceId: widget.service.id ?? 1,
        );

        if (!mounted) return;

        if (clientSecret == null) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Payment setup failed')));
          return;
        }

        final success = await BookingService.processStripePayment(
          clientSecret: clientSecret,
        );

        if (!mounted) return;

        if (!success) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Payment cancelled')));
          return;
        }
      }

      String _convertTo24Hour(String time12h) {
        final parts = time12h.split(' ');
        final timePart = parts[0];
        final period = parts[1];

        var [hours, minutes] = timePart.split(':');
        int hour = int.parse(hours);

        if (period == 'PM' && hour != 12) hour += 12;
        if (period == 'AM' && hour == 12) hour = 0;

        return '${hour.toString().padLeft(2, '0')}:$minutes:00';
      }

      // Confirm booking in DB
      final scheduled =
          '${_selectedDate.year.toString()}-'
          '${_selectedDate.month.toString().padLeft(2, '0')}-'
          '${_selectedDate.day.toString().padLeft(2, '0')} '
          '${_convertTo24Hour(_selectedTime ?? '')}';

      final addressId = await _ensureAddressExists();

      final booked = await BookingService.confirmBooking(
        serviceId: widget.service.id ?? 1,
        workerId: widget.service.workerId ?? 1,
        addressId: addressId ?? 1,
        scheduledAt: scheduled,
        totalPrice: widget.service.price,
        paymentMethod: _selectedPayment!,
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (booked) _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'Booking Confirmed!',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your booking is pending worker acceptance.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // close booking screen
                Navigator.pop(context); // close detail screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Go to Home',
                style: TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
