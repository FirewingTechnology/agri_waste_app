import 'package:flutter/foundation.dart';
import '../../models/user_model.dart';
import '../../services/local_auth_service.dart';

/// Auth Provider - Manages authentication state across the app
/// Provides persistent login functionality
class AuthProvider extends ChangeNotifier {
  final LocalAuthService _authService = LocalAuthService();
  
  UserModel? _currentUser;
  bool _isLoading = true;
  bool _isAuthenticated = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get userRole => _currentUser?.role;

  /// Initialize auth state - Check if user is already logged in
  Future<void> initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        _currentUser = await _authService.getCurrentUser();
        _isAuthenticated = _currentUser != null;
      } else {
        _isAuthenticated = false;
        _currentUser = null;
      }
    } catch (e) {
      _isAuthenticated = false;
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final success = await _authService.login(
        email: email,
        password: password,
      );

      if (success) {
        _currentUser = await _authService.getCurrentUser();
        _isAuthenticated = true;
        notifyListeners();

        return {
          'success': true,
          'message': 'Login successful',
          'user': _currentUser,
        };
      } else {
        return {
          'success': false,
          'message': 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  /// Register new user
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
  }) async {
    try {
      final success = await _authService.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
        role: role,
      );

      if (success) {
        _currentUser = await _authService.getCurrentUser();
        _isAuthenticated = true;
        notifyListeners();

        return {
          'success': true,
          'message': 'Registration successful',
          'user': _currentUser,
        };
      } else {
        return {
          'success': false,
          'message': 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _authService.logout();
      _currentUser = null;
      _isAuthenticated = false;
      notifyListeners();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  /// Refresh current user data
  Future<void> refreshUser() async {
    try {
      _currentUser = await _authService.getCurrentUser();
      _isAuthenticated = _currentUser != null;
      notifyListeners();
    } catch (e) {
      // Handle error silently or log
    }
  }
}
