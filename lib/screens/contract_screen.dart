import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:house_renting/controllers/contract_controller.dart';
import 'package:house_renting/models.dart';
import 'package:house_renting/widgets/custom_app_bar.dart';

class ContractScreen extends StatelessWidget {
  const ContractScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ContractController());

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Contracts',
        actions: const [], // No actions needed for this page
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    const Row(
                      children: [
                        Icon(
                          Icons.description,
                          color: Color(0xFF2C3E50),
                          size: 28,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Contracts',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage your rental contracts',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Contract List
                    if (controller.contracts.isEmpty)
                      _buildEmptyState()
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.contracts.length,
                        itemBuilder: (context, index) {
                          final contract = controller.contracts[index];
                          return _buildContractCard(contract, controller);
                        },
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No Contracts Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No contracts found for your properties yet.',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContractCard(Contract contract, ContractController controller) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contract Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(
                      int.parse(contract.statusColor.replaceFirst('#', '0xFF')),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.description, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contract #${contract.contractId}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      Text(
                        'Property: ${contract.property?['property_name'] ?? 'Unknown Property'}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Color(
                      int.parse(contract.statusColor.replaceFirst('#', '0xFF')),
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Color(
                        int.parse(
                          contract.statusColor.replaceFirst('#', '0xFF'),
                        ),
                      ),
                    ),
                  ),
                  child: Text(
                    contract.statusText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(
                        int.parse(
                          contract.statusColor.replaceFirst('#', '0xFF'),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Property Details
            Row(
              children: [
                const Icon(Icons.home, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    contract.property?['location'] ?? 'Unknown Location',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Contract Terms
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'From: ${contract.formattedStartDate}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.date_range, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'To: ${contract.formattedEndDate}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Financial Details
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Monthly Rent',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          contract.formattedMonthlyRent,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF27AE60),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Security Deposit',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          contract.formattedSecurityDeposit,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF39C12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Signatures Status
            Row(
              children: [
                Expanded(
                  child: _buildSignatureStatus(
                    'Tenant',
                    contract.isTenantSigned,
                    Icons.person,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSignatureStatus(
                    'Landlord',
                    contract.isLandlordSigned,
                    Icons.business,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action Buttons
            if (!contract.isFullySigned)
              Row(
                children: [
                  if (!contract.isTenantSigned && _isUserTenant(contract))
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            _handleSignContract(contract, controller),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF27AE60),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Sign Contract'),
                      ),
                    )
                  else if (!contract.isLandlordSigned &&
                      _isUserLandlord(contract))
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            _handleSignContract(contract, controller),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF27AE60),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Sign Contract'),
                      ),
                    )
                  else
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Waiting for ${!contract.isTenantSigned ? 'Tenant' : 'Landlord'} signature',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _handleViewDetails(contract, controller),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2C3E50),
                        side: const BorderSide(color: Color(0xFF2C3E50)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('View Details'),
                    ),
                  ),
                ],
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF27AE60),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Fully Signed - ${contract.statusText}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF27AE60),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignatureStatus(String role, bool isSigned, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSigned
            ? Colors.green.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSigned ? const Color(0xFF27AE60) : Colors.grey,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isSigned ? const Color(0xFF27AE60) : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            role,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSigned ? const Color(0xFF27AE60) : Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            isSigned ? Icons.check_circle : Icons.circle_outlined,
            color: isSigned ? const Color(0xFF27AE60) : Colors.grey,
            size: 16,
          ),
        ],
      ),
    );
  }

  bool _isUserTenant(Contract contract) {
    // This would check the current user's role from AuthController
    // For now, return false - implement proper role checking
    return false;
  }

  bool _isUserLandlord(Contract contract) {
    // This would check the current user's role from AuthController
    // For now, return false - implement proper role checking
    return false;
  }

  void _handleSignContract(
    Contract contract,
    ContractController controller,
  ) async {
    try {
      // In a real app, this would open a signature pad
      final signature =
          'placeholder_signature_${DateTime.now().millisecondsSinceEpoch}';

      await controller.signContract(contract.contractId, signature);
      Get.snackbar('Success', 'Contract signed successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign contract: ${e.toString()}');
    }
  }

  void _handleViewDetails(
    Contract contract,
    ContractController controller,
  ) async {
    try {
      await controller.fetchContractDetails(contract.contractId);

      // Navigate to contract details screen
      // Get.to(() => ContractDetailsScreen(contract: contract));

      // For now, show snackbar
      Get.snackbar('Contract Details', 'Contract ID: ${contract.contractId}');
    } catch (e) {
      Get.snackbar('Error', 'Failed to load contract details: ${e.toString()}');
    }
  }
}
