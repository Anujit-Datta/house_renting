import 'package:get/get.dart';
import 'package:house_renting/controllers/property_controller.dart';
import 'package:house_renting/services/property_service.dart';
import 'package:house_renting/controllers/auth_controller.dart';

class LandlordController extends GetxController {
  static LandlordController get to => Get.find();

  // Observable stats
  final stats = <String, String>{}.obs;

  // Observable properties list
  final myProperties = <Property>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;

      // 1. Fetch all properties
      // Note: Ideally API would provide /my-properties endpoint. behavior
      // We are fetching all and filtering client-side for now as per available API.
      final allProperties = await PropertyService().getProperties();

      // 2. Filter for current user
      final currentUserEmail = Get.find<AuthController>().currentUser?.email;

      if (currentUserEmail != null) {
        final userProperties = allProperties.where((p) {
          // Check 'email' in owner map
          return p.owner['email'] == currentUserEmail;
        }).toList();

        myProperties.assignAll(userProperties);
      } else {
        // Fallback or empty if not logged in (shouldn't happen on this screen)
        myProperties.clear();
      }

      // 3. Update Stats
      stats.value = {
        'Total Properties': myProperties.length.toString(),
        'Total Rentals': '0', // Placeholder
        'Active Rentals': '0', // Placeholder
        'Monthly Revenue': 'Tk ${calculateRevenue()}',
      };
    } catch (e) {
      print('Error fetching landlord data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String calculateRevenue() {
    double total = 0;
    for (var p in myProperties) {
      // Extract price logic, removing "Tk " and "/mo" and commas
      final cleanPrice = p.price
          .replaceAll('Tk ', '')
          .replaceAll('/mo', '')
          .replaceAll(',', '')
          .trim();
      total += double.tryParse(cleanPrice) ?? 0;
    }
    return total.toStringAsFixed(0);
  }
}
