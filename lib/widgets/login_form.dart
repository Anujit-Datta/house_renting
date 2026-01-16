import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:house_renting/controllers/auth_controller.dart';
import 'package:house_renting/screens/tenant_home_screen.dart';
import 'package:house_renting/screens/landlord_home_screen.dart';

class LoginForm extends StatefulWidget {
  final VoidCallback onToggleMode;
  final String role;

  const LoginForm({super.key, required this.onToggleMode, required this.role});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _rememberMe = false;
  bool _obscurePassword = true;

  final _emailController = TextEditingController(text: 'afreen@gmail.com');
  final _passwordController = TextEditingController(text: '123456@');

  @override
  void didUpdateWidget(LoginForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.role != oldWidget.role) {
      if (widget.role == 'Landlord') {
        _emailController.text = 'landlord@example.com';
      } else if (widget.role == 'Tenant') {
        _emailController.text = 'afreen@gmail.com';
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(hintText: 'Email or Username'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
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
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value ?? false;
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
                  'Remember me',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Forgot password?',
                style: TextStyle(color: Color(0xFFFF7F50)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // ... existing checkboxes ...
        const SizedBox(height: 24),
        GetBuilder<AuthController>(
          builder: (authController) {
            return ElevatedButton(
              onPressed: authController.isLoading
                  ? null
                  : () async {
                      final success = await authController.login(
                        _emailController.text.trim(),
                        _passwordController.text,
                        widget.role,
                      );

                      if (success) {
                        // User is logged in and token stored
                        // Navigate based on role (returned from API, or fallback to selected role if API matches)
                        // API returns role in lower case 'tenant', 'landlord'.
                        final role = authController.currentUser?.role
                            .toLowerCase();
                        if (role == 'landlord') {
                          Get.offAll(() => const LandlordHomeScreen());
                        } else {
                          Get.offAll(() => const TenantHomeScreen());
                        }
                      }
                      // Error is handled in controller with snackbar
                    },
              child: authController.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Log in',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            );
          },
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Don't have an account? ",
              style: TextStyle(color: Colors.grey),
            ),
            GestureDetector(
              onTap: widget.onToggleMode,
              child: const Text(
                'Sign up',
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
}
