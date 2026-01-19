import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:house_renting/controllers/rental_requests_controller.dart';
import 'package:house_renting/models.dart';
import 'package:house_renting/widgets/custom_app_bar.dart';

class RentalRequestsScreen extends StatefulWidget {
  const RentalRequestsScreen({super.key});

  @override
  State<RentalRequestsScreen> createState() => _RentalRequestsScreenState();
}

class _RentalRequestsScreenState extends State<RentalRequestsScreen> {
  // Track individual request loading states for approve/reject actions
  final RxSet<String> _loadingActions = <String>{}.obs;
  late final RentalRequestController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(RentalRequestController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Rental Requests',
        actions: const [], // No actions needed for this page
      ),
      body: Obx(
        () => _controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async {
                  await _controller.fetchRentalRequests();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Stats Grid
                    _buildStatsGrid(_controller),
                    const SizedBox(height: 32),

                    // Requests List
                    if (_controller.requests.isEmpty)
                      _buildEmptyState()
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _controller.requests.length,
                        itemBuilder: (context, index) {
                          final request = _controller.requests[index];
                          return _buildRequestCard(request);
                        },
                      ),
                  ],
                ),
                ),
              ),
      ),
    );
  }

  Widget _buildStatsGrid(RentalRequestController controller) {
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
              controller.getTotalRequests().toString(),
              'Total Requests',
              const Color(0xFF2C3E50),
              Colors.white,
            ),
            _buildStatCard(
              Icons.access_time_filled,
              controller.getPendingCount().toString(),
              'Pending Requests',
              const Color(0xFFF39C12),
              Colors.white,
            ),
            _buildStatCard(
              Icons.check_circle,
              controller.getAcceptedCount().toString(),
              'Approved Requests',
              const Color(0xFF27AE60),
              Colors.white,
            ),
            _buildStatCard(
              Icons.business,
              controller.getPropertiesWithRequestsCount().toString(),
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

  Widget _buildEmptyState() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No Rental Requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No rental requests found for your properties yet.',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(RentalRequest request) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Request Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(
                      int.parse(request.statusColor.replaceFirst('#', '0xFF')),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.request_page,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.propertyName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      Text(
                        'Tenant: ${request.tenantName}',
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
                      int.parse(request.statusColor.replaceFirst('#', '0xFF')),
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
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
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(
                        int.parse(
                          request.statusColor.replaceFirst('#', '0xFF'),
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
                    request.property['location'] ?? 'Unknown Location',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Rental Terms
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Move-in: ${request.formattedMoveInDate}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(width: 16),
                if (request.rentalDuration != null) ...[
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${request.rentalDuration} months',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
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
                          'Monthly Rent',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          request.monthlyRent != null ? 'Tk ${request.monthlyRent!.toStringAsFixed(0)}' : 'N/A',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF27AE60),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action Buttons
            if (request.status.toLowerCase() == 'pending')
              Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _loadingActions.contains('approve_${request.id}')
                            ? null
                            : () => _handleApproveRequest(request),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF27AE60),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.green.shade300,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _loadingActions.contains('approve_${request.id}')
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Approve'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _loadingActions.contains('reject_${request.id}')
                            ? null
                            : () => _handleRejectRequest(request),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE74C3C),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.red.shade300,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _loadingActions.contains('reject_${request.id}')
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Reject'),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  request.statusText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleApproveRequest(RentalRequest request) async {
    print('********** APPROVE REQUEST DEBUG START **********');
    print('Approving rental request ID: ${request.id}');
    print('Current status: ${request.status}');
    print('Tenant: ${request.tenantName}');
    print('Property: ${request.propertyName}');
    print('********** APPROVE REQUEST DEBUG END **********');

    // Add to loading set with specific action key
    _loadingActions.add('approve_${request.id}');

    try {
      // Call the API through controller
      final updatedRequest = await _controller.approveRentalRequest(request.id);

      print('********** APPROVE REQUEST RESPONSE START **********');
      print('Request approved successfully');
      print('New status: ${updatedRequest.status}');
      print('********** APPROVE REQUEST RESPONSE END **********');

      if (mounted) {
        Get.snackbar(
          'Success',
          'Rental request approved successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('********** APPROVE REQUEST ERROR START **********');
      print('Error approving request: $e');
      print('Stack trace: ${StackTrace.current}');
      print('********** APPROVE REQUEST ERROR END **********');

      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to approve request: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      // Remove from loading set
      _loadingActions.remove('approve_${request.id}');
    }
  }

  void _handleRejectRequest(RentalRequest request) async {
    print('********** REJECT REQUEST DEBUG START **********');
    print('Rejecting rental request ID: ${request.id}');
    print('Current status: ${request.status}');
    print('Tenant: ${request.tenantName}');
    print('Property: ${request.propertyName}');
    print('********** REJECT REQUEST DEBUG END **********');

    // Add to loading set with specific action key
    _loadingActions.add('reject_${request.id}');

    try {
      // Call the API through controller
      final updatedRequest = await _controller.rejectRentalRequest(request.id);

      print('********** REJECT REQUEST RESPONSE START **********');
      print('Request rejected successfully');
      print('New status: ${updatedRequest.status}');
      print('********** REJECT REQUEST RESPONSE END **********');

      if (mounted) {
        Get.snackbar(
          'Success',
          'Rental request rejected successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('********** REJECT REQUEST ERROR START **********');
      print('Error rejecting request: $e');
      print('Stack trace: ${StackTrace.current}');
      print('********** REJECT REQUEST ERROR END **********');

      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to reject request: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      // Remove from loading set
      _loadingActions.remove('reject_${request.id}');
    }
  }
}
