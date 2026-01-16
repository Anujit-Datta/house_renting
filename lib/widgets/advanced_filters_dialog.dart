import 'package:flutter/material.dart';

class AdvancedFiltersDialog extends StatefulWidget {
  final String location;
  final String propertyType;
  final int bedrooms;
  final double minRent;
  final double maxRent;

  const AdvancedFiltersDialog({
    super.key,
    this.location = 'Any',
    this.propertyType = 'Any',
    this.bedrooms = 0,
    this.minRent = 0.0,
    this.maxRent = 0.0,
  });

  @override
  State<AdvancedFiltersDialog> createState() => _AdvancedFiltersDialogState();
}

class _AdvancedFiltersDialogState extends State<AdvancedFiltersDialog> {
  // Filter States
  late String _selectedLocation;
  late String _selectedPropertyType;
  late int _selectedBedrooms;
  late RangeValues _priceRange;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.location;
    _selectedPropertyType = widget.propertyType;
    _selectedBedrooms = widget.bedrooms;

    // Handle price range initialization safely
    double start = widget.minRent > 0 ? widget.minRent : 10000;
    double end = widget.maxRent > 0 ? widget.maxRent : 100000;
    // ensure standard range if not set or invalid
    if (start < 5000) start = 5000;
    if (end > 200000) end = 200000;
    if (end < start) end = start + 5000;

    _priceRange = RangeValues(start, end);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Theme.of(context).cardColor,
      child: Container(
        padding: const EdgeInsets.all(24),
        width: 500, // Fixed width for desktop/web feel
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Advanced Filters',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),

            // Location
            _buildLabel('Location'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedLocation,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items:
                      [
                            'Any',
                            'Dhaka',
                            'Chittagong',
                            'Sylhet',
                            'Bashundhara R/A',
                            'Gulshan',
                            'Dhanmondi',
                          ]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  onChanged: (val) => setState(() => _selectedLocation = val!),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Property Type and Bedrooms Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Property Type'),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedPropertyType,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items:
                                [
                                      'Any',
                                      'Apartment',
                                      'House',
                                      'Sublet',
                                      'Office',
                                      'Shop',
                                    ]
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (val) =>
                                setState(() => _selectedPropertyType = val!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Bedrooms'),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _selectedBedrooms,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: [0, 1, 2, 3, 4, 5]
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e == 0 ? 'Any' : '$e+ Beds'),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _selectedBedrooms = val!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Price Range
            _buildLabel('Price Range (Tk)'),
            RangeSlider(
              values: _priceRange,
              min: 5000,
              max: 200000,
              divisions: 195,
              activeColor: Theme.of(context).primaryColor,
              labels: RangeLabels(
                'Tk ${_priceRange.start.round()}',
                'Tk ${_priceRange.end.round()}',
              ),
              onChanged: (values) => setState(() => _priceRange = values),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Min: Tk ${_priceRange.start.round()}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  'Max: Tk ${_priceRange.end.round()}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop({
                    'location': _selectedLocation,
                    'propertyType': _selectedPropertyType,
                    'bedrooms': _selectedBedrooms,
                    'minRent': _priceRange.start,
                    'maxRent': _priceRange.end,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
}
