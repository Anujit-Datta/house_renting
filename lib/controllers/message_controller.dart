import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:house_renting/services/api_service.dart';

class Message {
  final int id;
  final int senderId;
  final int receiverId;
  final String message;
  final String? filePath;
  final bool isSeen;
  final DateTime createdAt;
  final String? senderName;
  final String? senderRole;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    this.filePath,
    required this.isSeen,
    required this.createdAt,
    this.senderName,
    this.senderRole,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      receiverId: json['receiver_id'] ?? 0,
      message: json['message'] ?? '',
      filePath: json['file_path'],
      isSeen: json['is_seen'] == true || json['is_seen'] == 1,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      senderName: json['sender']?['name'] ?? json['sender_name'],
      senderRole: json['sender']?['role'] ?? json['sender_role'],
    );
  }
}

class Conversation {
  final int userId;
  final String userName;
  final String? userRole;
  final String? userAvatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  Conversation({
    required this.userId,
    required this.userName,
    this.userRole,
    this.userAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      userId: json['user_id'] ?? json['id'] ?? 0,
      userName: json['user_name'] ?? json['name'] ?? 'Unknown',
      userRole: json['user_role'] ?? json['role'],
      userAvatar: json['user_avatar'] ?? json['avatar'],
      lastMessage: json['last_message'] ?? '',
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.tryParse(json['last_message_time']) ?? DateTime.now()
          : DateTime.now(),
      unreadCount: json['unread_count'] ?? 0,
    );
  }
}

class MessageController extends GetxController {
  final RxList<Conversation> conversations = <Conversation>[].obs;
  final RxList<Message> currentMessages = <Message>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<int> currentChatUserId = Rxn<int>();
  final ApiService _apiService = ApiService();

  @override
  void onInit() {
    super.onInit();
    fetchConversations();
    fetchUnreadCount();
  }

  Future<void> fetchConversations() async {
    try {
      isLoading(true);
      errorMessage('');

      final response = await _apiService.getConversations();

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> convData = response['data'];
        final List<Conversation> convList = convData
            .map((json) => Conversation.fromJson(json))
            .toList();
        conversations.assignAll(convList);
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch conversations');
      }
    } catch (e) {
      errorMessage(e.toString());
      print('Error fetching conversations: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchMessages(int userId) async {
    try {
      currentChatUserId.value = userId;
      isLoading(true);
      errorMessage('');

      final response = await _apiService.getMessages(userId);

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> msgData = response['data'];
        final List<Message> msgList = msgData
            .map((json) => Message.fromJson(json))
            .toList();
        currentMessages.assignAll(msgList);

        // Mark messages as read
        await markAsRead(userId);
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch messages');
      }
    } catch (e) {
      errorMessage(e.toString());
      print('Error fetching messages: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<bool> sendMessage(int userId, String message) async {
    try {
      final response = await _apiService.sendMessage(userId, message);

      if (response['success'] == true && response['data'] != null) {
        final newMessage = Message.fromJson(response['data']);
        currentMessages.add(newMessage);

        // Update conversation list
        await fetchConversations();

        return true;
      } else {
        throw Exception(response['message'] ?? 'Failed to send message');
      }
    } catch (e) {
      print('Error sending message: $e');
      Get.snackbar(
        'Error',
        'Failed to send message',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<void> markAsRead(int userId) async {
    try {
      await _apiService.markMessagesAsRead(userId);

      // Update unread count
      await fetchUnreadCount();

      // Update conversation unread count locally
      final index = conversations.indexWhere((c) => c.userId == userId);
      if (index != -1) {
        final conv = conversations[index];
        conversations[index] = Conversation(
          userId: conv.userId,
          userName: conv.userName,
          userRole: conv.userRole,
          userAvatar: conv.userAvatar,
          lastMessage: conv.lastMessage,
          lastMessageTime: conv.lastMessageTime,
          unreadCount: 0,
        );
      }
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      final response = await _apiService.getUnreadMessageCount();

      if (response['success'] == true && response['data'] != null) {
        unreadCount.value = response['data']['count'] ?? 0;
      }
    } catch (e) {
      print('Error fetching unread count: $e');
    }
  }

  void clearCurrentChat() {
    currentMessages.clear();
    currentChatUserId.value = null;
  }

  Conversation? getConversationByUserId(int userId) {
    return conversations.firstWhereOrNull((c) => c.userId == userId);
  }

  int get totalUnreadCount {
    return conversations.fold(0, (sum, conv) => sum + conv.unreadCount);
  }
}
