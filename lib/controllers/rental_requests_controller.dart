import 'package:get/get.dart';
import 'package:house_renting/services/api_service.dart';
import 'package:house_renting/models.dart';

class RentalRequestController extends GetxController {
  final RxList<RentalRequest> rentalRequests = <RentalRequest>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<RentalRequest> currentRequest = Rxn<RentalRequest>();
  final ApiService _apiService = ApiService();

  @override
  void onInit() {
    super.onInit();
    fetchRentalRequests();
  }

  Future<void> fetchRentalRequests({int page = 1, int perPage = 15}) async {
    try {
      isLoading(true);
      errorMessage('');

      final response = await _apiService.getRentalRequests(
        page: page,
        perPage: perPage,
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> requestData = response['data'];
        final List<RentalRequest> requests = requestData
            .map((json) => RentalRequest.fromJson(json))
            .toList();
        rentalRequests.assignAll(requests);
      } else {
        throw Exception(
          response['message'] ?? 'Failed to fetch rental requests',
        );
      }
    } catch (e) {
      errorMessage(e.toString());
      print('Error fetching rental requests: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchRentalRequestDetails(int id) async {
    try {
      currentRequest.value = null;
      isLoading(true);

      final response = await _apiService.getRentalRequestDetails(id);

      if (response['success'] == true && response['data'] != null) {
        currentRequest.value = RentalRequest.fromJson(response['data']);
      } else {
        throw Exception(
          response['message'] ?? 'Failed to fetch rental request details',
        );
      }
    } catch (e) {
      errorMessage(e.toString());
      print('Error fetching rental request details: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<RentalRequest> createRentalRequest(
    Map<String, dynamic> requestData,
  ) async {
    try {
      isLoading(true);
      errorMessage('');

      final response = await _apiService.createRentalRequest(requestData);

      if (response['success'] == true && response['data'] != null) {
        final newRequest = RentalRequest.fromJson(response['data']);
        rentalRequests.insert(0, newRequest);
        return newRequest;
      } else {
        throw Exception(
          response['message'] ?? 'Failed to create rental request',
        );
      }
    } catch (e) {
      errorMessage(e.toString());
      print('Error creating rental request: $e');
      rethrow;
    } finally {
      isLoading(false);
    }
  }

  Future<RentalRequest> approveRentalRequest(int id) async {
    try {
      // Don't set global isLoading - let screen handle inline loading
      errorMessage('');

      final response = await _apiService.approveRentalRequest(id);

      if (response['success'] == true && response['data'] != null) {
        final updatedRequest = RentalRequest.fromJson(response['data']);

        // Update in list
        final index = rentalRequests.indexWhere((r) => r.id == id);
        if (index != -1) {
          rentalRequests[index] = updatedRequest;
        }

        // Update current request if it matches
        if (currentRequest.value?.id == id) {
          currentRequest.value = updatedRequest;
        }

        return updatedRequest;
      } else {
        throw Exception(
          response['message'] ?? 'Failed to approve rental request',
        );
      }
    } catch (e) {
      errorMessage(e.toString());
      print('Error approving rental request: $e');
      rethrow;
    }
  }

  Future<RentalRequest> rejectRentalRequest(int id, {String? reason}) async {
    try {
      // Don't set global isLoading - let screen handle inline loading
      errorMessage('');

      final response = await _apiService.rejectRentalRequest(
        id,
        reason: reason,
      );

      if (response['success'] == true && response['data'] != null) {
        final updatedRequest = RentalRequest.fromJson(response['data']);

        // Update in list
        final index = rentalRequests.indexWhere((r) => r.id == id);
        if (index != -1) {
          rentalRequests[index] = updatedRequest;
        }

        // Update current request if it matches
        if (currentRequest.value?.id == id) {
          currentRequest.value = updatedRequest;
        }

        return updatedRequest;
      } else {
        throw Exception(
          response['message'] ?? 'Failed to reject rental request',
        );
      }
    } catch (e) {
      errorMessage(e.toString());
      print('Error rejecting rental request: $e');
      rethrow;
    }
  }

  RentalRequest? getRentalRequestById(int id) {
    return rentalRequests.firstWhereOrNull((r) => r.id == id);
  }

  List<RentalRequest> get pendingRequests {
    return rentalRequests
        .where((r) => r.status.toLowerCase() == 'pending')
        .toList();
  }

  List<RentalRequest> get approvedRequests {
    return rentalRequests
        .where((r) => r.status.toLowerCase() == 'approved')
        .toList();
  }

  List<RentalRequest> get rejectedRequests {
    return rentalRequests
        .where((r) => r.status.toLowerCase() == 'rejected')
        .toList();
  }

  String getRequestStatusText(RentalRequest request) {
    return request.statusText;
  }

  String getRequestStatusColor(RentalRequest request) {
    return request.statusColor;
  }

  // Stats computed from rental requests
  Map<String, int> get stats {
    final total = rentalRequests.length;
    final pending = rentalRequests
        .where((r) => r.status.toLowerCase() == 'pending')
        .length;
    final approved = rentalRequests
        .where((r) => r.status.toLowerCase() == 'approved')
        .length;
    final propertiesWithRequests = rentalRequests
        .map((r) => r.propertyId)
        .toSet()
        .length;

    return {
      'Total Requests': total,
      'Pending Requests': pending,
      'Approved Requests': approved,
      'Properties with Requests': propertiesWithRequests,
    };
  }

  Future<bool> canApproveRequest(int requestId) async {
    try {
      final request = getRentalRequestById(requestId);
      return request?.status.toLowerCase() == 'pending';
    } catch (e) {
      print('Error checking request approval eligibility: $e');
      return false;
    }
  }

  Future<bool> canRejectRequest(int requestId) async {
    try {
      final request = getRentalRequestById(requestId);
      return request?.status.toLowerCase() == 'pending';
    } catch (e) {
      print('Error checking request rejection eligibility: $e');
      return false;
    }
  }

  // Alias for backward compatibility
  List<RentalRequest> get requests => rentalRequests;

  int getTotalRequests() {
    return rentalRequests.length;
  }

  int getPendingCount() {
    return pendingRequests.length;
  }

  int getAcceptedCount() {
    return approvedRequests.length +
        rentalRequests.where((r) => r.isAccepted).length;
  }

  int getRejectedCount() {
    return rejectedRequests.length;
  }

  int getPropertiesWithRequestsCount() {
    return rentalRequests
        .map((r) => r.propertyId)
        .toSet()
        .length;
  }

  void updateRequest(RentalRequest request) {
    final index = rentalRequests.indexWhere((r) => r.id == request.id);
    if (index != -1) {
      rentalRequests[index] = request;
    }
    // Also update current request if needed
    if (currentRequest.value?.id == request.id) {
      currentRequest.value = request;
    }
  }
}
