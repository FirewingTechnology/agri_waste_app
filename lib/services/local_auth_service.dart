// Local Authentication Service - Using SQLite Database
import 'database_service.dart';
import '../models/user_model.dart';

class LocalAuthService {
  final DatabaseService _db = DatabaseService();
  
  String? _currentUserId;

  /// Register a new user
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
  }) async {
    try {
      // Check if email already exists
      final existingUser = await _db.getUserByEmail(email);
      if (existingUser != null) {
        throw Exception('Email already registered');
      }

      // Validate inputs
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        throw Exception('All fields are required');
      }

      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      // Create user
      final userId = DateTime.now().millisecondsSinceEpoch.toString();
      final user = UserModel(
        id: userId,
        name: name,
        email: email,
        phone: phone,
        role: role,
        createdAt: DateTime.now(),
      );

      // Save credentials
      await _db.saveCredentials(email, password);

      // Save user
      await _db.insertUser(user);

      // Set as current user
      _currentUserId = userId;

      return true;
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  /// Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      // Validate credentials
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password required');
      }

      // Get stored password
      final storedPassword = await _db.getPassword(email);
      if (storedPassword == null) {
        throw Exception('User not found');
      }

      // Compare passwords
      if (storedPassword != password) {
        throw Exception('Invalid password');
      }

      // Get user
      final user = await _db.getUserByEmail(email);
      if (user == null) {
        throw Exception('User not found');
      }

      // Set as current user
      _currentUserId = user.id;

      return true;
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  /// Get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      if (_currentUserId == null) return null;
      return await _db.getUserById(_currentUserId!);
    } catch (e) {
      return null;
    }
  }

  /// Get current user ID
  String? getCurrentUserId() {
    return _currentUserId;
  }

  /// Logout
  Future<void> logout() async {
    try {
      _currentUserId = null;
    } catch (e) {
      throw Exception('Logout error: $e');
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final user = await getCurrentUser();
      return user != null;
    } catch (e) {
      return false;
    }
  }

  /// Change password
  Future<bool> changePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      // Verify old password
      final storedPassword = await _db.getPassword(email);
      if (storedPassword != oldPassword) {
        throw Exception('Old password is incorrect');
      }

      // Update password
      await _db.updatePassword(email, newPassword);
      return true;
    } catch (e) {
      throw Exception('Password change error: $e');
    }
  }
}
