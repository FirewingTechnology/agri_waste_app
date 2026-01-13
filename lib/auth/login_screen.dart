import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../core/localization/app_strings.dart';
import '../core/localization/language_provider.dart';
import '../core/providers/auth_provider.dart';
import 'register_screen.dart';

// Create login UI with email and password fields
// Add role selection dropdown (Farmer / Processor)
// Validate inputs
// On success navigate to respective dashboard

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  String _selectedRole = AppConstants.farmerRole;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Login using AuthProvider
      final result = await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        if (result['success']) {
          // Get user role from result
          final userRole = result['user']?.role ?? _selectedRole;
          
          // Navigate based on role
          String route;
          if (userRole == AppConstants.farmerRole) {
            route = '/farmer-dashboard';
          } else if (userRole == AppConstants.manufacturerRole || userRole == AppConstants.processorRole) {
            route = '/manufacturer-dashboard';
          } else {
            route = '/admin-dashboard';
          }
          
          Navigator.pushReplacementNamed(context, route);
        } else {
          // Show attractive error dialog
          _showErrorDialog(
            title: 'Login Failed',
            message: result['message'] ?? 'Unable to login. Please try again.',
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
                // Animated Icon
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
                
                // Title
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
                
                // Message
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
                
                // Action Button
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

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 340),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.blue.shade50,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_reset,
                    size: 36,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Title
                const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                
                // Message
                Text(
                  'Don\'t have an account yet?\nRegister now to get started!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _navigateToRegister();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final lang = languageProvider.currentLanguage;
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Logo with Gradient
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryGreen, AppTheme.darkGreen],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.eco,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Welcome Text
                Text(
                  'Welcome Back! 👋',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.loginSubtitle[lang] ?? 'Login to your sustainable journey',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 40),

                // Role Selection
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    '🎭 ${AppStrings.selectRole[lang] ?? 'Select Your Role'}',
                    style: const TextStyle(
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
                        role: AppStrings.farmer[lang] ?? 'Farmer',
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
                        role: AppStrings.manufacturer[lang] ?? 'Manufacturer',
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
                const SizedBox(height: 32),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: AppStrings.email[lang] ?? 'Email Address',
                    prefixIcon: const Icon(Icons.email_outlined),
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
                const SizedBox(height: 20),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: AppStrings.password[lang] ?? 'Password',
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
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      _showForgotPasswordDialog();
                    },
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 28),

                // Login Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            AppStrings.loginButton[lang] ?? 'Login',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppStrings.dontHaveAccount[lang] ?? "Don't have an account? "),
                    TextButton(
                      onPressed: _navigateToRegister,
                      child: Text(
                        AppStrings.registerButton[lang] ?? 'Register here',
                        style: const TextStyle(fontWeight: FontWeight.w700),
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
