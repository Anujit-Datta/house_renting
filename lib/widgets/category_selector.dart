import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/property_controller.dart';

class CategorySelector extends StatelessWidget {
  const CategorySelector({super.key});

  // Categories with their display data
  static const List<Map<String, dynamic>> categories = [
    {
      'title': 'All',
      'subtitle': 'All Properties',
      'icon': Icons.apps,
      'value': 'all',
    },
    {
      'title': 'Family',
      'subtitle': 'Families & long-term',
      'icon': Icons.people_alt,
      'value': 'family',
    },
    {
      'title': 'Sublet',
      'subtitle': 'Shared spaces',
      'icon': Icons.group,
      'value': 'sublet',
    },
    {
      'title': 'Bachelor',
      'subtitle': 'Bachelor & Students',
      'icon': Icons.school,
      'value': 'bachelor',
    },
    {
      'title': 'Commercial',
      'subtitle': 'Business spaces',
      'icon': Icons.business,
      'value': 'commercial',
    },
  ];

  int _getSelectedIndex(PropertyController controller) {
    final rentalType = controller.filterRentalType.value;
    for (int i = 0; i < categories.length; i++) {
      if (categories[i]['value'] == rentalType) {
        return i;
      }
    }
    return 0; // Default to 'All'
  }

  @override
  Widget build(BuildContext context) {
    return GetX<PropertyController>(
      builder: (controller) {
        final selectedIndex = _getSelectedIndex(controller);

        return Container(
          height: 125,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = selectedIndex == index;

              return GestureDetector(
                onTap: () {
                  // Update property filter and fetch
                  controller.updateFilters(rentalType: category['value'] as String);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 115,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFF7F50) // Coral/Orange color
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFF7F50)
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? const Color(0xFFFF7F50).withOpacity(0.3)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: isSelected ? 12 : 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        category['icon'] as IconData,
                        size: 24,
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category['title'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        category['subtitle'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected ? Colors.white70 : Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
