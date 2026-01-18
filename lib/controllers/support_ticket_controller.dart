import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:house_renting/services/api_service.dart';

class TicketReply {
  final int id;
  final int ticketId;
  final int userId;
  final String message;
  final String? userName;
  final String? userRole;
  final DateTime createdAt;

  TicketReply({
    required this.id,
    required this.ticketId,
    required this.userId,
    required this.message,
    this.userName,
    this.userRole,
    required this.createdAt,
  });

  factory TicketReply.fromJson(Map<String, dynamic> json) {
    return TicketReply(
      id: json['id'] ?? 0,
      ticketId: json['ticket_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      message: json['message'] ?? '',
      userName: json['user']?['name'] ?? json['user_name'],
      userRole: json['user']?['role'] ?? json['user_role'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class SupportTicket {
  final int id;
  final String subject;
  final String message;
  final String status; // open, in_progress, resolved, closed
  final String priority; // low, medium, high
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<TicketReply> replies;

  SupportTicket({
    required this.id,
    required this.subject,
    required this.message,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.updatedAt,
    this.replies = const [],
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    List<TicketReply> replyList = [];
    if (json['replies'] != null && json['replies'] is List) {
      replyList = (json['replies'] as List)
          .map((r) => TicketReply.fromJson(r))
          .toList();
    }

    return SupportTicket(
      id: json['id'] ?? 0,
      subject: json['subject'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? 'open',
      priority: json['priority'] ?? 'medium',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      replies: replyList,
    );
  }

  String get statusText {
    switch (status.toLowerCase()) {
      case 'open':
        return 'Open';
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      case 'closed':
        return 'Closed';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.blue;
      case 'in_progress':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Color get priorityColor {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class SupportTicketController extends GetxController {
  final RxList<SupportTicket> tickets = <SupportTicket>[].obs;
  final Rxn<SupportTicket> currentTicket = Rxn<SupportTicket>();
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final ApiService _apiService = ApiService();

  // Pagination
  int _currentPage = 1;
  final int _perPage = 15;
  bool _hasMoreData = true;

  @override
  void onInit() {
    super.onInit();
    fetchTickets();
  }

  Future<void> fetchTickets({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreData = true;
      tickets.clear();
    }

    if (!_hasMoreData) return;

    try {
      isLoading(true);
      errorMessage('');

      final response = await _apiService.getSupportTickets(
        page: _currentPage,
        perPage: _perPage,
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> ticketData = response['data'];
        final List<SupportTicket> ticketList = ticketData
            .map((json) => SupportTicket.fromJson(json))
            .toList();

        if (refresh) {
          tickets.assignAll(ticketList);
        } else {
          tickets.addAll(ticketList);
        }

        // Check if there's more data
        if (ticketList.length < _perPage) {
          _hasMoreData = false;
        } else {
          _currentPage++;
        }
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch tickets');
      }
    } catch (e) {
      errorMessage(e.toString());
      print('Error fetching tickets: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> loadMore() async {
    if (!isLoading.value && _hasMoreData) {
      await fetchTickets();
    }
  }

  Future<void> fetchTicketDetails(int id) async {
    try {
      currentTicket.value = null;
      isLoading(true);
      errorMessage('');

      final response = await _apiService.getTicketDetails(id);

      if (response['success'] == true && response['data'] != null) {
        currentTicket.value = SupportTicket.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch ticket details');
      }
    } catch (e) {
      errorMessage(e.toString());
      print('Error fetching ticket details: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<SupportTicket?> createTicket({
    required String subject,
    required String message,
    String priority = 'medium',
  }) async {
    try {
      isLoading(true);
      errorMessage('');

      final response = await _apiService.createSupportTicket({
        'subject': subject,
        'message': message,
        'priority': priority,
      });

      if (response['success'] == true && response['data'] != null) {
        final newTicket = SupportTicket.fromJson(response['data']);
        tickets.insert(0, newTicket);

        Get.snackbar(
          'Success',
          'Support ticket created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        return newTicket;
      } else {
        throw Exception(response['message'] ?? 'Failed to create ticket');
      }
    } catch (e) {
      errorMessage(e.toString());
      print('Error creating ticket: $e');
      Get.snackbar(
        'Error',
        'Failed to create ticket',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    } finally {
      isLoading(false);
    }
  }

  Future<bool> replyToTicket(int ticketId, String message) async {
    try {
      final response = await _apiService.replyToTicket(ticketId, message);

      if (response['success'] == true) {
        // Refresh ticket details to get the new reply
        await fetchTicketDetails(ticketId);

        Get.snackbar(
          'Success',
          'Reply sent successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        return true;
      } else {
        throw Exception(response['message'] ?? 'Failed to send reply');
      }
    } catch (e) {
      print('Error replying to ticket: $e');
      Get.snackbar(
        'Error',
        'Failed to send reply',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<bool> updateTicketStatus(int ticketId, String status) async {
    try {
      final response = await _apiService.updateTicketStatus(ticketId, status);

      if (response['success'] == true && response['data'] != null) {
        final updatedTicket = SupportTicket.fromJson(response['data']);

        // Update in list
        final index = tickets.indexWhere((t) => t.id == ticketId);
        if (index != -1) {
          tickets[index] = updatedTicket;
        }

        // Update current ticket if it matches
        if (currentTicket.value?.id == ticketId) {
          currentTicket.value = updatedTicket;
        }

        Get.snackbar(
          'Success',
          'Ticket status updated',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        return true;
      }
      return false;
    } catch (e) {
      print('Error updating ticket status: $e');
      Get.snackbar(
        'Error',
        'Failed to update ticket status',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  SupportTicket? getTicketById(int id) {
    return tickets.firstWhereOrNull((t) => t.id == id);
  }

  List<SupportTicket> get openTickets {
    return tickets.where((t) => t.status.toLowerCase() == 'open').toList();
  }

  List<SupportTicket> get inProgressTickets {
    return tickets.where((t) => t.status.toLowerCase() == 'in_progress').toList();
  }

  List<SupportTicket> get resolvedTickets {
    return tickets.where((t) => t.status.toLowerCase() == 'resolved').toList();
  }

  List<SupportTicket> get closedTickets {
    return tickets.where((t) => t.status.toLowerCase() == 'closed').toList();
  }

  Map<String, int> get ticketStats {
    return {
      'Total': tickets.length,
      'Open': openTickets.length,
      'In Progress': inProgressTickets.length,
      'Resolved': resolvedTickets.length,
      'Closed': closedTickets.length,
    };
  }
}
