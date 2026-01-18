import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:house_renting/services/api_service.dart';
import 'dart:io';

class AddPropertyController extends GetxController {
  // Basic Information
  final propertyNameController = TextEditingController();
  final locationController = TextEditingController();
  final rentController = TextEditingController();

  final propertyType = 'Apartment'.obs;
  final propertyStatus = 'For Rent'.obs;
  final isMultiUnit = false.obs;

  // Rental Type
  final isBachelor = false.obs;
  final isFamily = false.obs;
  final isSublet = false.obs;
  final isCommercial = false.obs;

  // Property Details
  final bedroomsController = TextEditingController(text: '1');
  final bathroomsController = TextEditingController(text: '1');
  final sizeController = TextEditingController();
  final floorController = TextEditingController();

  final parkingAvailable = false.obs;
  final furnished = false.obs;
  final isFeatured = false.obs;

  // Utility Bills
  final electricityRateController = TextEditingController();
  final meterRentController = TextEditingController();

  final hasWaterBill = false.obs;
  final waterBillController = TextEditingController();

  final hasGasBill = false.obs;
  final gasBillController = TextEditingController();

  final hasServiceCharge = false.obs;
  final serviceChargeController = TextEditingController();

  final hasOtherCharges = false.obs;
  final otherChargesController = TextEditingController();

  // Description
  final descriptionController = TextEditingController();

  // Image upload
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxBool isSubmitting = false.obs;

  @override
  void onClose() {
    propertyNameController.dispose();
    locationController.dispose();
    rentController.dispose();
    bedroomsController.dispose();
    bathroomsController.dispose();
    sizeController.dispose();
    floorController.dispose();
    electricityRateController.dispose();
    meterRentController.dispose();
    waterBillController.dispose();
    gasBillController.dispose();
    serviceChargeController.dispose();
    otherChargesController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  String getRentalType() {
    if (isBachelor.value) return 'bachelor';
    if (isFamily.value) return 'family';
    if (isSublet.value) return 'sublet';
    if (isCommercial.value) return 'commercial';
    return 'all';
  }

  Future<bool> submitProperty() async {
    isSubmitting.value = true;

    try {
      // Build the property data
      final propertyData = {
        'property_name': propertyNameController.text.trim(),
        'location': locationController.text.trim(),
        'rent': int.tryParse(rentController.text.trim()) ?? 0,
        'bedrooms': int.tryParse(bedroomsController.text.trim()) ?? 1,
        'bathrooms': int.tryParse(bathroomsController.text.trim()) ?? 1,
        'property_type': propertyType.value.toLowerCase(),
        'rental_type': getRentalType(),
        'size': sizeController.text.trim(),
        'floor': floorController.text.trim(),
        'parking': parkingAvailable.value,
        'furnished': furnished.value,
        'featured': isFeatured.value,
        'available': propertyStatus.value == 'For Rent',
        'description': descriptionController.text.trim(),
      };

      print('Submitting property: $propertyData');

      final response = await ApiService().createProperty(propertyData);

      if (response['success'] == true) {
        Get.snackbar(
          'Success',
          response['message'] ?? 'Property created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to create property',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      print('Error submitting property: $e');
      Get.snackbar(
        'Error',
        'Failed to create property: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  void clearForm() {
    propertyNameController.clear();
    locationController.clear();
    rentController.clear();
    bedroomsController.text = '1';
    bathroomsController.text = '1';
    sizeController.clear();
    floorController.clear();
    descriptionController.clear();
    
    propertyType.value = 'Apartment';
    propertyStatus.value = 'For Rent';
    isMultiUnit.value = false;
    
    isBachelor.value = false;
    isFamily.value = false;
    isSublet.value = false;
    isCommercial.value = false;
    
    parkingAvailable.value = false;
    furnished.value = false;
    isFeatured.value = false;
    
    electricityRateController.clear();
    meterRentController.clear();
    hasWaterBill.value = false;
    waterBillController.clear();
    hasGasBill.value = false;
    gasBillController.clear();
    hasServiceCharge.value = false;
    serviceChargeController.clear();
    hasOtherCharges.value = false;
    otherChargesController.clear();
    
    selectedImage.value = null;
  }
}
