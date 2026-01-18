import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:house_renting/controllers/rental_requests_controller.dart';
import 'package:house_renting/models.dart';
import 'package:house_renting/widgets/custom_app_bar.dart';

class PropertyRequestsListScreen extends StatelessWidget {
  final String propertyName;
  const PropertyRequestsListScreen({super.key, required this.propertyName});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RentalRequestController>();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Requests for $propertyName',
        actions: const [],
      ),
      body: Obx(() {
        if (controller.requests.isEmpty) {
          return const Center(child: Text('No requests for this property.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.requests.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return _buildRequestCard(controller.requests[index], controller);
          },
        );
      }),
    );
  }

  Widget _buildRequestCard(
    RentalRequest request,
    RentalRequestController controller,
  ) {
    final bool isPending = request.status.toLowerCase() == 'pending';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar + Name + Status
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: const NetworkImage(
                    'https://via.placeholder.com/150',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unknown Tenant', // Placeholder - implement tenant name
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Sent on 2024-01-01', // Placeholder - implement date
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Color(
                      int.parse(request.statusColor.replaceFirst('#', '0xFF')),
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Color(
                        int.parse(
                          request.statusColor.replaceFirst('#', '0xFF'),
                        ),
                      ),
                    ),
                  ),
                  child: Text(
                    request.statusText,
                    style: TextStyle(
                      color: Color(
                        int.parse(
                          request.statusColor.replaceFirst('#', '0xFF'),
                        ),
                      ),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Details Grid
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Occupation', 'Unknown'), // Placeholder
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Monthly Income',
                    'Tk 0', // Placeholder
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Family Members',
                    '0 Persons', // Placeholder
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Text(
              'Message:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'No message available', // Placeholder - implement message
              style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
            ),

            const SizedBox(height: 20),

            // Actions (Only if Pending)
            if (isPending)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          _handleDeclineRequest(request, controller),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          _handleAcceptRequest(request, controller),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF27AE60),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }

  void _handleAcceptRequest(
    RentalRequest request,
    RentalRequestController controller,
  ) {
    try {
      final updatedRequest = request.copyWith(status: 'accepted');
      controller.updateRequest(updatedRequest);
      Get.snackbar('Success', 'Request accepted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to accept request: ${e.toString()}');
    }
  }

  void _handleDeclineRequest(
    RentalRequest request,
    RentalRequestController controller,
  ) {
    try {
      final updatedRequest = request.copyWith(status: 'rejected');
      controller.updateRequest(updatedRequest);
      Get.snackbar('Success', 'Request declined successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to decline request: ${e.toString()}');
    }
  }
}
