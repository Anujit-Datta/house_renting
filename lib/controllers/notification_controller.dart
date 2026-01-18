import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:house_renting/services/api_service.dart';

class AppNotification {
  final int id;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? 0,
      type: json['type'] ?? 'general',
      title: json['title'] ?? 'Notification',
      message: json['message'] ?? '',
      isRead: json['is_read'] == true || json['is_read'] == 1,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      data: json['data'],
    );
  }

  IconData get icon {
    switch (type.toLowerCase()) {
      case 'payment':
        return Icons.payment;
      case 'contract':
        return Icons.description;
      case 'request':
        return Icons.home_work;
      case 'message':
        return Icons.message;
      case 'review':
        return Icons.star;
      default:
        return Icons.notifications;
    }
  }

  Color get iconColor {
    switch (type.toLowerCase()) {
      case 'payment':
        return Colors.green;
      case 'contract':
        return Colors.blue;
      case 'request':
        return Colors.orange;
      case 'message':
        return Colors.purple;
      case 'review':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}

class NotificationController extends GetxController {
  final RxList<AppNotification> notifications = <AppNotification>[].obs;
  final RxInt unreadCount = 0.obs;
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
    fetchNotifications();
  }

  Future<void> fetchNotifications({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreData = true;
      notifications.clear();
    }

    if (!_hasMoreData) return;

    try {
      isLoading(true);
      errorMessage('');

      final response = await _apiService.getNotifications(
        page: _currentPage,
        perPage: _perPage,
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> notifData = response['data'];
        final List<AppNotification> notifList = notifData
            .map((json) => AppNotification.fromJson(json))
            .toList();

        if (refresh) {
          notifications.assignAll(notifList);
        } else {
          notifications.addAll(notifList);
        }

        // Update unread count
        unreadCount.value = notifications.where((n) => !n.isRead).length;

        // Check if there's more data
        if (notifList.length < _perPage) {
          _hasMoreData = false;
        } else {
          _currentPage++;
        }
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch notifications');
      }
    } catch (e) {
      errorMessage(e.toString());
      print('Error fetching notifications: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> loadMore() async {
    if (!isLoading.value && _hasMoreData) {
      await fetchNotifications();
    }
  }

  Future<bool> markAsRead(int notificationId) async {
    try {
      final response = await _apiService.markNotificationAsRead(notificationId);

      if (response['success'] == true) {
        // Update local notification
        final index = notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          final notif = notifications[index];
          notifications[index] = AppNotification(
            id: notif.id,
            type: notif.type,
            title: notif.title,
            message: notif.message,
            isRead: true,
            createdAt: notif.createdAt,
            data: notif.data,
          );

          // Update unread count
          unreadCount.value = notifications.where((n) => !n.isRead).length;
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      final response = await _apiService.markAllNotificationsAsRead();

      if (response['success'] == true) {
        // Update all local notifications
        final updatedList = notifications.map((notif) => AppNotification(
          id: notif.id,
          type: notif.type,
          title: notif.title,
          message: notif.message,
          isRead: true,
          createdAt: notif.createdAt,
          data: notif.data,
        )).toList();

        notifications.assignAll(updatedList);
        unreadCount.value = 0;

        Get.snackbar(
          'Success',
          'All notifications marked as read',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Error marking all notifications as read: $e');
      Get.snackbar(
        'Error',
        'Failed to mark notifications as read',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  List<AppNotification> get unreadNotifications {
    return notifications.where((n) => !n.isRead).toList();
  }

  List<AppNotification> get readNotifications {
    return notifications.where((n) => n.isRead).toList();
  }

  List<AppNotification> getNotificationsByType(String type) {
    return notifications.where((n) => n.type == type).toList();
  }
}
