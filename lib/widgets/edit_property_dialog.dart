import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:house_renting/controllers/property_controller.dart';
import 'package:house_renting/controllers/landlord_controller.dart';
import 'package:house_renting/services/api_service.dart';

class EditPropertyDialog extends StatefulWidget {
  final Property property;

  const EditPropertyDialog({super.key, required this.property});

  @override
  State<EditPropertyDialog> createState() => _EditPropertyDialogState();
}

class _EditPropertyDialogState extends State<EditPropertyDialog> {
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _rentController;
  late TextEditingController _bedsController;
  late TextEditingController _bathsController;
  late TextEditingController _sizeController;
  late TextEditingController _floorController;
  late TextEditingController _descController;
  late TextEditingController _mapController;

  String _selectedPropertyType = 'Apartment';
  late bool _available;
  late bool _featured;
  late bool _parking;
  late bool _furnished;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.property.title);
    _locationController = TextEditingController(text: widget.property.location);
    // Extract numeric rent
    _rentController = TextEditingController(
      text: widget.property.price.replaceAll(RegExp(r'[^0-9]'), ''),
    );
    _bedsController = TextEditingController(
      text: widget.property.beds.toString(),
    );
    _bathsController = TextEditingController(
      text: widget.property.baths.toString(),
    );
    _sizeController = TextEditingController(
      text: widget.property.sqft.toString(),
    );
    _floorController = TextEditingController(
      text: widget.property.details['Floor'] ?? '',
    );
    _descController = TextEditingController(text: widget.property.description);
    _mapController = TextEditingController(
      text: 'Latitude: 23.746466, Longitude: 90.376015',
    );

    // Validate Property Type
    String incomingType =
        widget.property.details['Property Type']?.toString().toLowerCase() ?? 'apartment';

    print('********** EDIT PROPERTY TYPE DEBUG **********');
    print('Property Type from details: ${widget.property.details['Property Type']}');
    print('Lowercased incomingType: $incomingType');
    print('Available from property: ${widget.property.available}');
    print('Featured from property: ${widget.property.isFeatured}');
    print('***********************************************');

    const allowedTypes = ['apartment', 'house', 'duplex', 'flat', 'villa', 'office'];
    if (allowedTypes.contains(incomingType)) {
      // Capitalize first letter for display
      _selectedPropertyType = incomingType[0].toUpperCase() + incomingType.substring(1);
    } else {
      // Fallback if the API returns an unknown type
      _selectedPropertyType = 'Apartment';
    }

    _featured = widget.property.isFeatured;
    _available = widget.property.available;
    // Simple logic associated with 'Parking' in 'Available' for demo
    _parking =
        widget.property.details['Parking']?.toString().contains('Available') ??
        false;
    _furnished = widget.property.details['Furnished'] == 'Yes';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _rentController.dispose();
    _bedsController.dispose();
    _bathsController.dispose();
    _sizeController.dispose();
    _floorController.dispose();
    _descController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdateProperty() async {
    // Validate required fields
    if (_nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter property name',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }
    if (_locationController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter location',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }
    if (_rentController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter rent amount',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }
    if (int.tryParse(_rentController.text.trim()) == null) {
      Get.snackbar(
        'Validation Error',
        'Rent must be a valid number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    print('********** PROPERTY UPDATE DEBUG START **********');
    print('Updating property ID: ${widget.property.id}');
    print('Property name: ${_nameController.text.trim()}');
    print('********** PROPERTY UPDATE DEBUG END **********');

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Build the property data - matching Laravel backend exactly
      final propertyData = {
        // Required fields
        'property_name': _nameController.text.trim(),
        'location': _locationController.text.trim(),
        'rent': int.tryParse(_rentController.text.trim()) ?? 0,
        'bedrooms': int.tryParse(_bedsController.text.trim()) ?? widget.property.beds,
        'bathrooms': int.tryParse(_bathsController.text.trim()) ?? widget.property.baths,
        'property_type': _selectedPropertyType.toLowerCase(),

        // Optional fields - only include if they have values
        if (_descController.text.trim().isNotEmpty)
          'description': _descController.text.trim(),
        if (_sizeController.text.trim().isNotEmpty)
          'size': _sizeController.text.trim(),
        if (_floorController.text.trim().isNotEmpty)
          'floor': _floorController.text.trim(),

        // Boolean fields
        'parking': _parking,
        'furnished': _furnished,
        'available': _available,
        'featured': _featured,
      };

      print('********** SENDING UPDATE DATA START **********');
      propertyData.forEach((key, value) {
        print('  $key: $value (${value.runtimeType})');
      });
      print('********** SENDING UPDATE DATA END **********');

      final response = await ApiService().updateProperty(
        int.parse(widget.property.id),
        propertyData,
      );

      print('********** UPDATE RESPONSE START **********');
      print('Response status: ${response['success']}');
      print('Response message: ${response['message']}');
      print('********** UPDATE RESPONSE END **********');

      if (response['success'] == true) {
        if (mounted) {
          Get.snackbar(
            'Success',
            response['message'] ?? 'Property updated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          // Refresh landlord dashboard
          final landlordController = Get.find<LandlordController>();
          await landlordController.fetchDashboardData();

          // Close dialog
          Get.back();
        }
      } else {
        if (mounted) {
          Get.snackbar(
            'Error',
            response['message'] ?? 'Failed to update property',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      print('********** UPDATE ERROR START **********');
      print('Error updating property: $e');
      print('Stack trace: ${StackTrace.current}');
      print('********** UPDATE ERROR END **********');

      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to update property: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: 600, // Fixed max width for larger screens
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Edit Property',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Property Name'),
                    _buildTextField(_nameController),
                    const SizedBox(height: 16),

                    _buildLabel('Location'),
                    _buildTextField(_locationController),
                    const SizedBox(height: 16),

                    _buildLabel('Rent (\$)'), // Using $ as per image
                    _buildTextField(_rentController),
                    const SizedBox(height: 16),

                    _buildLabel('Bedrooms'),
                    _buildTextField(_bedsController),
                    const SizedBox(height: 16),

                    _buildLabel('Bathrooms'),
                    _buildTextField(_bathsController),
                    const SizedBox(height: 16),

                    _buildLabel('Size (sqft)'),
                    _buildTextField(_sizeController, suffix: ' sq ft'),
                    const SizedBox(height: 16),

                    _buildLabel('Floor'),
                    _buildTextField(_floorController),
                    const SizedBox(height: 16),

                    _buildLabel('Property Type'),
                    _buildDropdown(),
                    const SizedBox(height: 16),

                    _buildLabel('Description'),
                    _buildTextField(_descController, maxLines: 5),
                    const SizedBox(height: 16),

                    _buildLabel('Map Embed Code'),
                    _buildTextField(_mapController, maxLines: 2),
                    const SizedBox(height: 16),

                    // Checkboxes
                    Wrap(
                      spacing: 24,
                      children: [
                        _buildCheckbox(
                          'Available',
                          _available,
                          (v) => setState(() => _available = v!),
                        ),
                        _buildCheckbox(
                          'Featured',
                          _featured,
                          (v) => setState(() => _featured = v!),
                        ),
                        _buildCheckbox(
                          'Parking',
                          _parking,
                          (v) => setState(() => _parking = v!),
                        ),
                        _buildCheckbox(
                          'Furnished',
                          _furnished,
                          (v) => setState(() => _furnished = v!),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // File Inputs
                    _buildLabel('Main Image'),
                    _buildFileInput('No file chosen'),
                    const SizedBox(height: 16),

                    _buildLabel('Floor Plan'),
                    _buildFileInput('No file chosen'),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: 160,
                      child: ElevatedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => _handleUpdateProperty(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isSubmitting
                              ? Colors.green.shade300
                              : const Color(
                                  0xFF5CB85C,
                                ), // Green color matching image
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Update Property',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    int maxLines = 1,
    String? suffix,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        suffixText: suffix,
        suffixStyle: const TextStyle(color: Colors.black54),
        // Match the Bootstrap-like style: simple border, reduced padding
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Colors.blue, width: 1),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPropertyType,
          isExpanded: true,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          dropdownColor: Colors.white,
          items: ['Apartment', 'House', 'Duplex', 'Flat', 'Villa'].map((
            String value,
          ) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedPropertyType = newValue!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildCheckbox(
    String title,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // denser
          activeColor: Colors.blue,
        ),
        const SizedBox(width: 4),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildFileInput(String placeholder) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
        color: Colors.grey.shade50,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(2),
              color: Colors.grey.shade200,
            ),
            child: const Text(
              'Choose File',
              style: TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            placeholder,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
