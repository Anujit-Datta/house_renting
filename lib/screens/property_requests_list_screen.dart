import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:house_renting/controllers/rental_requests_controller.dart';
import 'package:house_renting/widgets/custom_app_bar.dart';

class PropertyRequestsListScreen extends StatelessWidget {
  final String propertyName;
  const PropertyRequestsListScreen({super.key, required this.propertyName});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RentalRequestsController>();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Requests for $propertyName',
        actions: const [],
      ),
      body: Obx(() {
        if (controller.tenantRequests.isEmpty) {
          return const Center(child: Text('No requests for this property.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.tenantRequests.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return _buildRequestCard(
              controller.tenantRequests[index],
              controller,
            );
          },
        );
      }),
    );
  }

  Widget _buildRequestCard(
    Map<String, dynamic> request,
    RentalRequestsController controller,
  ) {
    final bool isPending = request['status'] == 'Pending';

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
                  backgroundImage: NetworkImage(request['imageUrl']),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request['tenantName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Sent on ${request['date']}',
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
                    color: _getStatusColor(request['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: _getStatusColor(request['status']),
                    ),
                  ),
                  child: Text(
                    request['status'],
                    style: TextStyle(
                      color: _getStatusColor(request['status']),
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
                  child: _buildInfoItem('Occupation', request['occupation']),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Monthly Income',
                    'Tk ${request['income']}',
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
                    '${request['familyMembers']} Persons',
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
              request['message'],
              style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
            ),

            const SizedBox(height: 20),

            // Actions (Only if Pending)
            if (isPending)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => controller.declineRequest(request['id']),
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
                      onPressed: () => controller.acceptRequest(request['id']),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return const Color(0xFF27AE60);
      case 'Rejected':
        return const Color(0xFFC0392B);
      default:
        return const Color(0xFFF39C12);
    }
  }
}
