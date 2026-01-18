import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:house_renting/controllers/tenant_controller.dart';
import 'package:house_renting/controllers/payment_controller.dart';
import 'package:house_renting/controllers/contract_controller.dart';

class PayRentScreen extends StatefulWidget {
  const PayRentScreen({super.key});

  @override
  State<PayRentScreen> createState() => _PayRentScreenState();
}

class _PayRentScreenState extends State<PayRentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TenantController tenantController = Get.find<TenantController>();
  final PaymentController paymentController = Get.find<PaymentController>();
  final ContractController contractController = Get.find<ContractController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Refresh payment data
    paymentController.fetchPayments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay Rent'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2C3E50),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF2C3E50),
          tabs: const [
            Tab(text: 'Active Rentals'),
            Tab(text: 'Payment History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Active Rentals
          _buildActiveRentalsTab(),

          // Tab 2: Payment History
          _buildPaymentHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildActiveRentalsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Stats Row
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  Icons.home,
                  'Active Contracts',
                  '${contractController.activeContracts.length}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Obx(() => _buildInfoCard(
                  Icons.account_balance_wallet,
                  'Wallet Balance',
                  'Tk ${tenantController.walletBalance.value.toStringAsFixed(0)}',
                )),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Content - Show active contracts
          Obx(() {
            final activeContracts = contractController.contracts
                .where((c) => c.isFullySigned || c.status.toLowerCase() == 'active')
                .toList();

            if (activeContracts.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.home,
                        size: 60,
                        color: Colors.grey.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No Active Contracts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "You don't have any active rental contracts yet.",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Get.back();
                        },
                        icon: const Icon(Icons.search),
                        label: const Text('Browse Properties'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C3E50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activeContracts.length,
              itemBuilder: (context, index) {
                final contract = activeContracts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                contract.propertyName ?? 'Property',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                contract.statusText,
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Monthly Rent: Tk ${contract.monthlyRent.toStringAsFixed(0)}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Contract: ${contract.contractId}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _showPaymentDialog(contract),
                              icon: const Icon(Icons.payment, size: 18),
                              label: const Text('Pay Rent'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2C3E50),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  void _showPaymentDialog(dynamic contract) {
    final amountController = TextEditingController(
      text: contract.monthlyRent.toStringAsFixed(0),
    );
    String selectedMethod = 'wallet';

    Get.dialog(
      AlertDialog(
        title: const Text('Pay Rent'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Property: ${contract.propertyName ?? "Property"}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount (Tk)',
                  border: OutlineInputBorder(),
                  prefixText: 'Tk ',
                ),
              ),
              const SizedBox(height: 16),
              const Text('Payment Method:'),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      RadioListTile<String>(
                        title: const Text('Wallet'),
                        subtitle: Obx(() => Text(
                          'Balance: Tk ${tenantController.walletBalance.value.toStringAsFixed(0)}',
                        )),
                        value: 'wallet',
                        groupValue: selectedMethod,
                        onChanged: (value) {
                          setState(() => selectedMethod = value!);
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('Bank Transfer'),
                        value: 'bank_transfer',
                        groupValue: selectedMethod,
                        onChanged: (value) {
                          setState(() => selectedMethod = value!);
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('Mobile Banking'),
                        value: 'mobile_banking',
                        groupValue: selectedMethod,
                        onChanged: (value) {
                          setState(() => selectedMethod = value!);
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('Cash'),
                        value: 'hand_cash',
                        groupValue: selectedMethod,
                        onChanged: (value) {
                          setState(() => selectedMethod = value!);
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          Obx(() => ElevatedButton(
            onPressed: paymentController.isLoading.value
                ? null
                : () async {
                    final amount = double.tryParse(amountController.text) ?? 0;
                    if (amount <= 0) {
                      Get.snackbar(
                        'Error',
                        'Please enter a valid amount',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }

                    try {
                      await paymentController.createPayment({
                        'contract_id': int.tryParse(contract.id) ?? 0,
                        'amount': amount,
                        'payment_method': selectedMethod,
                        'payment_month': DateTime.now().toIso8601String(),
                      });
                      Get.back();
                      Get.snackbar(
                        'Success',
                        'Payment submitted successfully',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                      // Refresh wallet balance
                      tenantController.fetchTenantData();
                    } catch (e) {
                      Get.snackbar(
                        'Error',
                        'Failed to submit payment',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  },
            child: paymentController.isLoading.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Submit Payment'),
          )),
        ],
      ),
    );
  }

  Widget _buildPaymentHistoryTab() {
    return Obx(() {
      if (paymentController.isLoading.value && paymentController.payments.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (paymentController.payments.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: 60, color: Colors.grey.withOpacity(0.3)),
              const SizedBox(height: 16),
              const Text(
                'No Payment History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your payment history will appear here',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => paymentController.fetchPayments(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: paymentController.payments.length,
          itemBuilder: (context, index) {
            final payment = paymentController.payments[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getStatusColor(payment.status).withOpacity(0.1),
                  child: Icon(
                    _getStatusIcon(payment.status),
                    color: _getStatusColor(payment.status),
                    size: 20,
                  ),
                ),
                title: Text(
                  'Tk ${payment.amount.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(payment.paymentMethodText),
                    Text(
                      payment.paymentDate?.toString().substring(0, 10) ??
                          payment.createdAt.toString().substring(0, 10),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(payment.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    payment.statusText,
                    style: TextStyle(
                      color: _getStatusColor(payment.status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onTap: () {
                  // Show payment details
                  _showPaymentDetails(payment);
                },
              ),
            );
          },
        ),
      );
    });
  }

  void _showPaymentDetails(dynamic payment) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Payment Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildDetailRow('Amount', 'Tk ${payment.amount.toStringAsFixed(0)}'),
            _buildDetailRow('Status', payment.statusText),
            _buildDetailRow('Method', payment.paymentMethodText),
            _buildDetailRow(
              'Date',
              payment.paymentDate?.toString().substring(0, 10) ??
                  payment.createdAt.toString().substring(0, 10),
            ),
            if (payment.transactionId != null)
              _buildDetailRow('Transaction ID', payment.transactionId!),
            const SizedBox(height: 16),
            if (payment.hasReceipt)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await paymentController.downloadReceipt(payment.id);
                      Get.snackbar(
                        'Success',
                        'Receipt downloaded',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    } catch (e) {
                      Get.snackbar(
                        'Error',
                        'Failed to download receipt',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Download Receipt'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C3E50),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'paid':
        return Icons.check_circle;
      case 'pending':
        return Icons.hourglass_empty;
      case 'rejected':
      case 'failed':
        return Icons.cancel;
      default:
        return Icons.payment;
    }
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2C3E50), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
