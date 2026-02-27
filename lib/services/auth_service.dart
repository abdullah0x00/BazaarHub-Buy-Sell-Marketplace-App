import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

/// Simulated authentication service (replace with real API in production)
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // In-memory user store for demo
  final List<UserModel> _users = UserModel.mockUsers();

  /// Login with email and password
  Future<UserModel?> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Find user by email
    final user = _users.firstWhere(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
      orElse: () => UserModel(
        id: '',
        name: '',
        email: '',
        createdAt: DateTime.now(),
      ),
    );

    if (user.id.isEmpty) return null;
    if (user.isBlocked) throw Exception('Your account has been blocked.');

    // For demo, accept any password
    await _saveUser(user);
    return user;
  }

  /// Register a new user
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Check if email already exists
    final exists = _users.any(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
    );
    if (exists) throw Exception('An account with this email already exists.');

    final newUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      createdAt: DateTime.now(),
    );

    _users.add(newUser);
    await _saveUser(newUser);
    return newUser;
  }

  /// Update user profile
  Future<UserModel> updateProfile(UserModel user) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final idx = _users.indexWhere((u) => u.id == user.id);
    if (idx != -1) _users[idx] = user;
    await _saveUser(user);
    return user;
  }

  /// Apply to become seller
  Future<UserModel> applyForSeller({
    required UserModel user,
    required String shopName,
    required String cnic,
    required String phone,
    required String bankAccount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Set isApprovedSeller to true for auto-approval
    final updatedUser = user.copyWith(
      role: UserRole.seller,
      shopName: shopName,
      cnic: cnic,
      phone: phone,
      bankAccount: bankAccount,
      isApprovedSeller: true, // Auto-approved
    );
    final idx = _users.indexWhere((u) => u.id == user.id);
    if (idx != -1) _users[idx] = updatedUser;
    await _saveUser(updatedUser);
    return updatedUser;
  }

  /// Approve a seller (admin only)
  Future<void> approveSeller(String userId) async {
    final idx = _users.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      _users[idx] = _users[idx].copyWith(isApprovedSeller: true);
    }
  }

  /// Block or unblock a user
  Future<void> toggleBlockUser(String userId) async {
    final idx = _users.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      _users[idx] = _users[idx].copyWith(
        isBlocked: !_users[idx].isBlocked,
      );
    }
  }

  /// Get all users (admin)
  Future<List<UserModel>> getAllUsers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _users.where((u) => !u.isAdmin).toList();
  }

  /// Get pending sellers (admin)
  Future<List<UserModel>> getPendingSellers() async {
    return _users
        .where(
          (u) => u.role == UserRole.seller && !u.isApprovedSeller,
        )
        .toList();
  }

  /// Forgot password (simulated)
  Future<bool> forgotPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final exists = _users.any(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
    );
    return exists;
  }

  /// Logout - clear saved user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyUserData);
    await prefs.remove(AppConstants.keyAuthToken);
  }

  /// Get saved user from local storage
  Future<UserModel?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(AppConstants.keyUserData);
    if (userData == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(userData));
    } catch (_) {
      return null;
    }
  }

  /// Save user to local storage
  Future<void> _saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.keyUserData,
      jsonEncode(user.toJson()),
    );
    await prefs.setString(AppConstants.keyAuthToken, 'token_${user.id}');
  }
}
