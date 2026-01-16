import 'package:flutter/material.dart';
import 'package:get/get.dart';
// We will use constants from here for now, or move them.

class ThemeController extends GetxController {
  // Reactive state
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize standard logic if needed, e.g. check platform brightness
    // For now default to light or system
  }

  void toggleTheme(bool isDark) {
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
    Get.changeThemeMode(themeMode.value);
  }
}
