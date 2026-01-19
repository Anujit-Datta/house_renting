import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:house_renting/controllers/auth_controller.dart';
import 'package:house_renting/controllers/tenant_controller.dart';
import 'package:house_renting/controllers/landlord_controller.dart';
import 'package:house_renting/controllers/property_controller.dart';
import 'package:house_renting/controllers/theme_controller.dart';
import 'package:house_renting/controllers/rental_requests_controller.dart';
import 'package:house_renting/controllers/contract_controller.dart';
import 'package:house_renting/controllers/payment_controller.dart';
import 'package:house_renting/controllers/message_controller.dart';
import 'package:house_renting/controllers/notification_controller.dart';
import 'package:house_renting/controllers/support_ticket_controller.dart';
import 'package:house_renting/controllers/landlord_wallet_controller.dart';
import 'package:house_renting/screens/guest_home_screen.dart';
import 'package:house_renting/screens/landlord_home_screen.dart';
import 'package:house_renting/screens/tenant_home_screen.dart';
import 'package:house_renting/theme/app_theme.dart';

void main() {
  // Bind Controllers
  Get.put(ThemeController());
  Get.put(AuthController());
  Get.put(PropertyController()); // PropertyController needed for guests too

  // Lazy load controllers - only initialize when accessed
  Get.lazyPut(() => TenantController());
  Get.lazyPut(() => LandlordController());
  Get.lazyPut(() => RentalRequestController());
  Get.lazyPut(() => ContractController());
  Get.lazyPut(() => PaymentController());
  Get.lazyPut(() => MessageController());
  Get.lazyPut(() => NotificationController());
  Get.lazyPut(() => SupportTicketController());
  Get.lazyPut(() => LandlordWalletController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the controller
    final ThemeController themeController = Get.find();
    final AuthController authController = Get.find(); // Already put in main()

    return Obx(() {
      return GetMaterialApp(
        title: 'Rentify',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.themeMode.value,
        home: Obx(() {
          if (!authController.isAuthCheckComplete.value) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (authController.currentUser != null) {
            final role = authController.currentUser!.role.toLowerCase();
            if (role == 'landlord') {
              return const LandlordHomeScreen();
            } else if (role == 'tenant') {
              return const TenantHomeScreen();
            }
          }
          return const GuestHomeScreen();
        }),
      );
    });
  }
}
