import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lsf/global%20variable/colors.dart';
import 'package:lsf/services/api_service.dart';
import 'package:lsf/templates/service%20card/service_model.dart';

class WorkerServicesScreen extends StatefulWidget {
  const WorkerServicesScreen({super.key});

  @override
  WorkerServicesScreenState createState() => WorkerServicesScreenState();
}

class WorkerServicesScreenState extends State<WorkerServicesScreen> {
  List<ServiceModel> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    setState(() => _isLoading = true);
    try {
      final response =
          await ApiService.getRequest('worker-auth/my-services', auth: true);
      if (!mounted) return;
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> list =
            decoded is List ? decoded : (decoded['data'] ?? []);
        setState(() {
          _services = list
              .whereType<Map<String, dynamic>>()
              .map((json) => ServiceModel.fromJson(json))
              .toList();
        });
      }
    } catch (_) {
      // silently degrade
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddServiceSheet() {
    // Capture before async gaps inside the sheet callbacks
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final titleController = TextEditingController();
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'cleaning';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add New Service',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Service Title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Price (₱)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items:
                        ['cleaning', 'plumbing', 'repair', 'roofing', 'electrical']
                            .map((cat) => DropdownMenuItem(
                                  value: cat,
                                  child: Text(cat),
                                ))
                            .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => selectedCategory = val);
                      }
                    },
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.isEmpty ||
                            priceController.text.isEmpty) {
                          return;
                        }

                        Navigator.pop(modalContext);

                        final response = await ApiService.postRequest(
                          'worker-auth/my-services',
                          {
                            'title': titleController.text.trim(),
                            'price':
                                double.tryParse(priceController.text) ?? 0,
                            'description': descriptionController.text.trim(),
                            'category': selectedCategory,
                          },
                          auth: true,
                        );

                        if (!mounted) return;
                        if (response.statusCode == 201) {
                          _fetchServices();
                        } else {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                                content: Text('Failed to add service')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Add Service',
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
            );
          },
        );
      },
    );
  }

  void _deleteService(ServiceModel service) {
    // Capture before dialog and async gaps
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Delete Service',
          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete this service?',
          style: TextStyle(fontFamily: 'Montserrat'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              if (service.id == null) return;

              final response = await ApiService.deleteRequest(
                'worker-auth/my-services/${service.id}',
                auth: true,
              );

              if (!mounted) return;
              if (response.statusCode == 200 || response.statusCode == 204) {
                _fetchServices();
              } else {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('Failed to delete service')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'My Services',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showAddServiceSheet,
                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                  label: const Text(
                    'Add',
                    style: TextStyle(fontFamily: 'Montserrat', color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _services.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.briefcase,
                              size: 60,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No services yet\nTap Add to create one',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchServices,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _services.length,
                          itemBuilder: (context, index) {
                            return _buildServiceCard(_services[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(ServiceModel service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: service.imageUrl.isNotEmpty
                ? Image.network(
                    service.imageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported,
                          color: Colors.grey),
                    ),
                  )
                : Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey[200],
                    child: const Icon(Icons.build, color: Colors.grey),
                  ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.title,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  service.category ?? '',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '₱${service.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),

          Column(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.edit_outlined, size: 20),
                color: Colors.grey,
              ),
              IconButton(
                onPressed: () => _deleteService(service),
                icon: const Icon(Icons.delete_outline, size: 20),
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
