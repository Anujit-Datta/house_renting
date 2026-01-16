import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:house_renting/controllers/tenant_controller.dart';

class MyRentalsScreen extends GetView<TenantController> {
  const MyRentalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Rentals'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // Navigate to Pay Rent? Or Dashboard
              Get.back(); // Standard behavior
            },
            icon: const Icon(Icons.dashboard_outlined),
            tooltip: 'Dashboard',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.activeRentals.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.home_outlined,
                  size: 80,
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
                  "You don't have any active rentals at the moment",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to Explore Properties (Guest Home / Tenant Home search)
                    Get.back();
                  },
                  icon: const Icon(Icons.search),
                  label: const Text('Browse Properties'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    backgroundColor: const Color(0xFF2C3E50),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        } else {
          // List of Active Rentals
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.activeRentals.length,
            itemBuilder: (context, index) {
              final rental = controller.activeRentals[index];
              return Card(
                child: ListTile(
                  title: Text(rental.propertyName),
                  subtitle: Text(rental.address),
                  trailing: Text(
                    rental.status,
                    style: TextStyle(
                      color: rental.status == 'Active'
                          ? Colors.green
                          : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        }
      }),
    );
  }
}
