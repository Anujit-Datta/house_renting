import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:house_renting/controllers/rental_requests_controller.dart';
import 'package:house_renting/widgets/custom_app_bar.dart';
import 'package:house_renting/screens/property_requests_list_screen.dart';

class RentalRequestsScreen extends StatelessWidget {
  const RentalRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RentalRequestsController());

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Rental Requests',
        actions: const [], // No actions needed for this page
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Row(
              children: [
                Icon(
                  Icons.mark_email_unread,
                  color: Color(0xFF2C3E50),
                  size: 28,
                ),
                SizedBox(width: 12),
                Text(
                  'Rental Requests',
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
              'Manage tenant rental requests for your properties',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Stats Grid
            _buildStatsGrid(controller),
            const SizedBox(height: 32),

            // Property List
            Obx(
              () => ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.propertyRequests.length,
                itemBuilder: (context, index) {
                  final item = controller.propertyRequests[index];
                  return _buildPropertyRequestCard(item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(RentalRequestsController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Adapt grid based on screen width if needed, but for now fixed 4 cols or scrollable
        // For mobile, maybe 2x2. The design shows 4 in a row.
        // Let's use a Wrap or GridView that adapts.
        return GridView.count(
          crossAxisCount: constraints.maxWidth > 600 ? 4 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.1,
          children: [
            _buildStatCard(
              Icons.inbox,
              controller.stats['Total Requests']!,
              'Total Requests',
              const Color(0xFF2C3E50),
              Colors.white,
            ),
            _buildStatCard(
              Icons.access_time_filled,
              controller.stats['Pending Requests']!,
              'Pending Requests',
              const Color(0xFFF39C12),
              Colors.white,
            ),
            _buildStatCard(
              Icons.check_circle,
              controller.stats['Approved Requests']!,
              'Approved Requests',
              const Color(0xFF27AE60),
              Colors.white,
            ),
            _buildStatCard(
              Icons.business,
              controller.stats['Properties with Requests']!,
              'Properties with\nRequests',
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
        side: BorderSide(
          color: iconColor.withOpacity(0.5),
          width: 1,
        ), // Colored border left? Design has colored left border line style
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

  Widget _buildPropertyRequestCard(Map<String, dynamic> item) {
    final stats = item['stats'] as Map<String, dynamic>;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 300, // Fixed width card style from image? No, image shows list.
        // Wait, the image shows a vertical card with image on top.
        // Let's assume it's a grid of these property cards or a list.
        // I will make it a Column card.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                item['imageUrl'],
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['propertyName'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
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
                          item['location'],
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.home, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        item['propertyType'],
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '৳${item['rent']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF27AE60),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stats Row within card
                  Row(
                    children: [
                      _buildMiniStatBox(
                        'PENDING',
                        stats['pending'].toString(),
                        const Color(0xFFF39C12),
                      ),
                      const SizedBox(width: 8),
                      _buildMiniStatBox(
                        'APPROVED',
                        stats['approved'].toString(),
                        const Color(0xFF27AE60),
                      ),
                      const SizedBox(width: 8),
                      _buildMiniStatBox(
                        'REJECTED',
                        stats['rejected'].toString(),
                        const Color(0xFFC0392B),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.to(
                          () => PropertyRequestsListScreen(
                            propertyName: item['propertyName'],
                          ),
                        );
                      },
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('View All Requests'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C3E50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
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

  Widget _buildMiniStatBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
