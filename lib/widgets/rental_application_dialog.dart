import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RentalApplicationDialog extends StatefulWidget {
  const RentalApplicationDialog({super.key});

  @override
  State<RentalApplicationDialog> createState() =>
      _RentalApplicationDialogState();
}

class _RentalApplicationDialogState extends State<RentalApplicationDialog> {
  // Form State
  String? _petStatus;
  bool _termsAccepted = false;
  String? _paymentMethod;
  DateTime? _moveInDate;

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
                          const Expanded(
                            child: Text(
                              'No specific flats listed. General rental application for entire property.',
                              style: TextStyle(
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
                      'Muttakin Hosen',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Email *',
                      'Valid email address',
                      'redc22736@gmail.com',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'National ID (NID) *',
                      '10, 13, or 17 digits',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Mobile Number *',
                      '11-digit mobile number',
                      '+8801793607694',
                    ),

                    const SizedBox(height: 24),
                    _buildSectionHeader(Icons.location_on, 'Current Address'),
                    _buildTwoColumnRow(
                      _buildTextField(
                        'House/Flat/Building *',
                        'e.g., House 12, Flat 3A',
                      ),
                      _buildTextField('Road/Street *', 'e.g., Road 5, Mirpur'),
                    ),
                    _buildTwoColumnRow(
                      _buildTextField(
                        'Area/Locality *',
                        'e.g., Dhanmondi, Gulshan',
                      ),
                      _buildTextField(
                        'Thana/Upazila *',
                        'e.g., Mirpur, Uttara',
                      ),
                    ),
                    _buildTwoColumnRow(
                      _buildTextField('District *', 'e.g., Dhaka, Chittagong'),
                      _buildTextField('Postal Code *', 'e.g., 1216'),
                    ),

                    const SizedBox(height: 24),
                    _buildSectionHeader(Icons.work, 'Additional Details'),
                    _buildTextField(
                      'Number of Occupants *',
                      'Total people living',
                      '1',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Occupation *',
                      'Your profession',
                      'Student/Professional/Business',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Emergency Contact Name *',
                      'Family member or friend',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Emergency Mobile *',
                      'Emergency contact number',
                      '01XXXXXXXXX',
                    ),

                    const SizedBox(height: 24),
                    _buildSectionHeader(
                      Icons.calendar_today,
                      'Move-in & Payment',
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
                        const SizedBox(height: 16),
                        _buildDropdown(
                          label: 'Payment Method *',
                          hint: 'Select Payment Method',
                          items: ['Bank Transfer', 'bKash', 'Cash'],
                          selectedValue: _paymentMethod,
                          onChanged: (val) =>
                              setState(() => _paymentMethod = val),
                          subtext: 'Rent payment method',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      label: 'Do you have pets?',
                      hint: 'No',
                      items: ['No', 'Yes - Cat', 'Yes - Dog', 'Yes - Other'],
                      selectedValue: _petStatus,
                      onChanged: (val) => setState(() => _petStatus = val),
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
                          child: const TextField(
                            maxLines: 4,
                            decoration: InputDecoration(
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
                    _buildSectionHeader(
                      Icons.upload_file,
                      'Upload Documents (Optional)',
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: const Text(
                              'Choose Files',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'No file chosen',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'NID, passport, or supporting documents (Max 5 files, 5MB each)',
                      style: TextStyle(color: Colors.grey, fontSize: 11),
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
                onPressed: () {
                  Get.back();
                  Get.snackbar(
                    'Success',
                    'Application Submitted Successfully!',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                icon: const Icon(Icons.send, size: 18),
                label: const Text('Submit Application'),
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

  Widget _buildTwoColumnRow(Widget child1, Widget child2) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: child1),
          const SizedBox(width: 16),
          Expanded(child: child2),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, [String? initialValue]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          style: const TextStyle(fontSize: 14),
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
                  child: Text(value, style: const TextStyle(fontSize: 14)),
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
