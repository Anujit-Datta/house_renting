import 'package:flutter/material.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Services')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header Tag
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'WHAT WE OFFER',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                'Our Services at a Glance',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 32),

              // Services Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  // Responsive Grid: 1 column on small screens, 2 on medium, 4 on large
                  int crossAxisCount = 1;
                  if (constraints.maxWidth > 600) crossAxisCount = 2;
                  if (constraints.maxWidth > 1000) crossAxisCount = 4;

                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.95, // Adjust based on card content
                    children: [
                      _buildServiceCard(
                        context,
                        icon: Icons.home,
                        title: 'Family Homes',
                        description:
                            'Find cozy and spacious homes perfect for families, in safe and friendly neighborhoods.',
                        imageUrl:
                            'https://images.unsplash.com/photo-1600596542815-22b8c153bd30?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
                      ),
                      _buildServiceCard(
                        context,
                        icon: Icons.person,
                        title: 'Bachelor Rentals',
                        description:
                            'Affordable, convenient apartments for singles and students with flexible lease options.',
                        imageUrl:
                            'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
                      ),
                      _buildServiceCard(
                        context,
                        icon: Icons.business,
                        title: 'Office Spaces',
                        description:
                            'Premium and budget-friendly office spaces for startups, small businesses, and corporates.',
                        imageUrl:
                            'https://images.unsplash.com/photo-1497366216548-37526070297c?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
                      ),
                      _buildServiceCard(
                        context,
                        icon: Icons.store,
                        title: 'Shops & Sublets',
                        description:
                            'Commercial shops and short-term sublets available for businesses of all sizes.',
                        imageUrl:
                            'https://images.unsplash.com/photo-1441986300917-64674bd600d8?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
                      ),
                      _buildServiceCard(
                        context,
                        icon: Icons.handshake,
                        title: 'Property Management',
                        description:
                            'Comprehensive management services including tenant coordination, maintenance, and rent collection.',
                        imageUrl:
                            'https://images.unsplash.com/photo-1560518883-ce09059eeffa?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
                      ),
                      _buildServiceCard(
                        context,
                        icon: Icons.vpn_key,
                        title: 'Buying & Selling',
                        description:
                            'Expert guidance for buying or selling properties at the best market value.',
                        imageUrl:
                            'https://images.unsplash.com/photo-1560520653-9e0e4c89eb11?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String imageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            // Darken significantly to ensure white text (if theme is dark) or just generally readable
            // Since icons and text color adapt to theme, we need to be careful.
            // If local theme is LIGHT, text is black. Properties might be hard to read on a photo.
            // Best approach: Use a specific style for these cards regardless of theme?
            // Or heavily darken background and force WHITE text?
            // Let's force a dark theme look for these cards for "pop" as typically requested for "rich aesthetics".
            Colors.black.withOpacity(0.7),
            BlendMode.darken,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.white), // Force White Icon
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Force White Text
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70, // Force Lighter White Text
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
