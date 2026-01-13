// Local Authentication Service - Using SQLite Database
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';
import '../models/user_model.dart';

class LocalAuthService {
  final DatabaseService _db = DatabaseService();
  static const String _currentUserIdKey = 'current_user_id';

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
        throw Exception('This email is already registered.\n\nPlease login or use a different email.');
      }

      // Validate inputs
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        throw Exception('All fields are required.\n\nPlease fill in all the details to continue.');
      }

      if (password.length < 6) {
        throw Exception('Password is too short.\n\nPlease use at least 6 characters for better security.');
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

      // Set as current user in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserIdKey, userId);

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
        throw Exception('Please enter both email and password to continue');
      }

      // Get stored password
      final storedPassword = await _db.getPassword(email);
      if (storedPassword == null) {
        throw Exception('No account found with this email address.\n\nPlease check your email or create a new account.');
      }

      // Compare passwords
      if (storedPassword != password) {
        throw Exception('Incorrect password.\n\nPlease check your password and try again.');
      }

      // Get user
      final user = await _db.getUserByEmail(email);
      if (user == null) {
        throw Exception('Account data not found.\n\nPlease contact support for assistance.');
      }

      // Save current user ID to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserIdKey, user.id);

      return true;
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  /// Get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_currentUserIdKey);
      if (userId == null) return null;
      return await _db.getUserById(userId);
    } catch (e) {
      return null;
    }
  }

  /// Get current user ID
  Future<String?> getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_currentUserIdKey);
    } catch (e) {
      return null;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserIdKey);
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
