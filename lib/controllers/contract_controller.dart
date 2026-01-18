import 'package:get/get.dart';
import 'package:house_renting/controllers/auth_controller.dart';
import 'package:house_renting/models.dart';
import 'package:house_renting/services/api_service.dart';

class ContractController extends GetxController {
  final RxList<Contract> contracts = <Contract>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<Contract> currentContract = Rxn<Contract>();
  final ApiService _apiService = ApiService();

  @override
  void onInit() {
    super.onInit();
    fetchContracts();
  }

  Future<void> fetchContracts({int page = 1, int perPage = 15}) async {
    try {
      isLoading(true);
      errorMessage('');

      final response = await _apiService.getContracts(
        page: page,
        perPage: perPage,
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> contractData = response['data'];
        final List<Contract> contractList = contractData
            .map((json) => Contract.fromJson(json))
            .toList();
        contracts.assignAll(contractList);
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch contracts');
      }
    } catch (e) {
      errorMessage(e.toString());
      print('Error fetching contracts: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchContractDetails(String id) async {
    try {
      currentContract.value = null;
      isLoading(true);

      final response = await _apiService.getContractDetails(int.parse(id));

      if (response['success'] == true && response['data'] != null) {
        currentContract.value = Contract.fromJson(response['data']);
      } else {
        throw Exception(
          response['message'] ?? 'Failed to fetch contract details',
        );
      }
    } catch (e) {
      errorMessage(e.toString());
      print('Error fetching contract details: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<Contract> generateContract(
    int requestId,
    Map<String, dynamic> contractData,
  ) async {
    try {
      isLoading(true);
      errorMessage('');

      final response = await _apiService.generateContract(
        requestId,
        contractData,
      );

      if (response['success'] == true && response['data'] != null) {
        final newContract = Contract.fromJson(response['data']);
        contracts.insert(0, newContract);
        return newContract;
      } else {
        throw Exception(response['message'] ?? 'Failed to generate contract');
      }
    } catch (e) {
      errorMessage(e.toString());
      print('Error generating contract: $e');
      rethrow;
    } finally {
      isLoading(false);
    }
  }

  Future<Contract> signContract(String contractId, String signatureData) async {
    try {
      isLoading(true);
      errorMessage('');

      final response = await _apiService.signContract(
        int.parse(contractId),
        signatureData,
      );

      if (response['success'] == true && response['data'] != null) {
        final updatedContract = Contract.fromJson(response['data']);

        // Update in list
        final index = contracts.indexWhere((c) => c.contractId == contractId);
        if (index != -1) {
          contracts[index] = updatedContract;
        }

        // Update current contract if it matches
        if (currentContract.value?.contractId == contractId) {
          currentContract.value = updatedContract;
        }

        return updatedContract;
      } else {
        throw Exception(response['message'] ?? 'Failed to sign contract');
      }
    } catch (e) {
      errorMessage(e.toString());
      print('Error signing contract: $e');
      rethrow;
    } finally {
      isLoading(false);
    }
  }

  Future<Map<String, dynamic>> verifyContract(String contractId) async {
    try {
      final response = await _apiService.verifyContract(contractId);

      if (response['success'] == true) {
        return response;
      } else {
        throw Exception(response['message'] ?? 'Failed to verify contract');
      }
    } catch (e) {
      print('Error verifying contract: $e');
      rethrow;
    }
  }

  Contract? getContractById(String id) {
    return contracts.firstWhereOrNull((c) => c.contractId == id);
  }

  Contract? getContractByRequestId(int requestId) {
    return contracts.firstWhereOrNull((c) => c.rentalRequestId == requestId);
  }

  List<Contract> get activeContracts {
    return contracts.where((c) => c.isActive).toList();
  }

  List<Contract> get pendingContracts {
    return contracts
        .where((c) => c.status.toLowerCase().contains('pending'))
        .toList();
  }

  List<Contract> get signedContracts {
    return contracts.where((c) => c.isFullySigned).toList();
  }

  String getContractStatusText(Contract contract) {
    return contract.statusText;
  }

  String getContractStatusColor(Contract contract) {
    return contract.statusColor;
  }

  Future<bool> canSignContract(String contractId) async {
    try {
      final contract = getContractById(contractId);
      if (contract == null) return false;

      // Get user role from auth controller
      final authController = Get.find<AuthController>();
      final userRole = authController.currentUser?.role.toLowerCase();

      if (userRole == 'tenant') {
        return !contract.isTenantSigned;
      } else if (userRole == 'landlord') {
        return !contract.isLandlordSigned;
      }

      return false;
    } catch (e) {
      print('Error checking contract signing eligibility: $e');
      return false;
    }
  }

  Future<bool> canGenerateContract(int rentalRequestId) async {
    try {
      // Check if user is landlord and has approved rental request
      final authController = Get.find<AuthController>();
      if (authController.currentUser?.role.toLowerCase() != 'landlord') {
        return false;
      }

      // Check if contract already exists for this request
      final existingContract = getContractByRequestId(rentalRequestId);
      if (existingContract != null) {
        return false;
      }

      return true;
    } catch (e) {
      print('Error checking contract generation eligibility: $e');
      return false;
    }
  }

  Future<String> getContractDownloadUrl(String contractId) async {
    try {
      final response = await _apiService.downloadContract(
        int.parse(contractId),
      );
      // This would typically return a download URL or handle the download
      return response['download_url'] ?? '';
    } catch (e) {
      print('Error getting contract download URL: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getContractQrCode(String contractId) async {
    try {
      final response = await _apiService.getContractQrCode(contractId);

      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['message'] ?? 'Failed to get QR code');
      }
    } catch (e) {
      print('Error getting contract QR code: $e');
      rethrow;
    }
  }
}
