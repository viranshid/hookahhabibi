import 'package:flutter/foundation.dart';
import 'package:hookahhabibi/API/ApiResponseGeneric.dart';
import 'package:hookahhabibi/Managers/HHLocationManager.dart';
import 'package:hookahhabibi/Managers/HHMenuManager.dart';
import 'package:hookahhabibi/Managers/HHSessionManager.dart';
import 'package:hookahhabibi/Screen/Login/Service/HHAuthService.dart';


/// App Manager - Central coordinator for all managers
class HHAppManager extends ChangeNotifier {
  static final HHAppManager _instance = HHAppManager._internal();
  factory HHAppManager() => _instance;
  HHAppManager._internal();

  // Services
  final HHAuthService _authService = HHAuthService();

  // Managers
  final HHSessionManager sessionManager = HHSessionManager();
  final HHLocationManager locationManager = HHLocationManager();
  final HHMenuManager menuManager = HHMenuManager();

  // State
  bool _isInitializing = false;
  String? _error;

  // Getters
  bool get isInitializing => _isInitializing;
  String? get error => _error;
  bool get isLoggedIn => sessionManager.isLoggedIn;

  /// Initialize app
  Future<bool> initialize() async {
    _isInitializing = true;
    _error = null;
    notifyListeners();

    try {
      // Check if user is already logged in
      if (sessionManager.isLoggedIn) {
        // Validate token
        final isValid = await _authService.validateToken(
          sessionManager.bearerToken!,
        );

        if (!isValid) {
          sessionManager.logout();
        }
      }

      _isInitializing = false;
      notifyListeners();
      return sessionManager.isLoggedIn;
    } catch (e) {
      _error = 'Failed to initialize app: ${e.toString()}';
      _isInitializing = false;
      notifyListeners();
      return false;
    }
  }

  /// Login user
  Future<ApiResponse<bool>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Attempt login
      final loginResponse = await _authService.login(
        email: email,
        password: password,
      );

      if (!loginResponse.success || loginResponse.data == null) {
        return ApiResponse.error(
          message: loginResponse.message ?? 'Login failed',
          errorCode: loginResponse.errorCode,
        );
      }

      final bearerToken = loginResponse.data!.bearerToken;

      // Fetch user data
      final userResponse = await _authService.getUserData(
        bearerToken: bearerToken,
      );

      if (!userResponse.success || userResponse.data == null) {
        return ApiResponse.error(
          message: 'Failed to fetch user data',
          errorCode: 'USER_FETCH_ERROR',
        );
      }

      // Set session
      sessionManager.login(
        bearerToken: bearerToken,
        user: userResponse.data!,
      );

      // Load initial data
      await _loadInitialData();

      notifyListeners();

      return ApiResponse.success(
        data: true,
        message: 'Login successful',
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Login error: ${e.toString()}',
        errorCode: 'LOGIN_ERROR',
      );
    }
  }

  /// Load initial data after login
  Future<void> _loadInitialData() async {
    // Load locations
    await locationManager.loadLocations();

    // Load dish categories
    await menuManager.loadCategories();
  }

  /// Logout user
  Future<void> logout() async {
    sessionManager.logout();
    locationManager.reset();
    menuManager.reset();
    notifyListeners();
  }

  /// Select location and load menu
  Future<bool> selectLocation(String locationId) async {
    try {
      await locationManager.selectLocationById(locationId);

      // Load offers
      await menuManager.loadOffers();

      // If a category is selected, reload dishes
      if (menuManager.selectedCategory != null) {
        await menuManager.loadDishes(
          categoryId: menuManager.selectedCategory!.id,
        );
      }

      return true;
    } catch (e) {
      _error = 'Failed to select location: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reset all managers
  void resetAll() {
    sessionManager.clear();
    locationManager.reset();
    menuManager.reset();
    _error = null;
    notifyListeners();
  }
}