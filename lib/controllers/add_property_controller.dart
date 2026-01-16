import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
}
