import 'package:get/get.dart';
import 'package:house_renting/controllers/auth_controller.dart';
import 'package:house_renting/models.dart';
import 'package:house_renting/services/api_service.dart';

class PaymentController extends GetxController {
  final RxList<Payment> payments = <Payment>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<Payment> currentPayment = Rxn<Payment>();
  final ApiService _apiService = ApiService();

  @override
  void onInit() {
    super.onInit();
    fetchPayments();
  }

  Future<void> fetchPayments({int page = 1, int perPage = 15}) async {
    try {
      isLoading(true);
      errorMessage('');

      final response = await _apiService.getPayments(
        page: page,
        perPage: perPage,
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> paymentData = response['data'];
        final List<Payment> paymentList = paymentData
            .map((json) => Payment.fromJson(json))
            .toList();
        payments.assignAll(paymentList);
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch payments');
      }
    } catch (e) {
      errorMessage(e.toString());
      print('Error fetching payments: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchPaymentDetails(int id) async {
    try {
      currentPayment.value = null;
      isLoading(true);

      final response = await _apiService.getPaymentDetails(id);

      if (response['success'] == true && response['data'] != null) {
        currentPayment.value = Payment.fromJson(response['data']);
      } else {
        throw Exception(
          response['message'] ?? 'Failed to fetch payment details',
        );
      }
    } catch (e) {
      errorMessage(e.toString());
      print('Error fetching payment details: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<Payment> createPayment(Map<String, dynamic> paymentData) async {
    try {
      isLoading(true);
      errorMessage('');

      final response = await _apiService.createPayment(paymentData);

      if (response['success'] == true && response['data'] != null) {
        final newPayment = Payment.fromJson(response['data']);
        payments.insert(0, newPayment);
        return newPayment;
      } else {
        throw Exception(response['message'] ?? 'Failed to create payment');
      }
    } catch (e) {
      errorMessage(e.toString());
      print('Error creating payment: $e');
      rethrow;
    } finally {
      isLoading(false);
    }
  }

  Future<Payment> confirmPayment(int id) async {
    try {
      isLoading(true);
      errorMessage('');

      final response = await _apiService.confirmPayment(id);

      if (response['success'] == true && response['data'] != null) {
        final updatedPayment = Payment.fromJson(response['data']);

        // Update in list
        final index = payments.indexWhere((p) => p.id == id);
        if (index != -1) {
          payments[index] = updatedPayment;
        }

        // Update current payment if it matches
        if (currentPayment.value?.id == id) {
          currentPayment.value = updatedPayment;
        }

        return updatedPayment;
      } else {
        throw Exception(response['message'] ?? 'Failed to confirm payment');
      }
    } catch (e) {
      errorMessage(e.toString());
      print('Error confirming payment: $e');
      rethrow;
    } finally {
      isLoading(false);
    }
  }

  Future<Payment> rejectPayment(int id, {String? reason}) async {
    try {
      isLoading(true);
      errorMessage('');

      final response = await _apiService.rejectPayment(id, reason: reason);

      if (response['success'] == true && response['data'] != null) {
        final updatedPayment = Payment.fromJson(response['data']);

        // Update in list
        final index = payments.indexWhere((p) => p.id == id);
        if (index != -1) {
          payments[index] = updatedPayment;
        }

        // Update current payment if it matches
        if (currentPayment.value?.id == id) {
          currentPayment.value = updatedPayment;
        }

        return updatedPayment;
      } else {
        throw Exception(response['message'] ?? 'Failed to reject payment');
      }
    } catch (e) {
      errorMessage(e.toString());
      print('Error rejecting payment: $e');
      rethrow;
    } finally {
      isLoading(false);
    }
  }

  Future<Map<String, dynamic>> downloadReceipt(int id) async {
    try {
      final response = await _apiService.downloadReceipt(id);

      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['message'] ?? 'Failed to download receipt');
      }
    } catch (e) {
      print('Error downloading receipt: $e');
      rethrow;
    }
  }

  Payment? getPaymentById(int id) {
    return payments.firstWhereOrNull((p) => p.id == id);
  }

  List<Payment> get pendingPayments {
    return payments.where((p) => p.isPending).toList();
  }

  List<Payment> get confirmedPayments {
    return payments.where((p) => p.isConfirmed).toList();
  }

  List<Payment> get rejectedPayments {
    return payments.where((p) => p.isRejected).toList();
  }

  String getPaymentStatusText(Payment payment) {
    return payment.statusText;
  }

  String getPaymentStatusColor(Payment payment) {
    return payment.statusColor;
  }

  String getPaymentMethodText(Payment payment) {
    return payment.paymentMethodText;
  }

  Future<bool> canConfirmPayment(int paymentId) async {
    try {
      final payment = getPaymentById(paymentId);
      if (payment == null) return false;

      // Check if user is landlord
      final authController = Get.find<AuthController>();
      if (authController.currentUser?.role.toLowerCase() != 'landlord') {
        return false;
      }

      return payment.isPending;
    } catch (e) {
      print('Error checking payment confirmation eligibility: $e');
      return false;
    }
  }

  Future<bool> canRejectPayment(int paymentId) async {
    try {
      final payment = getPaymentById(paymentId);
      if (payment == null) return false;

      // Check if user is landlord
      final authController = Get.find<AuthController>();
      if (authController.currentUser?.role.toLowerCase() != 'landlord') {
        return false;
      }

      return payment.isPending;
    } catch (e) {
      print('Error checking payment rejection eligibility: $e');
      return false;
    }
  }

  Future<bool> canCreatePayment() async {
    try {
      // Check if user is tenant
      final authController = Get.find<AuthController>();
      return authController.currentUser?.role.toLowerCase() == 'tenant';
    } catch (e) {
      print('Error checking payment creation eligibility: $e');
      return false;
    }
  }

  // Calculate payment statistics
  Map<String, int> get paymentStats {
    final total = payments.length;
    final pending = payments.where((p) => p.isPending).length;
    final confirmed = payments.where((p) => p.isConfirmed).length;
    final rejected = payments.where((p) => p.isRejected).length;
    final withReceipt = payments.where((p) => p.hasReceipt).length;

    return {
      'Total': total,
      'Pending': pending,
      'Confirmed': confirmed,
      'Rejected': rejected,
      'With Receipt': withReceipt,
    };
  }

  // Calculate total amount
  double get totalAmount {
    return payments.fold(0, (sum, payment) => sum + payment.amount);
  }

  // Calculate confirmed amount
  double get confirmedAmount {
    return payments
        .where((p) => p.isConfirmed)
        .fold(0, (sum, payment) => sum + payment.amount);
  }
}
