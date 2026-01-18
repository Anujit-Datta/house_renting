import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:house_renting/services/api_service.dart';

class Rental {
  final String id;
  final String propertyName;
  final String address;
  final String status; // Active, Pending, Past
  final double rentAmount;
  final DateTime startDate;
  final DateTime? endDate;

  Rental({
    required this.id,
    required this.propertyName,
    required this.address,
    required this.status,
    required this.rentAmount,
    required this.startDate,
    this.endDate,
  });

  factory Rental.fromJson(Map<String, dynamic> json) {
    return Rental(
      id: json['id']?.toString() ?? '',
      propertyName:
          json['property_name'] ??
          json['property']['property_name'] ??
          'Unknown Property',
      address:
          json['location'] ??
          json['property']['location'] ??
          'Unknown Location',
      status: json['status']?.toString() ?? 'pending',
      rentAmount: (json['rent'] is num)
          ? (json['rent'] as num).toDouble()
          : 0.0,
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date']) ?? DateTime.now()
          : DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'])
          : null,
    );
  }
}

class Transaction {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final bool isCredit; // true = added, false = spent

  Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.isCredit,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id']?.toString() ?? '',
      description: json['description'] ?? json['type'] ?? 'Transaction',
      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : 0.0,
      date: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      isCredit: json['type'] == 'credit' || json['is_credit'] == true,
    );
  }
}

class Review {
  final String id;
  final String propertyName;
  final double rating;
  final String comment;
  final DateTime date;

  Review({
    required this.id,
    required this.propertyName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id']?.toString() ?? '',
      propertyName: json['property_name'] ?? 'Unknown Property',
      rating: (json['rating'] is num)
          ? (json['rating'] as num).toDouble()
          : 0.0,
      comment: json['comment'] ?? '',
      date: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class TenantController extends GetxController {
  final RxList<Rental> activeRentals = <Rental>[].obs;
  final RxList<Transaction> transactions = <Transaction>[].obs;
  final RxList<Review> reviews = <Review>[].obs;

  // Wallet
  final RxDouble walletBalance = 0.0.obs;
  final RxDouble totalAdded = 0.0.obs;
  final RxDouble totalSpent = 0.0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTenantData();
  }

  Future<void> fetchTenantData() async {
    isLoading.value = true;
    try {
      // Fetch wallet balance
      final balanceResponse = await ApiService().getWalletBalance();
      if (balanceResponse['success'] == true &&
          balanceResponse['data'] != null) {
        walletBalance.value = (balanceResponse['data']['balance'] is num)
            ? (balanceResponse['data']['balance'] as num).toDouble()
            : 0.0;
      }

      // Fetch transactions
      final transactionsResponse = await ApiService().getWalletTransactions();
      if (transactionsResponse['success'] == true &&
          transactionsResponse['data'] != null) {
        final txList = transactionsResponse['data'] as List;
        final txData = txList
            .map((json) => Transaction.fromJson(json))
            .toList();
        transactions.assignAll(txData);

        // Calculate totals
        totalAdded.value = txData
            .where((t) => t.isCredit)
            .fold(0.0, (sum, t) => sum + t.amount);
        totalSpent.value = txData
            .where((t) => !t.isCredit)
            .fold(0.0, (sum, t) => sum + t.amount);
      }

      // Fetch contracts (rentals)
      final contractsResponse = await ApiService().getContracts();
      if (contractsResponse['success'] == true &&
          contractsResponse['data'] != null) {
        final contractList = contractsResponse['data'] as List;
        final rentals = contractList
            .map((json) => Rental.fromJson(json))
            .toList();
        activeRentals.assignAll(rentals);
      }
    } catch (e) {
      print('Error fetching tenant data: $e');
      // Fallback to dummy data on error
      _loadDummyData();
    } finally {
      isLoading.value = false;
    }
  }

  void _loadDummyData() {
    // 1. Listings / Rentals
    activeRentals.addAll([
      Rental(
        id: '1',
        propertyName: 'Green Valley Apartments',
        address: '123 Park Lane, Gulshan, Dhaka',
        status: 'Active',
        rentAmount: 25000,
        startDate: DateTime.now().subtract(const Duration(days: 60)),
      ),
      Rental(
        id: '2',
        propertyName: 'Lakeside Studio',
        address: '45 Lake View, Banani, Dhaka',
        status: 'Pending',
        rentAmount: 12000,
        startDate: DateTime.now().add(const Duration(days: 5)),
      ),
    ]);

    // 2. Wallet Stats
    walletBalance.value = 15000.0;
    totalAdded.value = 50000.0;
    totalSpent.value = 35000.0;

    // 3. Transactions
    transactions.addAll([
      Transaction(
        id: 't1',
        description: 'Rent Payment - Oct',
        amount: 25000,
        date: DateTime.now().subtract(const Duration(days: 10)),
        isCredit: false,
      ),
      Transaction(
        id: 't2',
        description: 'Added Funds',
        amount: 10000,
        date: DateTime.now().subtract(const Duration(days: 12)),
        isCredit: true,
      ),
      Transaction(
        id: 't3',
        description: 'Service Charge',
        amount: 2000,
        date: DateTime.now().subtract(const Duration(days: 20)),
        isCredit: false,
      ),
    ]);

    // 4. Reviews
    reviews.addAll([
      Review(
        id: 'r1',
        propertyName: 'Sunny Side Condo',
        rating: 4.5,
        comment: 'Great place with amazing amenities. Highly recommended!',
        date: DateTime.now().subtract(const Duration(days: 120)),
      ),
      Review(
        id: 'r2',
        propertyName: 'Old Town House',
        rating: 3.0,
        comment: 'Decent stay but needs maintenance work on plumbing.',
        date: DateTime.now().subtract(const Duration(days: 300)),
      ),
    ]);
  }

  Future<bool> addMoney(double amount) async {
    try {
      final response = await ApiService().addMoneyToWallet({
        'amount': amount,
        'payment_method': 'card',
      });

      if (response['success'] == true) {
        await fetchTenantData();
        Get.snackbar(
          'Success',
          'Money added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Error adding money: $e');
      return false;
    }
  }

  Future<bool> createReview(
    int propertyId,
    double rating,
    String comment,
  ) async {
    try {
      final response = await ApiService().createPropertyReview(propertyId, {
        'rating': rating,
        'comment': comment,
      });

      if (response['success'] == true) {
        Get.snackbar(
          'Success',
          'Review submitted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Error creating review: $e');
      Get.snackbar(
        'Error',
        'Failed to submit review',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }
}
