import 'package:get/get.dart';

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
}

class LandlordWalletController extends GetxController {
  // Wallet
  final RxDouble walletBalance = 0.0.obs;
  final RxDouble totalEarnings = 0.0.obs;
  final RxDouble totalWithdrawn = 0.0.obs;
  final RxList<LandlordTransaction> transactions = <LandlordTransaction>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadDummyData();
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
