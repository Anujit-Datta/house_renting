import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:house_renting/controllers/payment_controller.dart';
import 'package:house_renting/models.dart';
import 'package:house_renting/widgets/custom_app_bar.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PaymentController());

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Payments',
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
                        Icon(Icons.payment, color: Color(0xFF2C3E50), size: 28),
                        SizedBox(width: 12),
                        Text(
                          'Payments',
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
                      'Manage your rental payments',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Stats Grid
                    _buildStatsGrid(controller),
                    const SizedBox(height: 32),

                    // Payment List
                    if (controller.payments.isEmpty)
                      _buildEmptyState()
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.payments.length,
                        itemBuilder: (context, index) {
                          final payment = controller.payments[index];
                          return _buildPaymentCard(payment, controller);
                        },
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatsGrid(PaymentController controller) {
    final stats = controller.paymentStats;
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.count(
          crossAxisCount: constraints.maxWidth > 600 ? 3 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.1,
          children: [
            _buildStatCard(
              Icons.monetization_on,
              controller.totalAmount.toStringAsFixed(0),
              'Total Amount',
              const Color(0xFF2C3E50),
              Colors.white,
            ),
            _buildStatCard(
              Icons.hourglass_top,
              stats['Pending'].toString(),
              'Pending',
              const Color(0xFFF39C12),
              Colors.white,
            ),
            _buildStatCard(
              Icons.check_circle,
              stats['Confirmed'].toString(),
              'Confirmed',
              const Color(0xFF27AE60),
              Colors.white,
            ),
            _buildStatCard(
              Icons.receipt,
              stats['With Receipt'].toString(),
              'With Receipt',
              Colors.blue.shade700,
              Colors.white,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String value,
    String label,
    Color iconColor,
    Color bgColor,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: iconColor.withOpacity(0.5), width: 1),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: iconColor, width: 4)),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
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
            Icon(Icons.payment_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No Payments Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No payment records found for your properties yet.',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(Payment payment, PaymentController controller) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(
                      int.parse(payment.statusColor.replaceFirst('#', '0xFF')),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.payment, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unknown Property', // payment.property?['property_name'] - Need to implement property relationship
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      Text(
                        'Payment - Online', // ${payment.formattedPaymentDate} - ${payment.paymentMethodText} - Need to implement these getters
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
                      int.parse(payment.statusColor.replaceFirst('#', '0xFF')),
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Color(
                        int.parse(
                          payment.statusColor.replaceFirst('#', '0xFF'),
                        ),
                      ),
                    ),
                  ),
                  child: Text(
                    payment.statusText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(
                        int.parse(
                          payment.statusColor.replaceFirst('#', '0xFF'),
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
                    payment.metadata?['location'] ?? 'Unknown Location',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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
                          'Payment Amount',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tk ${payment.amount.toStringAsFixed(0)}', // payment.formattedAmount - Need to implement this getter
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF27AE60),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (payment.hasReceipt)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Receipt',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'REC-${payment.id.toString().padLeft(6, '0')}', // payment.receiptNumber - Need to implement this getter
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Action Buttons
            if (payment.isPending && _isUserLandlord(payment))
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          _handleConfirmPayment(payment, controller),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF27AE60),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Confirm'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          _handleRejectPayment(payment, controller),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE74C3C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                ],
              )
            else if (payment.hasReceipt)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          _handleDownloadReceipt(payment, controller),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2C3E50),
                        side: const BorderSide(color: Color(0xFF2C3E50)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Download Receipt'),
                    ),
                  ),
                ],
              )
            else if (payment.isConfirmed)
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
                      'Payment Confirmed',
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

  bool _isUserLandlord(Payment payment) {
    // This would check the current user's role from AuthController
    // For now, return false - implement proper role checking
    return false;
  }

  void _handleConfirmPayment(
    Payment payment,
    PaymentController controller,
  ) async {
    try {
      await controller.confirmPayment(payment.id);
      Get.snackbar('Success', 'Payment confirmed successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to confirm payment: ${e.toString()}');
    }
  }

  void _handleRejectPayment(
    Payment payment,
    PaymentController controller,
  ) async {
    try {
      await controller.rejectPayment(payment.id);
      Get.snackbar('Success', 'Payment rejected successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to reject payment: ${e.toString()}');
    }
  }

  void _handleDownloadReceipt(
    Payment payment,
    PaymentController controller,
  ) async {
    try {
      await controller.downloadReceipt(payment.id);
      Get.snackbar('Success', 'Receipt downloaded successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to download receipt: ${e.toString()}');
    }
  }
}
