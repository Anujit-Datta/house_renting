import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:house_renting/controllers/auth_controller.dart';
import 'package:house_renting/controllers/rental_requests_controller.dart';
import 'package:house_renting/controllers/property_controller.dart' show Property;

class RentalApplicationDialog extends StatefulWidget {
  final String propertyId;
  final Property property;

  const RentalApplicationDialog({
    super.key,
    required this.propertyId,
    required this.property,
  });

  @override
  State<RentalApplicationDialog> createState() =>
      _RentalApplicationDialogState();
}

class _RentalApplicationDialogState extends State<RentalApplicationDialog> {
  // Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _occupantsController;
  late final TextEditingController _occupationController;
  late final TextEditingController _emergencyNameController;
  late final TextEditingController _emergencyPhoneController;
  late final TextEditingController _notesController;

  // Form State
  bool _hasPets = false;
  bool _termsAccepted = false;
  String? _paymentMethod;
  DateTime? _moveInDate;
  bool _isSubmitting = false;

  // Controllers
  late final AuthController _authController;
  late final RentalRequestController _rentalRequestController;

  @override
  void initState() {
    super.initState();
    _authController = Get.find<AuthController>();
    _rentalRequestController = Get.find<RentalRequestController>();

    // Initialize controllers with user data if available
    final user = _authController.currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _addressController = TextEditingController(text: '');
    _occupantsController = TextEditingController(text: '1');
    _occupationController = TextEditingController(text: '');
    _emergencyNameController = TextEditingController(text: '');
    _emergencyPhoneController = TextEditingController(text: '');

    _notesController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _occupantsController.dispose();
    _occupationController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    // Validation
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty ||
        _occupantsController.text.trim().isEmpty ||
        _occupationController.text.trim().isEmpty ||
        _emergencyNameController.text.trim().isEmpty ||
        _emergencyPhoneController.text.trim().isEmpty ||
        _moveInDate == null ||
        _paymentMethod == null ||
        !_termsAccepted) {
      Get.snackbar(
        'Error',
        'Please fill in all required fields and accept the terms.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final requestData = {
        'property_id': int.parse(widget.propertyId),
        'move_in_date':
            '${_moveInDate!.year}-${_moveInDate!.month.toString().padLeft(2, '0')}-${_moveInDate!.day.toString().padLeft(2, '0')}',
        'payment_method': _paymentMethod,
        'has_pets': _hasPets ? 'yes' : 'no',
        'current_address': _addressController.text.trim(),
        'num_occupants': int.parse(_occupantsController.text.trim()),
        'occupation': _occupationController.text.trim(),
        'emergency_contact': _emergencyNameController.text.trim(),
        'emergency_phone': _emergencyPhoneController.text.trim(),
        'notes': _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        'terms': true,
      };

      await _rentalRequestController.createRentalRequest(requestData);

      if (mounted) {
        Get.back();
        Get.snackbar(
          'Success',
          'Application Submitted Successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to submit application: ${e.toString()}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 800),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.assignment, color: Color(0xFF2C3E50)),
                      SizedBox(width: 12),
                      Text(
                        'Rental Application',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border(
                          left: BorderSide(
                            color: Colors.blue.shade400,
                            width: 4,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info,
                            color: Colors.blue.shade400,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Applying for: ${widget.property.title}\nLocation: ${widget.property.location}\nRent: ${widget.property.price}',
                              style: const TextStyle(
                                color: Color(0xFF2C3E50),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildSectionHeader(Icons.person, 'Personal Information'),
                    _buildTextField(
                      'Full Name *',
                      'Full name as per NID',
                      _nameController,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Email *',
                      'Valid email address',
                      _emailController,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Mobile Number *',
                      '11-digit mobile number',
                      _phoneController,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Current Address *',
                      'Your current residential address',
                      _addressController,
                      maxLines: 2,
                    ),

                    const SizedBox(height: 24),
                    _buildSectionHeader(Icons.work, 'Additional Details'),
                    _buildTextField(
                      'Number of Occupants *',
                      'Total people living',
                      _occupantsController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Occupation *',
                      'Your profession',
                      _occupationController,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Emergency Contact Name *',
                      'Family member or friend',
                      _emergencyNameController,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Emergency Mobile *',
                      'Emergency contact number',
                      _emergencyPhoneController,
                    ),

                    const SizedBox(height: 24),
                    _buildSectionHeader(
                      Icons.calendar_today,
                      'Move-in Date & Duration',
                    ),
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Move-in Date *'),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(
                                      const Duration(days: 365),
                                    ),
                                  );
                                  if (date != null) {
                                    setState(() => _moveInDate = date);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _moveInDate == null
                                            ? 'dd/mm/yyyy'
                                            : '${_moveInDate!.day}/${_moveInDate!.month}/${_moveInDate!.year}',
                                        style: TextStyle(
                                          color: _moveInDate == null
                                              ? Colors.grey
                                              : Colors.black,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.calendar_today,
                                        size: 18,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Preferred date',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      label: 'Payment Method *',
                      hint: 'Select Payment Method',
                      items: const [
                        'bank_transfer',
                        'mobile_banking',
                        'hand_cash',
                        'check',
                      ],
                      selectedValue: _paymentMethod,
                      onChanged: (val) =>
                          setState(() => _paymentMethod = val),
                      subtext: 'How will you pay rent?',
                      itemLabels: const {
                        'bank_transfer': 'Bank Transfer',
                        'mobile_banking': 'Mobile Banking (bKash/Nagad)',
                        'hand_cash': 'Hand Cash',
                        'check': 'Check',
                      },
                    ),

                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('I have pets'),
                      value: _hasPets,
                      onChanged: (val) => setState(() => _hasPets = val ?? false),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),

                    const SizedBox(height: 24),
                    _buildSectionHeader(Icons.note, 'Additional Notes'),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            controller: _notesController,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText:
                                  'Any special requests or additional information...',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Optional',
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Checkbox(
                          value: _termsAccepted,
                          onChanged: (val) =>
                              setState(() => _termsAccepted = val ?? false),
                          activeColor: const Color(0xFF5E60CE),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(
                              () => _termsAccepted = !_termsAccepted,
                            ),
                            child: const Text(
                              'I agree to the Terms & Conditions and confirm all information is accurate',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 1),
            // Footer
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitApplication,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send, size: 18),
                label: Text(_isSubmitting ? 'Submitting...' : 'Submit Application'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5E60CE),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF2C3E50)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: const TextStyle(fontSize: 14),
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF5E60CE)),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
        const SizedBox(height: 4),
        Text(hint, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String hint,
    required List<String> items,
    required String? selectedValue,
    required Function(String?) onChanged,
    String? subtext,
    Map<String, String>? itemLabels,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade50,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text(
                hint,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              value: selectedValue != null && items.contains(selectedValue)
                  ? selectedValue
                  : null,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              items: items.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    itemLabels?[value] ?? value,
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (val) => onChanged(val),
            ),
          ),
        ),
        if (subtext != null) ...[
          const SizedBox(height: 4),
          Text(
            subtext,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Row(
      children: [
        Text(
          label.replaceAll(' *', ''),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Color(0xFF2C3E50),
          ),
        ),
        if (label.contains('*'))
          const Text(
            ' *',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
      ],
    );
  }
}
