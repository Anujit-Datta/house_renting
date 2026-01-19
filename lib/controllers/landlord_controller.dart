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
  bool _isFetching = false; // Flag to prevent concurrent fetches

  @override
  void onInit() {
    super.onInit();
    // Don't fetch on init - let the screen trigger it when needed
  }

  Future<void> fetchDashboardData() async {
    // Prevent concurrent fetches
    if (_isFetching) {
      print('DEBUG: Already fetching, skipping duplicate request');
      return;
    }

    _isFetching = true;
    try {
      isLoading.value = true;

      // 1. Fetch all properties
      // Note: Ideally API would provide /my-properties endpoint. behavior
      // We are fetching all and filtering client-side for now as per available API.
      final allProperties = await PropertyService().getProperties();

      // 2. Filter for current landlord by ID
      final currentUser = Get.find<AuthController>().currentUser;
      final currentUserId = currentUser?.id;

      print('DEBUG: Current user email: ${currentUser?.email}');
      print('DEBUG: Current user ID: $currentUserId (type: ${currentUserId.runtimeType})');
      print('DEBUG: Total properties fetched: ${allProperties.length}');

      if (allProperties.isNotEmpty) {
        print('DEBUG: First property landlordId: ${allProperties.first.landlordId} (type: ${allProperties.first.landlordId.runtimeType})');
      }

      if (currentUserId != null) {
        final userProperties = allProperties.where((p) {
          // Filter by landlord_id
          final matches = p.landlordId == currentUserId.toString();
          print('DEBUG: Comparing p.landlordId="${p.landlordId}" with currentUserId="$currentUserId" -> $matches');
          return matches;
        }).toList();

        print('DEBUG: Filtered properties count: ${userProperties.length}');
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
      _isFetching = false;
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
