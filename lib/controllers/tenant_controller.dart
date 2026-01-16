import 'package:get/get.dart';

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
}

class TenantController extends GetxController {
  // Dummy Data
  final RxList<Rental> activeRentals = <Rental>[].obs;
  final RxList<Transaction> transactions = <Transaction>[].obs;
  final RxList<Review> reviews = <Review>[].obs;

  // Wallet
  final RxDouble walletBalance = 0.0.obs;
  final RxDouble totalAdded = 0.0.obs;
  final RxDouble totalSpent = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    // Simulate loading data
    _loadDummyData();
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

  // Actions
  void addMoney(double amount) {
    walletBalance.value += amount;
    totalAdded.value += amount;
    transactions.insert(
      0,
      Transaction(
        id: DateTime.now().toString(),
        description: 'Added Funds',
        amount: amount,
        date: DateTime.now(),
        isCredit: true,
      ),
    );
  }
}
