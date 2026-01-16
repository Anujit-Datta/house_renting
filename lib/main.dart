import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:house_renting/controllers/auth_controller.dart';
import 'package:house_renting/controllers/tenant_controller.dart';
import 'package:house_renting/controllers/landlord_controller.dart';
import 'package:house_renting/controllers/property_controller.dart';
import 'package:house_renting/controllers/theme_controller.dart';
import 'package:house_renting/screens/guest_home_screen.dart';
import 'package:house_renting/screens/landlord_home_screen.dart';
import 'package:house_renting/screens/tenant_home_screen.dart';
import 'package:house_renting/theme/app_theme.dart';

void main() {
  // Bind Controllers
  Get.put(ThemeController());
  Get.put(AuthController());
  Get.put(TenantController());
  Get.put(LandlordController());
  Get.put(PropertyController());

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
