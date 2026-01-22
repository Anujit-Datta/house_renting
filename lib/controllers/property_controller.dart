import 'package:get/get.dart';
import 'package:house_renting/services/property_service.dart';

class Property {
  final String id;
  final String title;
  final String location;
  final String price;
  final double rating;
  final bool isVerified;
  final bool isFeatured;
  final bool isFavorited; // Added field
  final bool available; // Property availability
  final bool rentedByMe; // If current user has rented this property
  final String landlordId; // Landlord's user ID
  final int beds;
  final int baths;
  final int sqft;
  final List<String> tags;
  final String date;
  final String imageUrl;
  final String description;
  final Map<String, dynamic> owner;
  final Map<String, dynamic> details;
  final Map<String, double> fees;

  Property({
    required this.id,
    required this.title,
    required this.location,
    required this.price,
    required this.rating,
    required this.isVerified,
    required this.isFeatured,
    this.isFavorited = false, // Default to false
    this.available = true, // Default to available
    this.rentedByMe = false, // Default to not rented
    this.landlordId = '0', // Default to '0' for backward compatibility
    required this.beds,
    required this.baths,
    required this.sqft,
    required this.tags,
    required this.date,
    required this.imageUrl,
    this.description = 'A handy description.',
    this.owner = const {
      'name': 'Rakib',
      'role': 'Property Owner',
      'image':
          'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80',
    },
    this.details = const {
      'Property Type': 'Apartment',
      'Floor': '6th',
      'Furnished': 'Yes',
      'Parking': 'Available',
      'Rental Type': 'Family',
    },
    this.fees = const {
      'Electricity Rate': 15.0, // Tk per unit
      'Gas Bill': 500.0,
      'Water Bill': 500.0,
      'Service Charge': 2000.0,
    },
  });
  factory Property.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse numbers to string/int/double
    String toStringOr(dynamic val, String fallback) =>
        val?.toString() ?? fallback;
    int toIntOr(dynamic val, int fallback) =>
        int.tryParse(val?.toString() ?? '') ?? fallback;

    final ownerData = json['landlord_data'] as Map<String, dynamic>? ?? {};

    return Property(
      id: toStringOr(json['id'], ''),
      title: json['property_name'] ?? 'No Title',
      location: json['location'] ?? 'No Location',
      price: 'Tk ${toStringOr(json['rent'], '0')}',
      rating: 0.0, // Not provided in API
      isVerified: json['is_verified'] == true || json['is_verified'] == 1,
      isFeatured: json['featured'] == true || json['featured'] == 1,
      available: json['available'] == true || json['available'] == 1,
      rentedByMe: json['rented_by_me'] == true || json['rented_by_me'] == 1,
      landlordId: toStringOr(json['landlord_id'], '0'),
      beds: toIntOr(json['bedrooms'], 0),
      baths: toIntOr(json['bathrooms'], 0),
      // Handle size carefully
      sqft: toIntOr(json['size'], 0),
      tags: [
        if (json['property_type'] != null) json['property_type'].toString(),
        if (json['rental_type'] != null) json['rental_type'].toString(),
        if (json['status'] != null) json['status'].toString(),
      ],
      date: json['posted_date'] ?? 'Recently',
      imageUrl:
          'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
      description: json['description'] ?? '',
      owner: {
        'name': ownerData['name'] ?? 'Unknown',
        'role': ownerData['role'] ?? 'Landlord',
        'image':
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80',
        'phone': ownerData['phone'],
        'email': ownerData['email'],
      },
      details: {
        'Property Type': json['property_type']?.toString() ?? 'Apartment',
        'Floor': json['floor']?.toString() ?? 'N/A',
        'Furnished': (json['furnished'] == true) ? 'Yes' : 'No',
        'Parking': (json['parking'] == true) ? 'Available' : 'None',
        'Rental Type': json['rental_type']?.toString() ?? 'Any',
      },
      isFavorited:
          json['favourited'] == true ||
          json['favourited'] == 1 ||
          json['favourited'] == '1' ||
          json['favourited'] == 'true',
      fees: _parseUtilityBills(json),
    );
  }

  /// Parse utility bills from API response
  static Map<String, double> _parseUtilityBills(Map<String, dynamic> json) {
    final utilityBills = json['utility_bills'] as Map<String, dynamic>? ?? {};

    final Map<String, double> fees = {};

    // Parse electricity_rate
    if (utilityBills['electricity_rate'] != null) {
      fees['Electricity Rate'] =
          double.tryParse(utilityBills['electricity_rate'].toString()) ?? 0.0;
    }

    // Parse meter_rent
    if (utilityBills['meter_rent'] != null) {
      fees['Meter Rent'] =
          double.tryParse(utilityBills['meter_rent'].toString()) ?? 0.0;
    }

    // Parse water_bill
    if (utilityBills['has_water_bill'] == true &&
        utilityBills['water_bill'] != null) {
      fees['Water Bill'] =
          double.tryParse(utilityBills['water_bill'].toString()) ?? 0.0;
    }

    // Parse gas_bill
    if (utilityBills['has_gas_bill'] == true &&
        utilityBills['gas_bill'] != null) {
      fees['Gas Bill'] =
          double.tryParse(utilityBills['gas_bill'].toString()) ?? 0.0;
    }

    // Parse service_charge
    if (utilityBills['has_service_charge'] == true &&
        utilityBills['service_charge'] != null) {
      fees['Service Charge'] =
          double.tryParse(utilityBills['service_charge'].toString()) ?? 0.0;
    }

    // Parse other_charges
    if (utilityBills['has_other_charges'] == true &&
        utilityBills['other_charges'] != null) {
      fees['Other Charges'] =
          double.tryParse(utilityBills['other_charges'].toString()) ?? 0.0;
    }

    return fees;
  }

  Property copyWith({
    String? id,
    String? title,
    String? location,
    String? price,
    double? rating,
    bool? isVerified,
    bool? isFeatured,
    bool? isFavorited,
    bool? available,
    bool? rentedByMe,
    String? landlordId,
    int? beds,
    int? baths,
    int? sqft,
    List<String>? tags,
    String? date,
    String? imageUrl,
    String? description,
    Map<String, dynamic>? owner,
    Map<String, dynamic>? details,
    Map<String, double>? fees,
  }) {
    return Property(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      isVerified: isVerified ?? this.isVerified,
      isFeatured: isFeatured ?? this.isFeatured,
      isFavorited: isFavorited ?? this.isFavorited,
      available: available ?? this.available,
      rentedByMe: rentedByMe ?? this.rentedByMe,
      landlordId: landlordId ?? this.landlordId,
      beds: beds ?? this.beds,
      baths: baths ?? this.baths,
      sqft: sqft ?? this.sqft,
      tags: tags ?? this.tags,
      date: date ?? this.date,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      owner: owner ?? this.owner,
      details: details ?? this.details,
      fees: fees ?? this.fees,
    );
  }
} // End of Property class

class PropertyController extends GetxController {
  final RxList<Property> properties = <Property>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<Property> currentProperty = Rxn<Property>();
  final RxSet<String> favoriteLoadingIds = <String>{}.obs;

  // Filter State
  final RxString filterLocation = 'Any'.obs;
  final RxString filterPropertyType = 'Any'.obs; // Apartment, House, etc
  final RxString filterRentalType = 'Any'.obs; // Family, Sublet, etc
  final RxInt filterBedrooms = 0.obs;
  final RxDouble filterMinRent = 0.0.obs;
  final RxDouble filterMaxRent = 0.0.obs;
  final RxString filterSearch = ''.obs; // Search query

  @override
  void onInit() {
    super.onInit();
    // Don't fetch on init - let screens trigger fetch when needed
    // This prevents conflicts with other controllers also fetching properties
  }

  Future<void> fetchProperties() async {
    try {
      isLoading(true);
      errorMessage('');

      // Debug: Print current filter values
      print('********** FETCH PROPERTIES DEBUG **********');
      print('filterLocation: ${filterLocation.value}');
      print('filterPropertyType: ${filterPropertyType.value}');
      print('filterRentalType: ${filterRentalType.value}');
      print('filterBedrooms: ${filterBedrooms.value}');
      print('filterMinRent: ${filterMinRent.value}');
      print('filterMaxRent: ${filterMaxRent.value}');
      print('filterSearch: ${filterSearch.value}');
      print('**********************************************');

      final fetchedProperties = await PropertyService().getProperties(
        location: filterLocation.value,
        propertyType: filterPropertyType.value,
        rentalType: filterRentalType.value,
        bedrooms: filterBedrooms.value,
        minRent: filterMinRent.value > 0 ? filterMinRent.value : null,
        maxRent: filterMaxRent.value > 0 ? filterMaxRent.value : null,
        search: filterSearch.value.trim().isNotEmpty ? filterSearch.value : null,
      );

      properties.assignAll(fetchedProperties);
    } catch (e) {
      errorMessage(e.toString());
      print(e);
    } finally {
      isLoading(false);
    }
  }

  void updateFilters({
    String? location,
    String? propertyType,
    String? rentalType,
    int? bedrooms,
    double? minRent,
    double? maxRent,
    String? search,
  }) {
    if (location != null) filterLocation.value = location;
    if (propertyType != null) filterPropertyType.value = propertyType;
    if (rentalType != null) filterRentalType.value = rentalType;
    if (bedrooms != null) filterBedrooms.value = bedrooms;
    if (minRent != null) filterMinRent.value = minRent;
    if (maxRent != null) filterMaxRent.value = maxRent;
    if (search != null) filterSearch.value = search;

    fetchProperties();
  }

  void clearFilters({bool clearSearch = false}) {
    filterLocation.value = 'Any';
    filterPropertyType.value = 'Any';
    filterRentalType.value = 'Any';
    filterBedrooms.value = 0;
    filterMinRent.value = 0.0;
    filterMaxRent.value = 0.0;
    if (clearSearch) filterSearch.value = '';
    fetchProperties();
  }

  Future<void> fetchPropertyDetails(String id) async {
    try {
      currentProperty.value = null; // Clear previous
      final property = await PropertyService().getPropertyDetails(id);
      currentProperty.value = property;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load property details');
      print(e);
    }
  }

  Future<void> toggleFavorite(Property property) async {
    if (favoriteLoadingIds.contains(property.id)) return; // Prevent double tap

    favoriteLoadingIds.add(property.id);

    // Optimistic Update
    final newStatus = !property.isFavorited;
    final updatedProperty = property.copyWith(isFavorited: newStatus);

    // Update in list
    final index = properties.indexWhere((p) => p.id == property.id);
    if (index != -1) {
      properties[index] = updatedProperty;
      properties.refresh(); // Trigger Obx
    }

    // Update currentProperty if it matches
    if (currentProperty.value?.id == property.id) {
      currentProperty.value = updatedProperty;
    }

    try {
      if (newStatus) {
        await PropertyService().addToFavorites(property.id);
      } else {
        await PropertyService().removeFromFavorites(property.id);
      }
    } catch (e) {
      // Revert on failure
      if (index != -1) {
        properties[index] = property;
        properties.refresh();
      }
      if (currentProperty.value?.id == property.id) {
        currentProperty.value = property;
      }
      print('Error toggling favorite: $e');
      Get.snackbar('Error', 'Failed to update favorite status');
    } finally {
      favoriteLoadingIds.remove(property.id);
    }
  }

  Property? getPropertyById(String id) {
    return properties.firstWhereOrNull((p) => p.id == id);
  }
}
