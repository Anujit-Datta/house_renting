import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:house_renting/utils/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token != null && token.isNotEmpty) {
      final cleanToken = token.trim();
      headers['Authorization'] = 'Bearer $cleanToken';
    }
    
    return headers;
  }

  // Auth Endpoints
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = '${ApiConstants.baseUrl}/login';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final url = '${ApiConstants.baseUrl}/register';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode(userData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Registration failed: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final url = '${ApiConstants.baseUrl}/auth/me';
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get current user: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> logout() async {
    final url = '${ApiConstants.baseUrl}/auth/logout';
    final headers = await _getHeaders();
    final response = await http.post(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Logout failed: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    final url = '${ApiConstants.baseUrl}/profile';
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse(url),
      headers: headers,
      body: json.encode(profileData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Profile update failed: ${response.body}');
    }
  }

  // Rental Request Endpoints
  Future<Map<String, dynamic>> createRentalRequest(Map<String, dynamic> requestData) async {
    final url = '${ApiConstants.baseUrl}/rental-requests';
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(requestData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create rental request: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getRentalRequests({int page = 1, int perPage = 15}) async {
    final url = '${ApiConstants.baseUrl}/rental-requests?page=$page&per_page=$perPage';
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get rental requests: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getRentalRequestDetails(int id) async {
    final url = '${ApiConstants.baseUrl}/rental-requests/$id';
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get rental request details: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> approveRentalRequest(int id) async {
    final url = '${ApiConstants.baseUrl}/rental-requests/$id/approve';
    final headers = await _getHeaders();
    final response = await http.put(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to approve rental request: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> rejectRentalRequest(int id, {String? reason}) async {
    final url = '${ApiConstants.baseUrl}/rental-requests/$id/reject';
    final headers = await _getHeaders();
    final body = reason != null ? json.encode({'reason': reason}) : null;
    final response = await http.put(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to reject rental request: ${response.body}');
    }
  }

  // Contract Endpoints
  Future<Map<String, dynamic>> getContracts({int page = 1, int perPage = 15}) async {
    final url = '${ApiConstants.baseUrl}/contracts?page=$page&per_page=$perPage';
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get contracts: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getContractDetails(int id) async {
    final url = '${ApiConstants.baseUrl}/contracts/$id';
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get contract details: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> generateContract(int requestId, Map<String, dynamic> contractData) async {
    final url = '${ApiConstants.baseUrl}/contracts/request/$requestId/generate';
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(contractData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to generate contract: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> signContract(int id, String signature) async {
    final url = '${ApiConstants.baseUrl}/contracts/$id/sign';
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode({'signature': signature}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to sign contract: ${response.body}');
    }
  }

  // Payment Endpoints
  Future<Map<String, dynamic>> createPayment(Map<String, dynamic> paymentData) async {
    final url = '${ApiConstants.baseUrl}/payments';
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(paymentData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create payment: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getPayments({int page = 1, int perPage = 15}) async {
    final url = '${ApiConstants.baseUrl}/payments?page=$page&per_page=$perPage';
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get payments: ${response.body}');
    }
  }

  // Message Endpoints
  Future<Map<String, dynamic>> getConversations() async {
    final url = '${ApiConstants.baseUrl}/messages/conversations';
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get conversations: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getMessages(int userId) async {
    final url = '${ApiConstants.baseUrl}/messages/conversation/$userId';
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get messages: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> sendMessage(int userId, String message) async {
    final url = '${ApiConstants.baseUrl}/messages/$userId';
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode({'message': message}),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to send message: ${response.body}');
    }
  }

  // Notification Endpoints
  Future<Map<String, dynamic>> getNotifications({int page = 1, int perPage = 15}) async {
    final url = '${ApiConstants.baseUrl}/notifications?page=$page&per_page=$perPage';
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get notifications: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> markNotificationAsRead(int id) async {
    final url = '${ApiConstants.baseUrl}/notifications/$id/read';
    final headers = await _getHeaders();
    final response = await http.put(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to mark notification as read: ${response.body}');
    }
  }

  // Wallet Endpoints
  Future<Map<String, dynamic>> getWalletBalance() async {
    final url = '${ApiConstants.baseUrl}/wallet/balance';
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get wallet balance: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> addMoneyToWallet(Map<String, dynamic> walletData) async {
    final url = '${ApiConstants.baseUrl}/wallet/add-money';
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(walletData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to add money to wallet: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getWalletTransactions({int page = 1, int perPage = 15}) async {
    final url = '${ApiConstants.baseUrl}/wallet/transactions?page=$page&per_page=$perPage';
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get wallet transactions: ${response.body}');
    }
  }

  // Support Ticket Endpoints
  Future<Map<String, dynamic>> createSupportTicket(Map<String, dynamic> ticketData) async {
    final url = '${ApiConstants.baseUrl}/tickets';
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(ticketData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create support ticket: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getSupportTickets({int page = 1, int perPage = 15}) async {
    final url = '${ApiConstants.baseUrl}/tickets?page=$page&per_page=$perPage';
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get support tickets: ${response.body}');
    }
  }

  // Review Endpoints
  Future<Map<String, dynamic>> createPropertyReview(int propertyId, Map<String, dynamic> reviewData) async {
    final url = '${ApiConstants.baseUrl}/properties/$propertyId/review';
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(reviewData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create property review: ${response.body}');
    }
  }

  

  Future<Map<String, dynamic>> verifyContract(String contractId) async {
    final url = '${ApiConstants.baseUrl}/contracts/$contractId/verify';
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to verify contract: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> downloadContract(int id) async {
    final url = '${ApiConstants.baseUrl}/contracts/$id/pdf';
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to download contract: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getContractQrCode(String contractId) async {
    final url = '${ApiConstants.baseUrl}/contracts/$contractId/qr';
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get QR code: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getPaymentDetails(int id) async {
    final url = '${ApiConstants.baseUrl}/payments/$id';
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get payment details: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> confirmPayment(int id) async {
    final url = '${ApiConstants.baseUrl}/payments/$id/confirm';
    final headers = await _getHeaders();
    final response = await http.put(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to confirm payment: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> rejectPayment(int id, {String? reason}) async {
    final url = '${ApiConstants.baseUrl}/payments/$id/reject';
    final headers = await _getHeaders();
    final body = reason != null ? json.encode({'reason': reason}) : null;
    final response = await http.put(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to reject payment: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> downloadReceipt(int id) async {
    final url = '${ApiConstants.baseUrl}/payments/$id/receipt';
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to download receipt: ${response.body}');
    }
  }

  // Property Management Endpoints
  Future<Map<String, dynamic>> createProperty(Map<String, dynamic> propertyData) async {
    final url = '${ApiConstants.baseUrl}/properties';
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(propertyData),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create property: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> updateProperty(int id, Map<String, dynamic> propertyData) async {
    final url = '${ApiConstants.baseUrl}/properties/$id';
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse(url),
      headers: headers,
      body: json.encode(propertyData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update property: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> deleteProperty(int id) async {
    final url = '${ApiConstants.baseUrl}/properties/$id';
    final headers = await _getHeaders();
    final response = await http.delete(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to delete property: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> uploadPropertyGallery(int propertyId, List<dynamic> images) async {
    final url = '${ApiConstants.baseUrl}/properties/$propertyId/gallery';
    final headers = await _getHeaders();
    headers.remove('Content-Type'); // Let multipart set it
    
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(headers);
    
    for (var image in images) {
      request.files.add(await http.MultipartFile.fromPath('images[]', image));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to upload gallery: ${response.body}');
    }
  }

  // User Profile Endpoints
  Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> profileData) async {
    final url = '${ApiConstants.baseUrl}/profile';
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse(url),
      headers: headers,
      body: json.encode(profileData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> uploadAvatar(String imagePath) async {
    final url = '${ApiConstants.baseUrl}/profile/upload-avatar';
    final headers = await _getHeaders();
    headers.remove('Content-Type');
    
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(headers);
    request.files.add(await http.MultipartFile.fromPath('avatar', imagePath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to upload avatar: ${response.body}');
    }
  }

  // Favorites/Properties Endpoints
  Future<Map<String, dynamic>> getFavorites() async {
    final url = '${ApiConstants.baseUrl}/favourites';
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get favorites: ${response.body}');
    }
  }

  // Generic GET method
  Future<Map<String, dynamic>> genericGet(String endpoint) async {
    final url = '${ApiConstants.baseUrl}/$endpoint';
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Request failed: ${response.body}');
    }
  }

  // ============================================
  // PASSWORD RESET ENDPOINTS
  // ============================================

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final url = '${ApiConstants.baseUrl}/forgot-password';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({'email': email}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to send reset email: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    final url = '${ApiConstants.baseUrl}/reset-password';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'email': email,
        'token': token,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to reset password: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    final url = '${ApiConstants.baseUrl}/auth/change-password';
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode({
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPasswordConfirmation,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to change password: ${response.body}');
    }
  }

  // ============================================
  // MESSAGE ENDPOINTS (Additional)
  // ============================================

  Future<Map<String, dynamic>> markMessagesAsRead(int userId) async {
    final url = '${ApiConstants.baseUrl}/messages/$userId/read';
    final headers = await _getHeaders();
    final response = await http.post(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to mark messages as read: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getUnreadMessageCount() async {
    final url = '${ApiConstants.baseUrl}/messages/unread-count';
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get unread count: ${response.body}');
    }
  }

  // ============================================
  // NOTIFICATION ENDPOINTS (Additional)
  // ============================================

  Future<Map<String, dynamic>> markAllNotificationsAsRead() async {
    final url = '${ApiConstants.baseUrl}/notifications/read-all';
    final headers = await _getHeaders();
    final response = await http.put(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to mark all notifications as read: ${response.body}');
    }
  }

  // ============================================
  // SUPPORT TICKET ENDPOINTS (Additional)
  // ============================================

  Future<Map<String, dynamic>> getTicketDetails(int id) async {
    final url = '${ApiConstants.baseUrl}/tickets/$id';
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get ticket details: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> replyToTicket(int id, String message) async {
    final url = '${ApiConstants.baseUrl}/tickets/$id/reply';
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode({'message': message}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to reply to ticket: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> updateTicketStatus(int id, String status) async {
    final url = '${ApiConstants.baseUrl}/tickets/$id/status';
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse(url),
      headers: headers,
      body: json.encode({'status': status}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update ticket status: ${response.body}');
    }
  }

  // ============================================
  // REVIEW ENDPOINTS (Additional)
  // ============================================

  Future<Map<String, dynamic>> getPropertyReviews(int propertyId) async {
    final url = '${ApiConstants.baseUrl}/properties/$propertyId/reviews';
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get property reviews: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getTenantReviews(int tenantId) async {
    final url = '${ApiConstants.baseUrl}/reviews/tenants/$tenantId';
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get tenant reviews: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> createTenantReview(
    int tenantId,
    Map<String, dynamic> reviewData,
  ) async {
    final url = '${ApiConstants.baseUrl}/reviews/tenants/$tenantId';
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(reviewData),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create tenant review: ${response.body}');
    }
  }

  // ============================================
  // PROPERTY UNIT ENDPOINTS
  // ============================================

  Future<Map<String, dynamic>> getPropertyUnits(int propertyId) async {
    final url = '${ApiConstants.baseUrl}/properties/$propertyId/units';
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get property units: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> addPropertyUnit(
    int propertyId,
    Map<String, dynamic> unitData,
  ) async {
    final url = '${ApiConstants.baseUrl}/properties/$propertyId/units';
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(unitData),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to add property unit: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> deleteGalleryImage(int imageId) async {
    final url = '${ApiConstants.baseUrl}/properties/gallery/$imageId';
    final headers = await _getHeaders();
    final response = await http.delete(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to delete gallery image: ${response.body}');
    }
  }

  // ============================================
  // PROFILE ENDPOINTS (Additional)
  // ============================================

  Future<Map<String, dynamic>> getProfile() async {
    final url = '${ApiConstants.baseUrl}/profile';
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get profile: ${response.body}');
    }
  }

  // ============================================
  // BLOCK/UNBLOCK USER ENDPOINTS
  // ============================================

  Future<Map<String, dynamic>> getBlockedUsers() async {
    final url = '${ApiConstants.baseUrl}/blocked-users';
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get blocked users: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> blockUser(int userId, {String? reason}) async {
    final url = '${ApiConstants.baseUrl}/blocked-users';
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode({
        'blocked_user_id': userId,
        if (reason != null) 'reason': reason,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to block user: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> unblockUser(int userId) async {
    final url = '${ApiConstants.baseUrl}/blocked-users/$userId';
    final headers = await _getHeaders();
    final response = await http.delete(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to unblock user: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> checkIfUserBlocked(int userId) async {
    final url = '${ApiConstants.baseUrl}/blocked-users/check/$userId';
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to check block status: ${response.body}');
    }
  }

  // ============================================
  // REPORT ENDPOINTS
  // ============================================

  Future<Map<String, dynamic>> submitPropertyReport(
    int propertyId,
    String reason,
    String description, {
    List<String>? screenshots,
  }) async {
    final url = '${ApiConstants.baseUrl}/reports/property/$propertyId';
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode({
        'report_reason': reason,
        'report_description': description,
        if (screenshots != null) 'screenshots': screenshots,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to submit property report: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> submitUserReport(
    int reportedUserId,
    String reason,
    String description, {
    String? screenshotPath,
  }) async {
    final url = '${ApiConstants.baseUrl}/reports/user';
    final headers = await _getHeaders();

    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(headers);
    request.fields['reported_user_id'] = reportedUserId.toString();
    request.fields['reason'] = reason;
    request.fields['description'] = description;

    if (screenshotPath != null) {
      request.files.add(await http.MultipartFile.fromPath('screenshot', screenshotPath));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to submit user report: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getMyReports({String? type}) async {
    String url = '${ApiConstants.baseUrl}/reports/my-reports';
    if (type != null) {
      url += '?type=$type';
    }
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get my reports: ${response.body}');
    }
  }

  // ============================================
  // ROOMMATE SEARCH ENDPOINTS
  // ============================================

  Future<Map<String, dynamic>> searchRoommates({
    String? location,
    int? budget,
    String? gender,
    String? smoking,
    String? pets,
    String? cleanliness,
    String? occupation,
  }) async {
    final queryParams = <String, String>{
      if (location != null) 'location': location,
      if (budget != null) 'budget': budget.toString(),
      if (gender != null) 'gender': gender,
      if (smoking != null) 'smoking': smoking,
      if (pets != null) 'pets': pets,
      if (cleanliness != null) 'cleanliness': cleanliness,
      if (occupation != null) 'occupation': occupation,
    }.entries.map((e) => '${e.key}=${e.value}').join('&');

    final url = '${ApiConstants.baseUrl}/roommates?$queryParams';
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to search roommates: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getRoommateFilters() async {
    final url = '${ApiConstants.baseUrl}/roommates/filters';
    final response = await http.get(Uri.parse(url), headers: {
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get roommate filters: ${response.body}');
    }
  }

  // ============================================
  // SEARCH ENDPOINTS
  // ============================================

  Future<Map<String, dynamic>> getSearchSuggestions(String query) async {
    final url = '${ApiConstants.baseUrl}/search/suggestions?q=${Uri.encodeComponent(query)}';
    final response = await http.get(Uri.parse(url), headers: {
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get search suggestions: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getFeaturedProperties({
    int? limit,
    String? propertyType,
    String? rentalType,
  }) async {
    final queryParams = <String, String>{
      if (limit != null) 'limit': limit.toString(),
      if (propertyType != null) 'property_type': propertyType,
      if (rentalType != null) 'rental_type': rentalType,
    }.entries.map((e) => '${e.key}=${e.value}').join('&');

    final url = '${ApiConstants.baseUrl}/properties/featured?$queryParams';
    final response = await http.get(Uri.parse(url), headers: {
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get featured properties: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getRecentProperties({int? limit}) async {
    final url = '${ApiConstants.baseUrl}/properties/recent${limit != null ? '?limit=$limit' : ''}';
    final response = await http.get(Uri.parse(url), headers: {
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get recent properties: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> advancedSearch({
    String? query,
    String? location,
    int? minRent,
    int? maxRent,
    int? bedrooms,
    int? bathrooms,
    String? propertyType,
    String? rentalType,
    String? amenities,
    bool? featured,
    bool? available,
    int? page,
    int? perPage,
  }) async {
    final queryParams = <String, String>{
      if (query != null) 'query': query,
      if (location != null) 'location': location,
      if (minRent != null) 'min_rent': minRent.toString(),
      if (maxRent != null) 'max_rent': maxRent.toString(),
      if (bedrooms != null) 'bedrooms': bedrooms.toString(),
      if (bathrooms != null) 'bathrooms': bathrooms.toString(),
      if (propertyType != null) 'property_type': propertyType,
      if (rentalType != null) 'rental_type': rentalType,
      if (amenities != null) 'amenities': amenities,
      if (featured != null) 'featured': featured.toString(),
      if (available != null) 'available': available.toString(),
      if (page != null) 'page': page.toString(),
      if (perPage != null) 'per_page': perPage.toString(),
    }.entries.map((e) => '${e.key}=${e.value}').join('&');

    final url = '${ApiConstants.baseUrl}/search/advanced?$queryParams';
    final response = await http.get(Uri.parse(url), headers: {
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to perform advanced search: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getSearchFilters() async {
    final url = '${ApiConstants.baseUrl}/search/filters';
    final response = await http.get(Uri.parse(url), headers: {
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get search filters: ${response.body}');
    }
  }

  // ============================================
  // CONTENT ENDPOINTS (FAQ, About, Privacy, Terms)
  // ============================================

  Future<Map<String, dynamic>> getFAQ() async {
    final url = '${ApiConstants.baseUrl}/content/faq';
    final response = await http.get(Uri.parse(url), headers: {
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get FAQ: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getAbout() async {
    final url = '${ApiConstants.baseUrl}/content/about';
    final response = await http.get(Uri.parse(url), headers: {
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get about content: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getPrivacyPolicy() async {
    final url = '${ApiConstants.baseUrl}/content/privacy';
    final response = await http.get(Uri.parse(url), headers: {
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get privacy policy: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getTermsAndConditions() async {
    final url = '${ApiConstants.baseUrl}/content/terms';
    final response = await http.get(Uri.parse(url), headers: {
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get terms & conditions: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getContactInfo() async {
    final url = '${ApiConstants.baseUrl}/content/contact';
    final response = await http.get(Uri.parse(url), headers: {
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get contact info: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getAppSettings() async {
    final url = '${ApiConstants.baseUrl}/content/settings';
    final response = await http.get(Uri.parse(url), headers: {
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get app settings: ${response.body}');
    }
  }

  // ============================================
  // MESSAGE ENDPOINTS (Additional - Delete & Upload)
  // ============================================

  Future<Map<String, dynamic>> deleteConversation(int userId) async {
    final url = '${ApiConstants.baseUrl}/messages/conversation/$userId';
    final headers = await _getHeaders();
    final response = await http.delete(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to delete conversation: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> deleteMessage(int messageId) async {
    final url = '${ApiConstants.baseUrl}/messages/message/$messageId';
    final headers = await _getHeaders();
    final response = await http.delete(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to delete message: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> uploadMessageFile(String filePath) async {
    final url = '${ApiConstants.baseUrl}/messages/upload';
    final headers = await _getHeaders();
    headers.remove('Content-Type');

    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(headers);
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to upload file: ${response.body}');
    }
  }
}
