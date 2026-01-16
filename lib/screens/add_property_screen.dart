import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:house_renting/controllers/add_property_controller.dart';
import 'package:house_renting/widgets/custom_app_bar.dart';

class AddPropertyScreen extends StatelessWidget {
  const AddPropertyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    final controller = Get.put(AddPropertyController());

    return Scaffold(
      appBar: CustomAppBar(title: 'Add New Property', actions: const []),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Basic Information Section ---
            _buildSectionHeader(Icons.info_outline, 'Basic Information'),
            const SizedBox(height: 20),
            _buildLabel('Property Name', isRequired: true),
            _buildTextField(
              controller.propertyNameController,
              'e.g., Sunshine Apartment Complex',
            ),
            const SizedBox(height: 16),
            _buildLabel('Location', isRequired: true),
            _buildTextField(
              controller.locationController,
              'e.g., House 12, Road 5, Gulshan-2, Dhaka',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Property Type', isRequired: true),
                      Obx(
                        () => _buildDropdown(
                          value: controller.propertyType.value,
                          items: ['Apartment', 'House', 'Villa', 'Office'],
                          onChanged: (v) => controller.propertyType.value = v!,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Status', isRequired: true),
                      Obx(
                        () => _buildDropdown(
                          value: controller.propertyStatus.value,
                          items: ['For Rent', 'For Sale'],
                          onChanged: (v) =>
                              controller.propertyStatus.value = v!,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('Base Monthly Rent (৳)', isRequired: true),
                _buildTextField(
                  controller.rentController,
                  'e.g., 25000',
                  isNumber: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(
              () => CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'This is a multi-unit building (Multiple floors and flats)',
                  style: TextStyle(fontSize: 14, color: Color(0xFF2C3E50)),
                ),
                secondary: const Icon(Icons.business, size: 20),
                value: controller.isMultiUnit.value,
                onChanged: (v) => controller.isMultiUnit.value = v!,
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
              ),
            ),

            const SizedBox(height: 32),
            // --- Rental Type Section ---
            _buildSectionHeader(Icons.people_outline, 'Rental Type'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Obx(
                    () => _buildCheckboxRow('Bachelor', controller.isBachelor),
                  ),
                  const Divider(),
                  Obx(() => _buildCheckboxRow('Family', controller.isFamily)),
                  const Divider(),
                  Obx(
                    () => _buildCheckboxRow(
                      'Sublet (Shared Room)',
                      controller.isSublet,
                    ),
                  ),
                  const Divider(),
                  Obx(
                    () => _buildCheckboxRow(
                      'Commercial',
                      controller.isCommercial,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            // --- Property Details Section ---
            _buildSectionHeader(Icons.home_outlined, 'Property Details'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Bedrooms'),
                      _buildTextField(
                        controller.bedroomsController,
                        '1',
                        isNumber: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Bathrooms'),
                      _buildTextField(
                        controller.bathroomsController,
                        '1',
                        isNumber: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Size (sq ft)'),
                      _buildTextField(
                        controller.sizeController,
                        'e.g., 1200',
                        isNumber: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Floor'),
                      _buildTextField(controller.floorController, '1st Floor'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(
              () => _buildDetailCheckbox(
                'Parking Available',
                Icons.directions_car,
                controller.parkingAvailable,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => _buildDetailCheckbox(
                'Furnished',
                Icons.weekend,
                controller.furnished,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => _buildDetailCheckbox(
                'Mark as Featured Property',
                Icons.star,
                controller.isFeatured,
              ),
            ),

            const SizedBox(height: 32),
            // --- Utility Bills Section ---
            _buildSectionHeader(Icons.receipt_long, 'Utility Bills & Charges'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF3498DB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF3498DB), width: 1),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Color(0xFF3498DB), size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Electricity will be calculated based on actual monthly consumption',
                      style: TextStyle(
                        color: Color(0xFF2980B9),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Electricity Rate per Unit (৳/kWh)'),
                      _buildTextField(
                        controller.electricityRateController,
                        '7.50',
                        isNumber: true,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tenants will pay based on their meter reading',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Meter Rent (Monthly ৳)'),
                      _buildTextField(
                        controller.meterRentController,
                        '50',
                        isNumber: true,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Fixed monthly meter charge (if any)',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Obx(
              () => _buildUtilityItem(
                'Water Bill (Fixed)',
                controller.hasWaterBill,
                controller.waterBillController,
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => _buildUtilityItem(
                'Gas Bill (Fixed)',
                controller.hasGasBill,
                controller.gasBillController,
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => _buildUtilityItem(
                'Service Charge',
                controller.hasServiceCharge,
                controller.serviceChargeController,
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => _buildUtilityItem(
                'Other Charges',
                controller.hasOtherCharges,
                controller.otherChargesController,
              ),
            ),

            const SizedBox(height: 32),
            // --- Description Section ---
            _buildSectionHeader(Icons.description, 'Description'),
            const SizedBox(height: 16),
            _buildTextField(
              controller.descriptionController,
              'Enter detailed description...',
              maxLines: 4,
            ),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.snackbar(
                    'Success',
                    'Property Added Successfully',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C3E50),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Save Property',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 22, color: const Color(0xFF2C3E50)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF34495E),
          ),
          children: isRequired
              ? [
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  ),
                ]
              : [],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF2C3E50), width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          isExpanded: true,
          style: const TextStyle(color: Color(0xFF2C3E50), fontSize: 14),
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCheckboxRow(String title, RxBool value) {
    return InkWell(
      onTap: () => value.value = !value.value,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
        child: Row(
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: value.value,
                onChanged: (v) => value.value = v!,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Color(0xFF2C3E50)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCheckbox(String title, IconData icon, RxBool value) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: CheckboxListTile(
        title: Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey.shade700),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Color(0xFF2C3E50)),
            ),
          ],
        ),
        value: value.value,
        onChanged: (v) => value.value = v!,
        controlAffinity: ListTileControlAffinity.leading,
        dense: true,
        contentPadding: const EdgeInsets.only(left: 8, right: 16),
      ),
    );
  }

  Widget _buildUtilityItem(
    String title,
    RxBool isChecked,
    TextEditingController amountController,
  ) {
    return Row(
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: isChecked.value,
            onChanged: (v) => isChecked.value = v!,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        SizedBox(
          width: 120,
          child: TextField(
            controller: amountController,
            enabled: isChecked.value,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Amount (৳)',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: isChecked.value ? Colors.white : Colors.grey.shade100,
            ),
          ),
        ),
      ],
    );
  }
}
