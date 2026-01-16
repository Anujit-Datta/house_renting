import 'package:get/get.dart';

class RentalRequestsController extends GetxController {
  // Stats Data
  final stats = <String, String>{
    'Total Requests': '1',
    'Pending Requests': '1',
    'Approved Requests': '0',
    'Properties with Requests': '1',
  }.obs;

  // Dummy Property Request Data
  final propertyRequests = <Map<String, dynamic>>[
    {
      'propertyName': 'Green Haven 5-Level Residence',
      'location': 'House 22, Road 8, Bashundhara R/A, Dhaka',
      'propertyType': 'Apartment',
      'rent': '20,000/month',
      'imageUrl':
          'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=80',
      'stats': {'pending': 1, 'approved': 0, 'rejected': 0},
    },
    // Add more dummy data if needed
  ].obs;

  // Dummy Tenant Requests for a specific property
  final tenantRequests = <Map<String, dynamic>>[
    {
      'id': 'req1',
      'tenantName': 'Rahim Uddin',
      'occupation': 'Software Engineer',
      'income': '80,000/month',
      'familyMembers': '3',
      'message':
          'Hi, I am interested in this apartment. We are a small family of 3. Please let me know if it is available.',
      'imageUrl':
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80',
      'status': 'Pending',
      'date': '12 Jan, 2026',
    },
    {
      'id': 'req2',
      'tenantName': 'Karim Hasan',
      'occupation': 'Banker',
      'income': '95,000/month',
      'familyMembers': '4',
      'message': 'Looking for a long term rental. Can move in from next month.',
      'imageUrl':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80',
      'status': 'Rejected',
      'date': '10 Jan, 2026',
    },
  ].obs;

  void acceptRequest(String id) {
    final index = tenantRequests.indexWhere((r) => r['id'] == id);
    if (index != -1) {
      tenantRequests[index]['status'] = 'Approved';
      tenantRequests.refresh();
      Get.snackbar(
        'Success',
        'Request Approved',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void declineRequest(String id) {
    final index = tenantRequests.indexWhere((r) => r['id'] == id);
    if (index != -1) {
      tenantRequests[index]['status'] = 'Rejected';
      tenantRequests
          .refresh(); // manually trigger update since it's a map update inside list
      Get.snackbar(
        'Declined',
        'Request Rejected',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
