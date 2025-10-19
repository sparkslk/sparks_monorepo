import 'package:flutter/foundation.dart';
import 'api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = true;
  Map<String, dynamic>? _user;
  String? _errorMessage;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get user => _user;
  String? get errorMessage => _errorMessage;

  // Check authentication status on app start
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isLoggedIn = await ApiService.isLoggedIn();
      if (_isLoggedIn) {
        _user = await ApiService.getCurrentUser();
      }
    } catch (e) {
      _isLoggedIn = false;
      _user = null;
      if (kDebugMode) {
        print('Auth check error: $e');
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // Login with email and password
  Future<bool> login(String email, String password) async {
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await ApiService.login(email, password);

      if (result['success']) {
        _isLoggedIn = true;
        _user = result['user'];
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred. Please try again.';
      notifyListeners();
      if (kDebugMode) {
        print('Login error: $e');
      }
      return false;
    }
  }

  // Signup
  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    required String role,
    Map<String, dynamic>? metadata,
  }) async {
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await ApiService.signup(
        name: name,
        email: email,
        password: password,
        role: role,
        metadata: metadata,
      );

      if (result['success']) {
        // After successful signup, you might want to auto-login
        // or navigate to login screen
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred. Please try again.';
      notifyListeners();
      if (kDebugMode) {
        print('Signup error: $e');
      }
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await ApiService.logout();
    } catch (e) {
      if (kDebugMode) {
        print('Logout error: $e');
      }
    }

    _isLoggedIn = false;
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Update user data
  void updateUser(Map<String, dynamic> userData) {
    _user = userData;
    notifyListeners();
  }
}
