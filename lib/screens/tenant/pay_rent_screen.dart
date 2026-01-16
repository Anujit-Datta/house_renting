import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:house_renting/controllers/tenant_controller.dart';

class PayRentScreen extends StatefulWidget {
  const PayRentScreen({super.key});

  @override
  State<PayRentScreen> createState() => _PayRentScreenState();
}

class _PayRentScreenState extends State<PayRentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TenantController controller = Get.find<TenantController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
                  'Active Rentals',
                  '${controller.activeRentals.length}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInfoCard(
                  Icons.account_balance_wallet,
                  'Wallet Balance',
                  'Tk ${controller.walletBalance.value.toStringAsFixed(0)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Content
          Obx(() {
            if (controller.activeRentals.isEmpty) {
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
                        'No Active Rentals',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "You don't have any active rental agreements yet.",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Get.back(); // Or navigate to Explore
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
              itemCount: controller.activeRentals.length,
              itemBuilder: (context, index) {
                final rental = controller.activeRentals[index];
                return Card(
                  child: ListTile(
                    title: Text(rental.propertyName),
                    subtitle: Text('Due: Tk ${rental.rentAmount}'),
                    trailing: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Pay'),
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

  Widget _buildPaymentHistoryTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 60, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text(
            'No Payment History',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
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
