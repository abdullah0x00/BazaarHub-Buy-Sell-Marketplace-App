import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

/// Auth state management using Provider pattern
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isSeller => _currentUser?.isSeller ?? false;
  bool get isPendingSeller =>
      (_currentUser?.role == UserRole.seller &&
          !(_currentUser?.isApprovedSeller ?? false));
  bool get isDarkMode => _isDarkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  String get selectedLanguage => _selectedLanguage;
  String? get error => _error;

  /// Update profile picture
  Future<bool> updateProfilePicture(File image) async {
    if (_currentUser == null) return false;
    _setLoading(true);
    try {
      final imageUrl = await _authService.uploadFile(image, folder: 'profile_pictures');
      if (imageUrl.isNotEmpty) {
        final updatedUser = _currentUser!.copyWith(avatar: imageUrl);
        // Direct call to service to avoid nested setLoading
        _currentUser = await _authService.updateProfile(updatedUser);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Setter for currentUser to update from outside
  set currentUser(UserModel? user) {
    _currentUser = user;
    notifyListeners();
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _error = null;
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Initialize app state (called on splash screen)
  Future<void> init() async {
    _setLoading(true);
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(AppConstants.keyDarkMode) ?? false;
    _notificationsEnabled =
        prefs.getBool(AppConstants.keyNotifications) ?? true;
    _selectedLanguage = prefs.getString(AppConstants.keyLanguage) ?? 'English';
    _currentUser = await _authService.getSavedUser();
    _setLoading(false);
  }

  /// Login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      final user = await _authService.login(email, password);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      _error = 'Invalid email or password';
      return false;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Register
  Future<bool> register(String name, String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      final user = await _authService.register(
        name: name,
        email: email,
        password: password,
      );
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Forgot password
  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    try {
      return await _authService.forgotPassword(email);
    } finally {
      _setLoading(false);
    }
  }

  /// Apply to become seller
  Future<bool> applyForSeller({
    required String shopName,
    required String cnic,
    required String phone,
    required String bankAccount,
    String? warehouseAddress,
  }) async {
    if (_currentUser == null) return false;
    _setLoading(true);
    try {
      final updated = await _authService.applyForSeller(
        user: _currentUser!,
        shopName: shopName,
        cnic: cnic,
        phone: phone,
        bankAccount: bankAccount,
        warehouseAddress: warehouseAddress,
      );
      _currentUser = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update profile
  Future<bool> updateProfile(UserModel user) async {
    _setLoading(true);
    try {
      _currentUser = await _authService.updateProfile(user);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Complete onboarding step
  Future<void> completeOnboardingStep(String step) async {
    if (_currentUser == null) return;
    try {
      await _authService.updateOnboardingStep(_currentUser!.id, step);
      // Reload user to get updated steps
      _currentUser = await _authService.getSavedUser();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  /// Logout
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }

  /// Toggle dark mode
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyDarkMode, _isDarkMode);
    notifyListeners();
  }

  /// Toggle notifications
  Future<void> toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyNotifications, _notificationsEnabled);
    notifyListeners();
  }

  /// Change language
  Future<void> setLanguage(String language) async {
    _selectedLanguage = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyLanguage, language);
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
