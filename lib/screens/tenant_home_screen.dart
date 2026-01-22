import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:house_renting/controllers/property_controller.dart';
import 'package:house_renting/controllers/auth_controller.dart';
import 'package:house_renting/screens/auth_screen.dart';
import 'package:house_renting/screens/guest_home_screen.dart';
import 'package:house_renting/widgets/advanced_filters_dialog.dart';
import 'package:house_renting/widgets/custom_app_bar.dart';
import 'package:house_renting/widgets/property_card.dart';
import 'package:house_renting/widgets/category_selector.dart';
import 'package:house_renting/screens/tenant/my_rentals_screen.dart';
import 'package:house_renting/screens/tenant/wallet_screen.dart';
import 'package:house_renting/screens/tenant/pay_rent_screen.dart';
import 'package:house_renting/screens/tenant/my_reviews_screen.dart';

class TenantHomeScreen extends StatefulWidget {
  const TenantHomeScreen({super.key});

  @override
  State<TenantHomeScreen> createState() => _TenantHomeScreenState();
}

class _TenantHomeScreenState extends State<TenantHomeScreen> {
  // Navigation State
  final TextEditingController _searchController = TextEditingController();
  final PropertyController _propertyController = Get.find<PropertyController>();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        actions: [
          // Notification
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
          const SizedBox(width: 8),
          // Avatar Dropdown
          // Avatar Dropdown
          // Avatar Dropdown
          GetBuilder<AuthController>(
            builder: (authController) {
              final user = authController.currentUser;
              return PopupMenuButton<String>(
                offset: const Offset(0, 50),
                child: CircleAvatar(
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: NetworkImage(
                    user?.photoUrl ??
                        'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80',
                  ),
                ),
                onSelected: (val) {
                  switch (val) {
                    case 'Logout':
                      authController.logout();
                      Get.offAll(() => const GuestHomeScreen());
                      break;
                    case 'My Rentals':
                      Get.to(() => const MyRentalsScreen());
                      break;
                    case 'My Wallet':
                      Get.to(() => const WalletScreen());
                      break;
                    case 'Pay Rent':
                      Get.to(() => const PayRentScreen());
                      break;
                    case 'My Reviews':
                      Get.to(() => const MyReviewsScreen());
                      break;
                    default:
                      // Handle other cases or show "Coming Soon"
                      break;
                  }
                },
                itemBuilder: (context) => [
                  // Custom Header
                  PopupMenuItem(
                    enabled: false,
                    padding: EdgeInsets.zero,
                    child: Container(
                      width: double.infinity,
                      color: const Color(0xFF2C3E50), // Dark Blue Header
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 16,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white24,
                            backgroundImage: NetworkImage(
                              user?.photoUrl ??
                                  'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.name ?? 'Guest',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  user?.email ?? '',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Menu Items
                  // const PopupMenuItem(
                  //   value: 'Profile',
                  //   child: Row(
                  //     children: [
                  //       Icon(Icons.person, size: 20),
                  //       SizedBox(width: 12),
                  //       Text('My Profile'),
                  //     ],
                  //   ),
                  // ),
                  // const PopupMenuItem(
                  //   value: 'Settings',
                  //   child: Row(
                  //     children: [
                  //       Icon(Icons.settings, size: 20),
                  //       SizedBox(width: 12),
                  //       Text('Settings'),
                  //     ],
                  //   ),
                  // ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'My Rentals',
                    child: Row(
                      children: [
                        Icon(Icons.home, size: 20),
                        SizedBox(width: 12),
                        Text('My Rentals'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'Pay Rent',
                    child: Row(
                      children: [
                        Icon(Icons.payment, size: 20),
                        SizedBox(width: 12),
                        Text('Pay Rent'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'My Requests',
                    child: Row(
                      children: [
                        Icon(Icons.send, size: 20),
                        SizedBox(width: 12),
                        Text('My Requests'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'My Wallet',
                    child: Row(
                      children: [
                        Icon(Icons.account_balance_wallet, size: 20),
                        SizedBox(width: 12),
                        Text('My Wallet'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'My Reviews',
                    child: Row(
                      children: [
                        Icon(Icons.star_rate, size: 20),
                        SizedBox(width: 12),
                        Text('My Reviews'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'Favourites',
                    child: Row(
                      children: [
                        Icon(Icons.favorite, size: 20),
                        SizedBox(width: 12),
                        Text('Favourites'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'Logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Log Out', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      // Create a Row for Sidebar + Main Content (simulating dashboard layout)
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sidebar (Visible on larger screens, strictly speaking user design implies it's always there or this is a responsive layout)
          // For now, let's implement the sidebar as a fixed width container
          if (MediaQuery.of(context).size.width > 800) _buildSidebar(context),

          // Main Content Area
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                final controller = Get.find<PropertyController>();
                await controller.fetchProperties();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Categories Row - Horizontally Scrollable
                    const CategorySelector(),
                    const SizedBox(height: 32),

                    // Search & Filters
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Find Your Perfect Home',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              // Search Bar
                              Expanded(
                                child: ValueListenableBuilder(
                                  valueListenable: _searchController,
                                  builder: (context, TextEditingValue value, child) {
                                    return TextField(
                                      controller: _searchController,
                                      onSubmitted: (searchValue) {
                                        // Trigger search when user presses Enter
                                        _propertyController.updateFilters(search: searchValue);
                                      },
                                      decoration: InputDecoration(
                                        hintText:
                                            'Search by property name, location, or description...',
                                        prefixIcon: const Icon(
                                          Icons.search,
                                          color: Colors.grey,
                                        ),
                                        suffixIcon: value.text.isNotEmpty
                                            ? IconButton(
                                                icon: const Icon(
                                                  Icons.clear,
                                                  color: Colors.grey,
                                                ),
                                                onPressed: () {
                                                  _searchController.clear();
                                                  _propertyController.updateFilters(search: '');
                                                },
                                              )
                                            : null,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide
                                              .none, // Or grey border depending on theme
                                        ),
                                        filled: true,
                                        fillColor: Theme.of(
                                          context,
                                        ).scaffoldBackgroundColor, // Slight contrast
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Search Button
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF7F50), // Coral color
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.search,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    // Trigger search when button is pressed
                                    _propertyController.updateFilters(
                                      search: _searchController.text,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Advanced Filters Button (Moved to next line)
                          SizedBox(
                            width: double.infinity, // Full width for better UX
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final controller =
                                    Get.find<PropertyController>();
                                final result =
                                    await showDialog<Map<String, dynamic>>(
                                      context: context,
                                      builder: (context) =>
                                          AdvancedFiltersDialog(
                                            location:
                                                controller.filterLocation.value,
                                            propertyType: controller
                                                .filterPropertyType
                                                .value,
                                            bedrooms:
                                                controller.filterBedrooms.value,
                                            minRent:
                                                controller.filterMinRent.value,
                                            maxRent:
                                                controller.filterMaxRent.value,
                                          ),
                                    );

                                if (result != null) {
                                  Get.find<PropertyController>().updateFilters(
                                    location: result['location'],
                                    propertyType: result['propertyType'],
                                    bedrooms: result['bedrooms'],
                                    minRent: result['minRent'],
                                    maxRent: result['maxRent'],
                                  );
                                }
                              },
                              icon: Icon(
                                Icons.tune,
                                size: 18,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color,
                              ),
                              label: Text(
                                'Advanced Filters',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 18,
                                ),
                                side: BorderSide(
                                  color: Colors.grey.withOpacity(0.3),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment
                                    .centerLeft, // Align text/icon left
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Listings Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Properties',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.grid_view),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.list),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Listings Grid
                    GetX<PropertyController>(
                      init: PropertyController(),
                      builder: (controller) {
                        if (controller.isLoading.value) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (controller.errorMessage.isNotEmpty) {
                          return Center(
                            child: Text(
                              'Error: ${controller.errorMessage.value}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }
                        if (controller.properties.isEmpty) {
                          return const Center(
                            child: Text('No properties found.'),
                          );
                        }

                        return LayoutBuilder(
                          builder: (context, constraints) {
                            int crossAxisCount = 1;
                            if (constraints.maxWidth > 700) crossAxisCount = 2;
                            if (constraints.maxWidth > 1100) crossAxisCount = 3;

                            // Calculate Card Width
                            double spacing = 20;
                            double totalSpacing =
                                spacing * (crossAxisCount - 1);
                            double cardWidth =
                                (constraints.maxWidth - totalSpacing) /
                                crossAxisCount;

                            return Wrap(
                              spacing: spacing,
                              runSpacing: spacing,
                              children: controller.properties.map((property) {
                                return SizedBox(
                                  width: cardWidth,
                                  child: PropertyCard(
                                    property: property,
                                    isFavVisible: true,
                                    onPressFav: () {
                                      controller.toggleFavorite(property);
                                    },
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 250,
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // We might not need Logo here if Header has it, but Dashboard usually has logo in Sidebar
          // Header in design has "RENTIFY" logo.
          // Let's stick to Design: Sidebar starts with "Explore Properties" button
          // Design shows sidebar content, header content separately. Vertical layout.
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.explore, size: 20),
            label: const Text('Explore Properties'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C3E50), // Navy Blue
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              alignment: Alignment.centerLeft,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 24),

          _buildSidebarItem(Icons.vpn_key, 'My Rentals'),
          _buildSidebarItem(Icons.account_balance_wallet, 'Wallet'),
          _buildSidebarItem(Icons.payment, 'Pay Rent'),
          // Messages and Map View crossed out in design description? "Messages and Map View are crossed out"
          // So skipping them or showing them disabled? User said crossed out.
          _buildSidebarItem(Icons.star, 'My Reviews'),

          const Spacer(),
          _buildSidebarItem(
            Icons.logout,
            'Log Out',
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (c) => const AuthScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String label, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, size: 20, color: Colors.grey),
      title: Text(
        label,
        style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
      ),
      onTap: onTap ?? () {},
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      hoverColor: Colors.grey.withOpacity(0.1),
    );
  }
}
