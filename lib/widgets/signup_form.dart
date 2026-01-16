import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class SignupForm extends StatefulWidget {
  final VoidCallback onToggleMode;
  final String role;

  const SignupForm({super.key, required this.onToggleMode, required this.role});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  bool _agreeToTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _verificationMethod = 'Verify via Email';
  String? _nidFrontPath;
  String? _nidBackPath;

  double _passwordStrength = 0.0;
  String _passwordStrengthText = '';
  Color _passwordStrengthColor = Colors.grey;

  void _updatePasswordStrength(String password) {
    setState(() {
      if (password.isEmpty) {
        _passwordStrength = 0.0;
        _passwordStrengthText = '';
        _passwordStrengthColor = Colors.grey;
      } else if (password.length < 6) {
        _passwordStrength = 0.3;
        _passwordStrengthText = 'Weak';
        _passwordStrengthColor = Colors.red;
      } else if (password.length < 10) {
        _passwordStrength = 0.6;
        _passwordStrengthText = 'Medium';
        _passwordStrengthColor = Colors.orange;
      } else {
        _passwordStrength = 1.0;
        _passwordStrengthText = 'Strong';
        _passwordStrengthColor = Colors.green;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(decoration: const InputDecoration(hintText: 'Username')),
        const SizedBox(height: 8),
        // Username available indicator (mock)
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_box, color: Colors.green, size: 16),
            SizedBox(width: 4),
            Text(
              'Username available',
              style: TextStyle(color: Colors.green, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: const InputDecoration(hintText: 'test@example.com'),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: '+880 (BD)',
                    dropdownColor: const Color(0xFF2C2C2C),
                    items: const [
                      DropdownMenuItem(
                        value: '+880 (BD)',
                        child: Text(
                          '+880 (BD)',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      DropdownMenuItem(
                        value: '+1 (US)',
                        child: Text(
                          '+1 (US)',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                    onChanged: (value) {},
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: TextFormField(
                decoration: const InputDecoration(hintText: '1628275089'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            hintText: 'NID Number', // Implied from 6519498656
          ),
        ),
        const SizedBox(height: 16),

        // NID Uploads
        _buildFileUpload(
          'Upload NID Front:',
          _nidFrontPath,
          (path) => setState(() => _nidFrontPath = path),
        ),
        const SizedBox(height: 16),
        _buildFileUpload(
          'Upload NID Back:',
          _nidBackPath,
          (path) => setState(() => _nidBackPath = path),
        ),

        const SizedBox(height: 16),
        TextFormField(
          obscureText: _obscurePassword,
          onChanged: _updatePasswordStrength,
          decoration: InputDecoration(
            hintText: 'Password',
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Password Strength
        if (_passwordStrength > 0) ...[
          Center(
            child: Text(
              _passwordStrengthText,
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: _passwordStrength,
            backgroundColor: Colors.grey[800],
            valueColor: AlwaysStoppedAnimation<Color>(_passwordStrengthColor),
          ),
        ],
        const SizedBox(height: 16),
        TextFormField(
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            hintText: 'Confirm Password',
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: _agreeToTerms,
                onChanged: (value) {
                  setState(() {
                    _agreeToTerms = value ?? false;
                  });
                },
                fillColor: MaterialStateProperty.resolveWith(
                  (states) => states.contains(MaterialState.selected)
                      ? Colors.white
                      : Colors.transparent,
                ),
                checkColor: Colors.black,
                side: const BorderSide(color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'I agree to the ',
              style: TextStyle(color: Colors.white),
            ),
            const Text(
              'Terms & Conditions',
              style: TextStyle(color: Color(0xFFFF7F50)),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            const Text(
              'Choose Verification Method: ',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                height: 30,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _verificationMethod,
                    dropdownColor: Colors.white,
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.black,
                    ),
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                    items: const [
                      DropdownMenuItem(
                        value: 'Verify via Email',
                        child: Text('Verify via Email'),
                      ),
                      DropdownMenuItem(
                        value: 'Verify via SMS',
                        child: Text('Verify via SMS'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _verificationMethod = value!;
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Signing up as ${widget.role}...')),
            );
          },
          child: const Text(
            'Sign Up',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Already have an account? ",
              style: TextStyle(color: Colors.grey),
            ),
            GestureDetector(
              onTap: widget.onToggleMode,
              child: const Text(
                'Log in',
                style: TextStyle(
                  color: Color(0xFFFF7F50),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFileUpload(
    String label,
    String? filePath,
    Function(String) onFileSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2C),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform
                      .pickFiles();

                  if (result != null) {
                    onFileSelected(result.files.single.name);
                  } else {
                    // User canceled the picker
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                ),
                child: const Text('Choose File'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  filePath ?? 'No file chosen',
                  style: const TextStyle(color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
