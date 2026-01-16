import 'package:get/get.dart';
import 'package:house_renting/controllers/property_controller.dart';

class LandlordController extends GetxController {
  static LandlordController get to => Get.find();

  // Observable stats
  final stats = <String, String>{}.obs;

  // Observable properties list
  final myProperties = <Property>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  void fetchDashboardData() {
    // Dummy Data for Dashboard Stats
    stats.value = {
      'Total Properties': '3',
      'Total Rentals': '0',
      'Active Rentals': '0',
      'Monthly Revenue': 'Tk 0',
    };

    // Dummy Data for My Properties
    myProperties.value = [
      Property(
        id: '1',
        title: 'Modern Apartment in Gulshan',
        location: 'Gulshan 2, Dhaka',
        price: 'Tk 25,000/mo',
        rating: 4.8,
        imageUrl:
            'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=80',
        beds: 3,
        baths: 2,
        sqft: 1500,
        tags: ['Apartment', 'Modern'],
        date: '2 days ago',
        description: 'Luxury apartment with all modern amenities.',
        isVerified: true,
        isFeatured: true,
        owner: {
          'name': 'You',
          'image':
              'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80',
          'role': 'Landlord',
        },
      ),
      Property(
        id: '2',
        title: 'Cozy Studio in Banani',
        location: 'Banani, Dhaka',
        price: 'Tk 15,000/mo',
        rating: 4.5,
        imageUrl:
            'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=80',
        beds: 1,
        baths: 1,
        sqft: 600,
        tags: ['Studio', 'Cozy'],
        date: '5 days ago',
        description: 'Perfect for singles or couples.',
        isVerified: true,
        isFeatured: false,
        owner: {
          'name': 'You',
          'image':
              'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80',
          'role': 'Landlord',
        },
      ),
      Property(
        id: '3',
        title: 'Spacious Family Home',
        location: 'Uttara Sector 7',
        price: 'Tk 35,000/mo',
        rating: 4.7,
        imageUrl:
            'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=80',
        beds: 4,
        baths: 3,
        sqft: 2200,
        tags: ['House', 'Family'],
        date: '1 week ago',
        description: 'Large family home near park.',
        isVerified: true,
        isFeatured: false,
        owner: {
          'name': 'You',
          'image':
              'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80',
          'role': 'Landlord',
        },
      ),
    ];
  }
}
