import 'package:flutter/material.dart';

class RentCalculationDialog extends StatefulWidget {
  final double baseRent;
  final Map<String, double> fees;

  const RentCalculationDialog({
    super.key,
    required this.baseRent,
    required this.fees,
  });

  @override
  State<RentCalculationDialog> createState() => _RentCalculationDialogState();
}

class _RentCalculationDialogState extends State<RentCalculationDialog> {
  // Store dynamic inputs. Key = fee name (e.g., 'Electricity Rate'), Value = user input units
  final Map<String, double> _inputValues = {};

  @override
  Widget build(BuildContext context) {
    // Calculate total
    double totalFees = 0;

    // We need to build the rows first to know the total,
    // but we can just iterate to sum up.
    widget.fees.forEach((key, value) {
      if (key.contains('Rate')) {
        // It's a rate, multiply by input (default 0 or 100?)
        // User mock data is 'Electricity Rate'.
        final units = _inputValues[key] ?? 0.0;
        totalFees += (value * units);
      } else {
        // Fixed fee
        totalFees += value;
      }
    });

    final double totalAmount = widget.baseRent + totalFees;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0.0, 10.0),
              ),
            ],
          ),
          child: SingleChildScrollView(
            // Add scroll in case of keyboard
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Rent Calculation',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 10),

                // Base Rent
                _buildRow(
                  label: 'Base Rent',
                  amount: widget.baseRent,
                  isBold: true,
                  color: const Color(0xFF2C3E50),
                ),
                const SizedBox(height: 10),

                // Fees List
                const Text(
                  'Additional Fees:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),

                // Fee Items
                ...widget.fees.entries.map((entry) {
                  if (entry.key.contains('Rate')) {
                    // Interactive Row
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, left: 12.0),
                      child: _buildInteractiveRow(
                        label: entry.key.replaceFirst(
                          'Rate',
                          'Bill',
                        ), // Rename label
                        rate: entry.value,
                        originalKey: entry.key,
                      ),
                    );
                  } else {
                    // Standard Row
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, left: 12.0),
                      child: _buildRow(
                        label: entry.key,
                        amount: entry.value,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    );
                  }
                }),

                const Divider(thickness: 1.5),
                const SizedBox(height: 10),

                // Total
                _buildRow(
                  label: 'Total Monthly Payment',
                  amount: totalAmount,
                  isBold: true,
                  isTotal: true,
                ),

                const SizedBox(height: 24),

                // Close Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5E60CE),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow({
    required String label,
    required double amount,
    bool isBold = false,
    bool isTotal = false,
    Color? color,
    TextStyle? style,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style:
              style ??
              TextStyle(
                fontSize: isTotal ? 18 : 16,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color:
                    color ??
                    (isTotal ? const Color(0xFF5E60CE) : Colors.black87),
              ),
        ),
        Text(
          'Tk ${amount.toStringAsFixed(0)}',
          style:
              style ??
              TextStyle(
                fontSize: isTotal ? 18 : 16,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color:
                    color ??
                    (isTotal ? const Color(0xFF5E60CE) : Colors.black87),
              ),
        ),
      ],
    );
  }

  Widget _buildInteractiveRow({
    required String label,
    required double rate,
    required String originalKey,
  }) {
    final units = _inputValues[originalKey] ?? 0.0;
    final calculatedAmount = rate * units;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Label
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              Text(
                '(${rate.toStringAsFixed(0)} TK/Unit)',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),

        // Input Field
        Expanded(
          flex: 4,
          child: Container(
            height: 35,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: TextField(
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 8,
                ),
                hintText: 'estimated units',
                hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 14),
              onChanged: (value) {
                setState(() {
                  _inputValues[originalKey] = double.tryParse(value) ?? 0.0;
                });
              },
            ),
          ),
        ),

        // Calculated Total
        Expanded(
          flex: 3,
          child: Text(
            'Tk ${calculatedAmount.toStringAsFixed(0)}',
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
