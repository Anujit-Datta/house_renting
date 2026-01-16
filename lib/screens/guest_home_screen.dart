import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:house_renting/controllers/property_controller.dart';
import 'package:house_renting/screens/auth_screen.dart';
import 'package:house_renting/widgets/property_card.dart';
import 'package:house_renting/screens/contact_screen.dart';
import 'package:house_renting/screens/services_screen.dart';

import 'package:house_renting/widgets/custom_app_bar.dart';

class GuestHomeScreen extends StatefulWidget {
  const GuestHomeScreen({super.key});

  @override
  State<GuestHomeScreen> createState() => _GuestHomeScreenState();
}

class _GuestHomeScreenState extends State<GuestHomeScreen> {
  // Navigation State
  // String _selectedNavItem = 'Home';

  void _onNavItemTapped(String navItem) {
    // setState(() {
    //   _selectedNavItem = navItem;
    // });

    if (navItem == 'Services') {
      Get.to(() => const ServicesScreen());
    } else if (navItem == 'Contact') {
      Get.to(() => const ContactScreen());
    }
    // Add other navigation logic here if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        actions: [
          // Avatar Menu (Login / Navigation)
          PopupMenuButton<String>(
            offset: const Offset(0, 50),
            icon: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(Icons.person, color: Theme.of(context).primaryColor),
            ),
            onSelected: (value) {
              if (value == 'Login') {
                Get.to(() => const AuthScreen());
              } else {
                _onNavItemTapped(value);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Home',
                child: Row(
                  children: [
                    Icon(Icons.home, size: 18),
                    SizedBox(width: 8),
                    Text('Home'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'About',
                child: Row(
                  children: [
                    Icon(Icons.info, size: 18),
                    SizedBox(width: 8),
                    Text('About'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'Services',
                child: Row(
                  children: [
                    Icon(Icons.cleaning_services, size: 18),
                    SizedBox(width: 8),
                    Text('Services'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'Contact',
                child: Row(
                  children: [
                    Icon(Icons.contact_support, size: 18),
                    SizedBox(width: 8),
                    Text('Contact'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'Login',
                child: Row(
                  children: [
                    Icon(Icons.login, size: 18, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Log In / Sign Up',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Use Get.find since it should be initialized by the list below
          // If not found (unlikely), we can instantiate just for the refresh or handle error
          if (Get.isRegistered<PropertyController>()) {
            await Get.find<PropertyController>().fetchProperties();
          } else {
            // Fallback if controller not yet registered (create a temp one just to fetch?)
            // Or better, just ignore. But it should be registered by the GetX widget below.
            // Actually, safest is to ensure it is registered.
            // For now assuming it is.
            await Get.put(PropertyController()).fetchProperties();
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero / Banner Section
              Container(
                height: 200,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
                    ),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black45,
                      BlendMode.darken,
                    ),
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Find Your Dream Home',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Apartments, Homes, and more...',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),

              _buildFilterSection(context),

              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Featured Properties',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    // Removed fixed white color to adapt to theme,
                    // or keep white if background is dark?
                    // Since GuestHomeScreen scaffold background is dark in dark mode
                    // and light in light mode, text should be adaptive.
                    // However, Text('Featured Properties') implies simple text.
                    // Let's use Theme.of(context).textTheme.headlineSmall
                  ),
                ),
              ),

              // Featured Properties List
              // Featured Properties List
              GetX<PropertyController>(
                init: PropertyController(),
                builder: (controller) {
                  if (controller.isLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (controller.errorMessage.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'Error: ${controller.errorMessage.value}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }

                  if (controller.properties.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: Text('No properies found')),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.properties.length,
                    itemBuilder: (context, index) {
                      final property = controller.properties[index];
                      return PropertyCard(
                        property: property,
                        isFavVisible: false, // Hidden for guests
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter Chips Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              _buildFilterChip(
                'All Properties',
                isSelected: true,
                icon: Icons.grid_view,
              ),
              _buildFilterChip('Available', icon: Icons.check_circle),
              _buildFilterChip('Buildings', icon: Icons.apartment),
              _buildFilterChip('Single Units', icon: Icons.home),
              _buildFilterChip('Family', icon: Icons.people),
              _buildFilterChip('Bachelor', icon: Icons.person),
              _buildFilterChip('Sublet', icon: Icons.door_front_door),
              _buildFilterChip('Commercial', icon: Icons.business_center),
              _buildFilterChip('Roommate', icon: Icons.group),
            ],
          ),
        ),

        // Sort Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Row(
            children: [
              Text(
                'Sort by: ',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: 'Newest First',
                    dropdownColor: Theme.of(context).cardColor,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: Theme.of(context).iconTheme.color,
                      size: 16,
                    ),
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    onChanged: (String? newValue) {
                      // Handle sort change
                    },
                    items:
                        <String>[
                          'Newest First',
                          'Price: Low to High',
                          'Price: High to Low',
                          'Best Rating',
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Stats Row (Moved Below)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.home, color: Colors.blue, size: 18),
                  SizedBox(width: 4),
                  Text(
                    '3 of 3 properties',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 12),
                  Icon(Icons.check_circle, color: Colors.blue, size: 18),
                  SizedBox(width: 4),
                  Text(
                    '3 available',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 12),
                  Icon(Icons.apartment, color: Colors.blue, size: 18),
                  SizedBox(width: 4),
                  Text(
                    '2 buildings',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 12),
                  Icon(Icons.door_front_door, color: Colors.blue, size: 18),
                  SizedBox(width: 4),
                  Text(
                    '11 total units',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    String label, {
    bool isSelected = false,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF2C3E50) : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 18,
                    color: isSelected ? Colors.white : Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
