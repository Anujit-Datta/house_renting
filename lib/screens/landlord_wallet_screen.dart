import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:house_renting/controllers/landlord_wallet_controller.dart';
import 'package:house_renting/widgets/custom_app_bar.dart';

class LandlordWalletScreen extends StatelessWidget {
  const LandlordWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LandlordWalletController());

    return Scaffold(
      appBar: CustomAppBar(title: 'My Wallet', actions: const []),
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
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
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Withdraw Logic (Dialog)
                            Get.defaultDialog(
                              title: 'Withdraw Funds',
                              content: const Text(
                                'Withdrawal to linked bank account?',
                              ),
                              textConfirm: 'Confirm',
                              textCancel: 'Cancel',
                              confirmTextColor: Colors.white,
                              onConfirm: () {
                                controller.withdrawMoney(
                                  5000,
                                ); // Simulate withdrawal
                                Get.back();
                              },
                            );
                          },
                          icon: const Icon(Icons.account_balance_wallet),
                          label: const Text('Withdraw'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF2C3E50),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Earnings',
                    controller.totalEarnings,
                    Icons.monetization_on,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Total Withdrawn',
                    controller.totalWithdrawn,
                    Icons.outbond,
                    Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
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
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.transactions.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final tx = controller.transactions[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: tx.isCredit
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      child: Icon(
                        tx.isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                        color: tx.isCredit ? Colors.green : Colors.orange,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      tx.description,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      tx.date.toString().substring(0, 10),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    trailing: Text(
                      '${tx.isCredit ? '+' : '-'} Tk ${tx.amount.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: tx.isCredit ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
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
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Obx(
            () => Text(
              'Tk ${valueRx.value.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
