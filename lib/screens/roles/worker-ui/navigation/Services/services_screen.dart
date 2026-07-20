import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
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
  final ImagePicker _picker = ImagePicker();

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

  // Shared sheet for both adding a new service and editing an existing one —
  // pass [existing] to pre-fill the form and PATCH it instead of creating.
  void _showServiceFormSheet({ServiceModel? existing}) {
    final isEditing = existing != null;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final titleController = TextEditingController(text: existing?.title);
    final priceController = TextEditingController(
      text: existing != null ? existing.price.toStringAsFixed(0) : '',
    );
    final descriptionController =
        TextEditingController(text: existing?.description);
    String selectedCategory = existing?.category ?? 'cleaning';

    File? coverImageFile;
    List<File> galleryFiles = [];
    File? videoFile;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            Future<void> pickCover() async {
              final picked =
                  await _picker.pickImage(source: ImageSource.gallery);
              if (picked != null) {
                setModalState(() => coverImageFile = File(picked.path));
              }
            }

            Future<void> pickGallery() async {
              final picked = await _picker.pickMultiImage();
              if (picked.isNotEmpty) {
                setModalState(
                  () => galleryFiles = picked.map((x) => File(x.path)).toList(),
                );
              }
            }

            Future<void> pickVideo() async {
              final picked =
                  await _picker.pickVideo(source: ImageSource.gallery);
              if (picked != null) {
                setModalState(() => videoFile = File(picked.path));
              }
            }

            Future<void> submit() async {
              if (titleController.text.isEmpty ||
                  priceController.text.isEmpty) {
                return;
              }

              setModalState(() => isSaving = true);
              final modalNavigator = Navigator.of(modalContext);

              final fields = {
                'title': titleController.text.trim(),
                'price': (double.tryParse(priceController.text) ?? 0)
                    .toString(),
                'description': descriptionController.text.trim(),
                'category': selectedCategory,
              };

              try {
                final response = await ApiService.multipartRequest(
                  isEditing
                      ? 'worker-auth/my-services/${existing.id}'
                      : 'worker-auth/my-services',
                  fields: fields,
                  coverImage: coverImageFile,
                  galleryImages: galleryFiles.isNotEmpty ? galleryFiles : null,
                  video: videoFile,
                  auth: true,
                );

                if (!mounted) return;

                final ok = isEditing
                    ? response.statusCode == 200
                    : response.statusCode == 201;

                if (ok) {
                  modalNavigator.pop();
                  _fetchServices();
                } else {
                  setModalState(() => isSaving = false);
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        isEditing
                            ? 'Failed to update service'
                            : 'Failed to add service',
                      ),
                    ),
                  );
                }
              } catch (_) {
                if (!mounted) return;
                setModalState(() => isSaving = false);
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('Network error, please try again')),
                );
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing ? 'Edit Service' : 'Add New Service',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Cover photo
                    Text(
                      'Cover Photo',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: pickCover,
                      child: Container(
                        width: double.infinity,
                        height: 130,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: coverImageFile != null
                            ? Image.file(coverImageFile!, fit: BoxFit.cover)
                            : (existing?.imageUrl.isNotEmpty ?? false)
                                ? Image.network(
                                    existing!.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _pickerPlaceholder('Tap to add a cover photo'),
                                  )
                                : _pickerPlaceholder('Tap to add a cover photo'),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Gallery photos
                    Text(
                      'Gallery Photos',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 76,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          GestureDetector(
                            onTap: pickGallery,
                            child: Container(
                              width: 76,
                              height: 76,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Icon(Icons.add_photo_alternate_outlined,
                                  color: Colors.grey[500]),
                            ),
                          ),
                          if (galleryFiles.isNotEmpty)
                            ...galleryFiles.map(
                              (file) => ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: 76,
                                  height: 76,
                                  margin: const EdgeInsets.only(right: 8),
                                  child: Image.file(file, fit: BoxFit.cover),
                                ),
                              ),
                            )
                          else if (existing?.galleryImages?.isNotEmpty ?? false)
                            ...existing!.galleryImages!.map(
                              (url) => ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: 76,
                                  height: 76,
                                  margin: const EdgeInsets.only(right: 8),
                                  child: Image.network(url, fit: BoxFit.cover),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (galleryFiles.isEmpty &&
                        (existing?.galleryImages?.isNotEmpty ?? false))
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'Adding new photos replaces the current gallery.',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Demo video
                    Text(
                      'Demo Video',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: pickVideo,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.videocam_outlined, color: Colors.grey[600]),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                videoFile != null
                                    ? videoFile!.path.split(Platform.pathSeparator).last
                                    : (existing?.videoUrl != null
                                        ? 'Video already added — tap to replace'
                                        : 'Tap to add a demo video'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
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
                      items: ['cleaning', 'plumbing', 'repair', 'roofing', 'electrical']
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
                        onPressed: isSaving ? null : submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                isEditing ? 'Save Changes' : 'Add Service',
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      titleController.dispose();
      priceController.dispose();
      descriptionController.dispose();
    });
  }

  Widget _pickerPlaceholder(String label) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_a_photo_outlined, color: Colors.grey[400], size: 28),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
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
                  onPressed: () => _showServiceFormSheet(),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  service.category ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                onPressed: () => _showServiceFormSheet(existing: service),
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
