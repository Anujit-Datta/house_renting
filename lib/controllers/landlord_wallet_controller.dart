import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:house_renting/services/api_service.dart';

class LandlordTransaction {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final bool isCredit; // true = earnings, false = withdrawal

  LandlordTransaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.isCredit,
  });

  factory LandlordTransaction.fromJson(Map<String, dynamic> json) {
    return LandlordTransaction(
      id: json['id']?.toString() ?? json['transaction_id']?.toString() ?? '',
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

class LandlordWalletController extends GetxController {
  // Wallet
  final RxDouble walletBalance = 0.0.obs;
  final RxDouble totalEarnings = 0.0.obs;
  final RxDouble totalWithdrawn = 0.0.obs;
  final RxList<LandlordTransaction> transactions = <LandlordTransaction>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWalletData();
  }

  Future<void> fetchWalletData() async {
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
            .map((json) => LandlordTransaction.fromJson(json))
            .toList();
        transactions.assignAll(txData);

        // Calculate totals
        totalEarnings.value = txData
            .where((t) => t.isCredit)
            .fold(0.0, (sum, t) => sum + t.amount);
        totalWithdrawn.value = txData
            .where((t) => !t.isCredit)
            .fold(0.0, (sum, t) => sum + t.amount);
      }
    } catch (e) {
      print('Error fetching wallet data: $e');
      // Fallback to dummy data on error
      _loadDummyData();
    } finally {
      isLoading.value = false;
    }
  }

  void _loadDummyData() {
    // 1. Wallet Stats
    walletBalance.value = 45000.0;
    totalEarnings.value = 120000.0;
    totalWithdrawn.value = 75000.0;

    // 2. Transactions
    transactions.addAll([
      LandlordTransaction(
        id: 'tx1',
        description: 'Rent Received - Green View',
        amount: 25000,
        date: DateTime.now().subtract(const Duration(days: 2)),
        isCredit: true,
      ),
      LandlordTransaction(
        id: 'tx2',
        description: 'Withdrawal to Bank',
        amount: 50000,
        date: DateTime.now().subtract(const Duration(days: 15)),
        isCredit: false,
      ),
      LandlordTransaction(
        id: 'tx3',
        description: 'Rent Received - Sunny Condo',
        amount: 20000,
        date: DateTime.now().subtract(const Duration(days: 32)),
        isCredit: true,
      ),
    ]);
  }

  Future<bool> addMoneyToWallet(double amount, String paymentMethod) async {
    try {
      final response = await ApiService().addMoneyToWallet({
        'amount': amount,
        'payment_method': paymentMethod,
      });

      if (response['success'] == true) {
        // Refresh wallet data
        await fetchWalletData();
        Get.snackbar(
          'Success',
          response['message'] ?? 'Money added to wallet successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to add money',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      print('Error adding money to wallet: $e');
      Get.snackbar(
        'Error',
        'Failed to add money: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // Actions
  void withdrawMoney(double amount) {
    if (walletBalance.value >= amount) {
      walletBalance.value -= amount;
      totalWithdrawn.value += amount;
      transactions.insert(
        0,
        LandlordTransaction(
          id: DateTime.now().toString(),
          description: 'Withdrawal',
          amount: amount,
          date: DateTime.now(),
          isCredit: false,
        ),
      );
      Get.snackbar(
        'Success',
        'Withdrawal processed successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Error',
        'Insufficient funds',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
