import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:house_renting/controllers/theme_controller.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final String? title;

  const CustomAppBar({super.key, this.actions, this.title});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find();

    return AppBar(
      backgroundColor: Theme.of(context).cardColor,
      elevation: 0,
      iconTheme: IconThemeData(
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      titleSpacing: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.home, color: Theme.of(context).primaryColor, size: 24),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              title ?? 'RENTIFY',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
      actions: [
        // Theme Toggle Switch
        Obx(() {
          bool isDark = themeController.themeMode.value == ThemeMode.dark;
          return Row(
            children: [
              Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                size: 18,
                color: Colors.grey,
              ),
              const SizedBox(width: 2),
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: isDark,
                  onChanged: (value) {
                    themeController.toggleTheme(value);
                  },
                  activeColor: Theme.of(context).primaryColor,
                ),
              ),
            ],
          );
        }),
        // Custom Actions
        if (actions != null) ...actions!,
        const SizedBox(width: 4),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
