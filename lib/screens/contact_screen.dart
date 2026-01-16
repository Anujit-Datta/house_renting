import 'package:flutter/material.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              Text(
                'Get in Touch',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'We\'d love to hear from you. Reach out anytime!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // Info Cards Row
              LayoutBuilder(
                builder: (context, constraints) {
                  // Stack vertically on mobile, horizontally on tablet/web
                  if (constraints.maxWidth < 800) {
                    return Column(
                      children: [
                        _buildInfoCard(
                          context,
                          Icons.location_on,
                          'Address',
                          '123 Main Street\nCityville, Bangladesh',
                        ),
                        const SizedBox(height: 16),
                        _buildInfoCard(
                          context,
                          Icons.phone,
                          'Phone',
                          '+880 1234 567 890',
                        ),
                        const SizedBox(height: 16),
                        _buildInfoCard(
                          context,
                          Icons.email,
                          'Email',
                          'rentify.smtp@gmail.com',
                        ),
                      ],
                    );
                  } else {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            context,
                            Icons.location_on,
                            'Address',
                            '123 Main Street\nCityville, Bangladesh',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInfoCard(
                            context,
                            Icons.phone,
                            'Phone',
                            '+880 1234 567 890',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInfoCard(
                            context,
                            Icons.email,
                            'Email',
                            'rentify.smtp@gmail.com',
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 48),

              // Contact Form
              Container(
                width: 800, // Max width for larger screens
                padding: const EdgeInsets.all(32),
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
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Send Us a Message',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Fill out the form below and we\'ll get back to you as soon as possible',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 32),

                    _buildTextFieldLabel('Your Name'),
                    const SizedBox(height: 8),
                    _buildTextField(context, 'Enter your name'),
                    const SizedBox(height: 16),

                    _buildTextFieldLabel('Your Email'),
                    const SizedBox(height: 8),
                    _buildTextField(context, 'Enter your email'),
                    const SizedBox(height: 16),

                    _buildTextFieldLabel('Your Message'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      context,
                      'Write your message here...',
                      maxLines: 5,
                    ),
                    const SizedBox(height: 32),

                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.send, size: 18),
                      label: const Text('Send Message'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF2C3E50,
                        ), // Dark Blue to match design
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    IconData icon,
    String title,
    String content,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2C3E50), // Dark Blue background for icons
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    String hint, {
    int maxLines = 1,
  }) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Theme.of(
          context,
        ).cardColor, // Use card color (white or dark grey)
        // Override border manually if needed, but theme should handle it
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
      ),
    );
  }
}
