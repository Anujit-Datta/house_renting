import 'dart:convert';

import 'package:get/get.dart';
import 'package:house_renting/screens/guest_home_screen.dart';
import 'package:house_renting/utils/api_constants.dart';
import 'package:house_renting/controllers/property_controller.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? photoUrl;
  final String? token;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.photoUrl,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json, {String? token}) {
    // Use dummy profile pic
    String pic =
        'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80';

    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'] ?? 'guest',
      phone: json['phone'],
      photoUrl: pic,
      token: token,
    );
  }
}

class AuthController extends GetxController {
  User? _currentUser;
  bool _isLoading = false;
  final RxBool isAuthCheckComplete = false.obs;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userData = prefs.getString('user_data');

    if (token != null && userData != null) {
      try {
        final jsonUser = json.decode(userData);
        _currentUser = User.fromJson(jsonUser, token: token);
        update();
      } catch (e) {
        print('Error parsing stored user: $e');
        await logout();
      }
    }

    isAuthCheckComplete.value = true; // Mark check as done
  }

  Future<bool> login(String email, String password, String role) async {
    _isLoading = true;
    update();

    try {
      final url = '${ApiConstants.baseUrl}/login';
      print('Logging in to: $url with $email');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'email': email, 'password': password}),
      );

      print('Login Response: ${response.statusCode}');
      print('Login Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final token = data['data']['token'];
          final userJson = data['data']['user'];

          _currentUser = User.fromJson(userJson, token: token);

          // Save to storage
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          await prefs.setString('user_data', json.encode(userJson));

          _isLoading = false;
          update();

          // Refetch properties with new token to get favorite status
          if (Get.isRegistered<PropertyController>()) {
            Get.find<PropertyController>().fetchProperties();
          }

          return true;
        } else {
          Get.snackbar('Login Failed', data['message'] ?? 'Unknown error');
        }
      } else {
        Get.snackbar('Login Error', 'Server returned ${response.statusCode}');
      }
    } catch (e) {
      print('Login Exception: $e');
      Get.snackbar('Connection Error', 'Failed to connect to server');
    }

    _isLoading = false;
    update();
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');

    _currentUser = null;
    update();
    Get.offAll(() => const GuestHomeScreen());
  }

  // Password Reset Methods
  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    update();

    try {
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
        final data = json.decode(response.body);
        if (data['success'] == true) {
          Get.snackbar(
            'Success',
            data['message'] ?? 'Password reset email sent',
            snackPosition: SnackPosition.BOTTOM,
          );
          return true;
        } else {
          Get.snackbar('Error', data['message'] ?? 'Failed to send reset email');
        }
      } else {
        Get.snackbar('Error', 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Forgot Password Exception: $e');
      Get.snackbar('Error', 'Failed to connect to server');
    }

    _isLoading = false;
    update();
    return false;
  }

  Future<bool> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    _isLoading = true;
    update();

    try {
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
        final data = json.decode(response.body);
        if (data['success'] == true) {
          Get.snackbar(
            'Success',
            data['message'] ?? 'Password reset successfully',
            snackPosition: SnackPosition.BOTTOM,
          );
          return true;
        } else {
          Get.snackbar('Error', data['message'] ?? 'Failed to reset password');
        }
      } else {
        Get.snackbar('Error', 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Reset Password Exception: $e');
      Get.snackbar('Error', 'Failed to connect to server');
    }

    _isLoading = false;
    update();
    return false;
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    _isLoading = true;
    update();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        Get.snackbar('Error', 'Not authenticated');
        _isLoading = false;
        update();
        return false;
      }

      final url = '${ApiConstants.baseUrl}/auth/change-password';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': newPasswordConfirmation,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          Get.snackbar(
            'Success',
            data['message'] ?? 'Password changed successfully',
            snackPosition: SnackPosition.BOTTOM,
          );
          return true;
        } else {
          Get.snackbar('Error', data['message'] ?? 'Failed to change password');
        }
      } else {
        Get.snackbar('Error', 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Change Password Exception: $e');
      Get.snackbar('Error', 'Failed to connect to server');
    }

    _isLoading = false;
    update();
    return false;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String role,
    String? phone,
  }) async {
    _isLoading = true;
    update();

    try {
      final url = '${ApiConstants.baseUrl}/register';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'role': role,
          if (phone != null) 'phone': phone,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final token = data['data']['token'];
          final userJson = data['data']['user'];

          _currentUser = User.fromJson(userJson, token: token);

          // Save to storage
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          await prefs.setString('user_data', json.encode(userJson));

          _isLoading = false;
          update();

          // Refetch properties with new token
          if (Get.isRegistered<PropertyController>()) {
            Get.find<PropertyController>().fetchProperties();
          }

          Get.snackbar(
            'Success',
            'Registration successful',
            snackPosition: SnackPosition.BOTTOM,
          );

          return true;
        } else {
          Get.snackbar('Error', data['message'] ?? 'Registration failed');
        }
      } else {
        final data = json.decode(response.body);
        Get.snackbar('Error', data['message'] ?? 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Register Exception: $e');
      Get.snackbar('Error', 'Failed to connect to server');
    }

    _isLoading = false;
    update();
    return false;
  }
}
