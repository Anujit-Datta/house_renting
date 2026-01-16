import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:house_renting/controllers/property_controller.dart';
import 'package:house_renting/controllers/auth_controller.dart';
import 'package:house_renting/widgets/custom_app_bar.dart';
import 'package:house_renting/widgets/rental_application_dialog.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final Property property;
  const PropertyDetailsScreen({super.key, required this.property});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  final PropertyController _controller = Get.find<PropertyController>();

  @override
  void initState() {
    super.initState();
    // Fetch fresh details on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.fetchPropertyDetails(widget.property.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetX<PropertyController>(
      builder: (controller) {
        // Use fresh data if available, otherwise fallback to passed property
        final property =
            controller.currentProperty.value?.id == widget.property.id
            ? controller.currentProperty.value!
            : widget.property;

        return Scaffold(
          appBar: CustomAppBar(
            actions: [
              IconButton(icon: const Icon(Icons.share), onPressed: () {}),
              IconButton(
                icon: Icon(
                  property.isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: property.isFavorited ? Colors.red : Colors.grey,
                ),
                onPressed: () {
                  controller.toggleFavorite(property);
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await controller.fetchPropertyDetails(widget.property.id);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      property.imageUrl,
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title and Price
                  Text(
                    property.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property.location,
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property.price,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Overview Section
                  _buildSectionCard(
                    title: 'Overview',
                    icon: Icons.info,
                    child: Text(
                      property.description,
                      style: const TextStyle(height: 1.5, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Property Details Grid
                  _buildSectionCard(
                    title: 'Property Details',
                    icon: Icons.list,
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 3,
                      children: [
                        _buildDetailItem(
                          Icons.bed,
                          'Bedrooms',
                          '${property.beds}',
                        ),
                        _buildDetailItem(
                          Icons.bathtub,
                          'Bathrooms',
                          '${property.baths}',
                        ),
                        _buildDetailItem(
                          Icons.square_foot,
                          'Size',
                          '${property.sqft} sq ft',
                        ),
                        _buildDetailItem(
                          Icons.home,
                          'Property Type',
                          property.details['Property Type'] ?? 'Apartment',
                        ),
                        _buildDetailItem(
                          Icons.layers,
                          'Floor',
                          property.details['Floor'] ?? 'N/A',
                        ),
                        _buildDetailItem(
                          Icons.local_parking,
                          'Parking',
                          property.details['Parking'] ?? 'N/A',
                        ),
                        _buildDetailItem(
                          Icons.weekend,
                          'Furnished',
                          property.details['Furnished'] ?? 'No',
                        ),
                        _buildDetailItem(
                          Icons.people,
                          'Rental Type',
                          property.details['Rental Type'] ?? 'Family',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Location
                  _buildSectionCard(
                    title: 'Location',
                    icon: Icons.map,
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Latitude: 23.746466, Longitude: 90.376015',
                          style: TextStyle(color: Colors.grey),
                        ),
                        // Map placeholder could go here
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Property Owner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(
                              property.owner['image'],
                            ),
                          ),
                          title: Text(
                            property.owner['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            property.owner['role'],
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.email),
                          label: const Text('Send Message'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF5E60CE,
                            ), // Purple/Blue from mockup
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 45),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Contact landlord for more details',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.person),
                          label: const Text('View All Properties'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2C3E50),
                            minimumSize: const Size(double.infinity, 45),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quick Actions
                  _buildSectionCard(
                    title: 'Quick Actions',
                    icon: Icons.flash_on,
                    child: Column(
                      children: [
                        if (Get.find<AuthController>().currentUser != null) ...[
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF5E60CE), Color(0xFF6930C3)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      const RentalApplicationDialog(),
                                );
                              },
                              icon: const Icon(Icons.vpn_key),
                              label: const Text('Rent Now'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 45),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.calculate),
                          label: const Text('Calculate Total Rent'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2C3E50),
                            minimumSize: const Size(double.infinity, 45),
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.flag, color: Colors.red),
                          label: const Text(
                            'Report Abuse',
                            style: TextStyle(color: Colors.red),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFFCDD2)),
                            minimumSize: const Size(double.infinity, 45),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Share Property
                  _buildSectionCard(
                    title: 'Share Property',
                    icon: Icons.share,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSocialIcon(Icons.facebook, Colors.blue),
                        _buildSocialIcon(
                          Icons.link,
                          Colors.blueAccent,
                        ), // Twitter replacement
                        _buildSocialIcon(
                          Icons.call,
                          Colors.green,
                        ), // WhatsApp replacement
                        _buildSocialIcon(Icons.copy, Colors.grey),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF2C3E50)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF5E60CE)),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }
}
