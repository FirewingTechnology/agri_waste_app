import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../core/providers/auth_provider.dart';

// Create registration screen with name, email, password, role
// Store user data in Firebase Firestore

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedRole = AppConstants.farmerRole;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Register using AuthProvider
      final result = await authProvider.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        role: _selectedRole,
      );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        if (result['success']) {
          // Show success dialog
          _showSuccessDialog(
            title: 'Welcome Aboard! 🎉',
            message: 'Your account has been created successfully. Let\'s get started!',
            onContinue: () {
              Navigator.pop(context); // Close dialog
              
              // Navigate based on role
              String route;
              if (_selectedRole == AppConstants.farmerRole) {
                route = '/farmer-dashboard';
              } else if (_selectedRole == AppConstants.manufacturerRole || _selectedRole == AppConstants.processorRole) {
                route = '/manufacturer-dashboard';
              } else {
                route = '/admin-dashboard';
              }
              
              Navigator.pushReplacementNamed(context, route);
            },
          );
        } else {
          _showErrorDialog(
            title: 'Registration Failed',
            message: result['message'] ?? 'Unable to create account. Please try again.',
            icon: Icons.error_outline,
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        _showErrorDialog(
          title: 'Oops! Something Went Wrong',
          message: e.toString().replaceAll('Exception: ', ''),
          icon: Icons.warning_amber_rounded,
        );
      }
    }
  }

  void _showErrorDialog({
    required String title,
    required String message,
    required IconData icon,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.red.shade50,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 48,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Try Again',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSuccessDialog({
    required String title,
    required String message,
    required VoidCallback onContinue,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  AppTheme.primaryGreen.withOpacity(0.1),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    size: 48,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 4,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Title
                Text(
                  'Join Us Today 🌱',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Be part of the sustainable revolution',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),

                // Role Selection
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    '🎭 Select Your Role',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _RoleSelector(
                        role: AppConstants.farmerRole,
                        icon: Icons.agriculture,
                        emoji: '🌾',
                        isSelected: _selectedRole == AppConstants.farmerRole,
                        onTap: () {
                          setState(() {
                            _selectedRole = AppConstants.farmerRole;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _RoleSelector(
                        role: 'Manufacturer',
                        icon: Icons.factory,
                        emoji: '🏭',
                        isSelected: _selectedRole == AppConstants.manufacturerRole || _selectedRole == AppConstants.processorRole,
                        onTap: () {
                          setState(() {
                            _selectedRole = AppConstants.manufacturerRole;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: _RoleSelector(
                      role: AppConstants.adminRole,
                      icon: Icons.admin_panel_settings,
                      emoji: '🛡️',
                      isSelected: _selectedRole == AppConstants.adminRole,
                      onTap: () {
                        setState(() {
                          _selectedRole = AppConstants.adminRole;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Phone Field
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (value.length != 10) {
                      return 'Please enter a valid 10-digit phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Register Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Create Account',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? '),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Login here',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleSelector extends StatelessWidget {
  final String role;
  final IconData icon;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleSelector({
    required this.role,
    required this.icon,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [AppTheme.primaryGreen, AppTheme.darkGreen],
                    )
                  : LinearGradient(
                      colors: [Colors.white, Colors.grey.shade50],
                    ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? AppTheme.primaryGreen : AppTheme.lightGreen.withOpacity(0.5),
                width: isSelected ? 2 : 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryGreen.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              children: [
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 6),
                Icon(
                  icon,
                  size: 32,
                  color: isSelected ? Colors.white : AppTheme.primaryGreen,
                ),
                const SizedBox(height: 8),
                Text(
                  role,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
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
