import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:house_renting/controllers/auth_controller.dart';
import 'package:house_renting/controllers/landlord_controller.dart';
import 'package:house_renting/widgets/custom_app_bar.dart';
import 'package:house_renting/screens/add_property_screen.dart';
import 'package:house_renting/widgets/edit_property_dialog.dart';
import 'package:house_renting/screens/rental_requests_screen.dart';
import 'package:house_renting/screens/landlord_wallet_screen.dart';

class LandlordHomeScreen extends GetView<LandlordController> {
  const LandlordHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Force fetch if empty (ensures data is present after hot reload)
    if (controller.stats.isEmpty) {
      controller.fetchDashboardData();
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Landlord Dashboard',
        actions: [_buildAvatarMenu(), const SizedBox(width: 16)],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatsGrid(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Properties',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Get.to(() => const AddPropertyScreen()),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add New'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C3E50),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildPropertyList(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Rentals',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'View All',
                      style: TextStyle(color: Color(0xFF2C3E50)),
                    ),
                  ),
                ],
              ),
              // Placeholder for Recent Rentals list
              const SizedBox(height: 100), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarMenu() {
    return GetBuilder<AuthController>(
      builder: (auth) {
        final user = auth.currentUser;
        return PopupMenuButton<String>(
          offset: const Offset(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (value) {
            switch (value) {
              case 'requests':
                Get.to(() => const RentalRequestsScreen());
                break;
              case 'wallet':
                Get.to(() => const LandlordWalletScreen());
                break;
              case 'logout':
                auth.logout();
                break;
            }
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(
                  user?.photoUrl ??
                      'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80',
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.keyboard_arrow_down,
                color: Get.theme.iconTheme.color,
                size: 20,
              ),
            ],
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              enabled: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? 'Landlord',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user?.email ?? 'rakib12@gmail.com',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const Divider(),
                ],
              ),
            ),
            _buildMenuItem(Icons.dashboard, 'Dashboard'),
            PopupMenuItem(
              value: 'requests',
              child: Row(
                children: [
                  Icon(Icons.mail, size: 20, color: Colors.grey.shade700),
                  const SizedBox(width: 12),
                  const Text('Requests'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'wallet',
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    size: 20,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(width: 12),
                  const Text('Wallet'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.red, size: 20),
                  SizedBox(width: 12),
                  Text('Log Out', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  PopupMenuItem<String> _buildMenuItem(IconData icon, String text) {
    return PopupMenuItem(
      value: text.toLowerCase(),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade700),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = controller.stats;
    return Column(
      children: [
        Row(
          children: [
            _buildSimpleStatCard(
              'Total Properties',
              stats['Total Properties'] ?? '0',
            ),
            const SizedBox(width: 16),
            _buildSimpleStatCard(
              'Total Rentals',
              stats['Total Rentals'] ?? '0',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildSimpleStatCard(
              'Active Rentals',
              stats['Active Rentals'] ?? '0',
            ),
            const SizedBox(width: 16),
            _buildSimpleStatCard(
              'Monthly Revenue',
              stats['Monthly Revenue'] ?? 'Tk 0',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSimpleStatCard(String title, String value) {
    return Expanded(
      child: Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        );
      }
      if (controller.myProperties.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text('No properties listed yet.'),
          ),
        );
      }
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.myProperties.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final property = controller.myProperties[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.network(
                    property.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, st) => Container(
                      height: 180,
                      color: Colors.grey.shade200,
                      child: const Center(child: Icon(Icons.broken_image)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        property.price,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF27AE60), // Green for price
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              property.location,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildSpecItem(Icons.bed, '${property.beds} Bed'),
                          const SizedBox(width: 16),
                          _buildSpecItem(
                            Icons.bathtub,
                            '${property.baths} Bath',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.home, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          const Text(
                            'Apartment', // Static for now, can come from model
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Get.dialog(
                                  EditPropertyDialog(property: property),
                                );
                              },
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text('Edit'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2C3E50),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.delete, size: 16),
                              label: const Text('Delete'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC0392B), // Red
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildSpecItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
