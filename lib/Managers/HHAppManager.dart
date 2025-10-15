import 'package:flutter/foundation.dart';
import 'package:hookahhabibi/API/ApiResponseGeneric.dart';
import 'package:hookahhabibi/Managers/HHLocationManager.dart';
import 'package:hookahhabibi/Managers/HHMenuManager.dart';
import 'package:hookahhabibi/Managers/HHSessionManager.dart';
import 'package:hookahhabibi/Managers/HHStorageManager.dart';
import 'package:hookahhabibi/Managers/HHLockManager.dart';
import 'package:hookahhabibi/Screen/Login/Service/HHAuthService.dart';

/// App Manager - Central coordinator for all managers
class HHAppManager extends ChangeNotifier {
  static final HHAppManager _instance = HHAppManager._internal();
  factory HHAppManager() => _instance;
  HHAppManager._internal();

  // Services
  final HHAuthService _authService = HHAuthService();
  final HHStorageManager _storage = HHStorageManager();

  // Managers
  final HHSessionManager sessionManager = HHSessionManager();
  final HHLocationManager locationManager = HHLocationManager();
  final HHMenuManager menuManager = HHMenuManager();
  final HHLockManager lockManager = HHLockManager();

  // State
  bool _isInitializing = false;
  bool _isInitialized = false;
  String? _error;

  // Getters
  bool get isInitializing => _isInitializing;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  bool get isLoggedIn => sessionManager.isLoggedIn;

  /// Initialize app
  Future<bool> initialize() async {
    print('\n🚀 APP MANAGER: Initializing');

    if (_isInitialized) {
      print('   ✅ Already initialized');
      return sessionManager.isLoggedIn;
    }

    _isInitializing = true;
    _error = null;
    notifyListeners();

    try {
      // Step 1: Ensure session is initialized
      print('   📦 Step 1: Initializing session manager');
      if (!sessionManager.isInitialized) {
        await sessionManager.initialize();
      }
      print('   ✅ Session manager initialized');
      print('   Is Logged In: ${sessionManager.isLoggedIn}');

      // Step 2: Check if user is already logged in
      if (sessionManager.isLoggedIn) {
        print('   👤 User is logged in, validating token');
        print('   Bearer Token: ${sessionManager.bearerToken?.substring(0, 20)}...');

        // Validate token
        final isValid = await _authService.validateToken(
          sessionManager.bearerToken!,
        );

        if (!isValid) {
          print('   ❌ Token validation failed, logging out');
          await sessionManager.logout();
          _isInitializing = false;
          _isInitialized = true;
          notifyListeners();
          return false;
        }

        print('   ✅ Token is valid');
        _isInitializing = false;
        _isInitialized = true;
        notifyListeners();
        return true;
      }

      print('   ℹ️  User not logged in');
      _isInitializing = false;
      _isInitialized = true;
      notifyListeners();
      return false;
    } catch (e) {
      print('   ❌ Initialization error: ${e.toString()}');
      print('   Stack trace: ${StackTrace.current}');

      _error = 'Failed to initialize app: ${e.toString()}';
      _isInitializing = false;
      _isInitialized = true;
      notifyListeners();
      return false;
    }
  }

  /// Login user
  Future<ApiResponse<bool>> login({
    required String email,
    required String password,
  }) async {
    print('\n🔐 APP MANAGER: Login started');
    print('   Email: $email');

    try {
      // Step 1: Attempt login
      print('   📡 Step 1: Calling auth service login');
      final loginResponse = await _authService.login(
        email: email,
        password: password,
      );

      if (!loginResponse.success || loginResponse.data == null) {
        print('   ❌ Login failed: ${loginResponse.message}');
        return ApiResponse.error(
          message: loginResponse.message ?? 'Login failed',
          errorCode: loginResponse.errorCode,
        );
      }

      print('   ✅ Login API call successful');
      final bearerToken = loginResponse.data!.bearerToken;
      print('   Bearer Token: ${bearerToken.substring(0, 20)}...');

      // Step 2: Fetch user data
      print('   📡 Step 2: Fetching user data');
      final userResponse = await _authService.getUserData(
        bearerToken: bearerToken,
      );

      if (!userResponse.success || userResponse.data == null) {
        print('   ❌ Failed to fetch user data');
        return ApiResponse.error(
          message: 'Failed to fetch user data',
          errorCode: 'USER_FETCH_ERROR',
        );
      }

      print('   ✅ User data fetched successfully');
      print('   User: ${userResponse.data!.fullName} (${userResponse.data!.email})');

      // Step 3: Set session (this will save to storage)
      print('   💾 Step 3: Saving session');
      await sessionManager.login(
        bearerToken: bearerToken,
        user: userResponse.data!,
      );
      print('   ✅ Session saved');

      // Step 4: Load initial data
      print('   📦 Step 4: Loading initial data');
      await _loadInitialData();
      print('   ✅ Initial data loaded');

      notifyListeners();

      print('   🎉 Login process completed successfully');
      return ApiResponse.success(
        data: true,
        message: 'Login successful',
      );
    } catch (e) {
      print('   ❌ Login error: ${e.toString()}');
      print('   Stack trace: ${StackTrace.current}');

      return ApiResponse.error(
        message: 'Login error: ${e.toString()}',
        errorCode: 'LOGIN_ERROR',
      );
    }
  }

  /// Load initial data after login
  Future<void> _loadInitialData() async {
    print('\n📦 Loading initial data');

    try {
      // Load locations
      print('   🗺️  Loading locations...');
      final locationsLoaded = await locationManager.loadLocations();

      if (locationsLoaded) {
        print('   ✅ Locations loaded: ${locationManager.locations.length}');
      } else {
        print('   ⚠️  Failed to load locations: ${locationManager.error}');
      }

      // Load dish categories
      print('   🍽️  Loading dish categories...');
      final categoriesLoaded = await menuManager.loadCategories();

      if (categoriesLoaded) {
        print('   ✅ Categories loaded: ${menuManager.categories.length}');
      } else {
        print('   ⚠️  Failed to load categories: ${menuManager.error}');
      }
    } catch (e) {
      print('   ❌ Error loading initial data: ${e.toString()}');
    }
  }

  /// Logout user
  Future<void> logout() async {
    print('\n🚪 APP MANAGER: Logging out');

    await sessionManager.logout();
    locationManager.reset();
    menuManager.reset();
    await lockManager.reset();

    print('   ✅ Logout completed');
    notifyListeners();
  }

  /// Select location and load menu
  Future<bool> selectLocation(String locationId) async {
    print('\n📍 APP MANAGER: Selecting location');
    print('   Location ID: $locationId');

    try {
      await locationManager.selectLocationById(locationId);
      print('   ✅ Location selected in manager');

      // Load offers
      print('   🎁 Loading offers...');
      await menuManager.loadOffers();
      print('   ✅ Offers loaded: ${menuManager.offers.length}');

      // If a category is selected, reload dishes
      if (menuManager.selectedCategory != null) {
        print('   🍽️  Reloading dishes for selected category...');
        await menuManager.loadDishes(
          categoryId: menuManager.selectedCategory!.id,
        );
        print('   ✅ Dishes reloaded');
      }

      return true;
    } catch (e) {
      print('   ❌ Error selecting location: ${e.toString()}');
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
  Future<void> resetAll() async {
    print('\n🔄 APP MANAGER: Resetting all');

    await sessionManager.clear();
    locationManager.reset();
    menuManager.reset();
    await lockManager.reset();
    _error = null;
    _isInitialized = false;

    print('   ✅ All managers reset');
    notifyListeners();
  }
}