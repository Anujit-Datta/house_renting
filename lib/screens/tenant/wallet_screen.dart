import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:house_renting/controllers/tenant_controller.dart';

class WalletScreen extends GetView<TenantController> {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Wallet'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Balance Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF2C3E50), // Navy Blue
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Balance',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => Text(
                      'Tk ${controller.walletBalance.value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Add Money Logic (Dialog)
                      Get.defaultDialog(
                        title: 'Add Money',
                        content: const Text(
                          'Payment Gateway Integration Pending',
                        ),
                        textConfirm: 'OK',
                        confirmTextColor: Colors.white,
                        onConfirm: () {
                          controller.addMoney(5000); // Simulate adding
                          Get.back();
                        },
                      );
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Add Money'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2C3E50),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Added',
                    controller.totalAdded,
                    Icons.arrow_downward,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Total Spent',
                    controller.totalSpent,
                    Icons.arrow_upward,
                    Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Text(
              'Recent Transactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Obx(() {
              if (controller.transactions.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 60,
                          color: Colors.grey.withOpacity(0.3),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'No transactions yet',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.transactions.length,
                itemBuilder: (context, index) {
                  final tx = controller.transactions[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: tx.isCredit
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      child: Icon(
                        tx.isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                        color: tx.isCredit ? Colors.green : Colors.red,
                        size: 20,
                      ),
                    ),
                    title: Text(tx.description),
                    subtitle: Text(tx.date.toString().substring(0, 10)),
                    trailing: Text(
                      '${tx.isCredit ? '+' : '-'} Tk ${tx.amount.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: tx.isCredit ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    RxDouble valueRx,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Obx(
            () => Text(
              'Tk ${valueRx.value.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
