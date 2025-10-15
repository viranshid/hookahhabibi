import 'package:flutter/foundation.dart';
import 'package:hookahhabibi/Managers/HHStorageManager.dart';
import 'package:hookahhabibi/Screen/Location/Model/HHLocationModel.dart';
import 'package:hookahhabibi/Screen/User/HHUserModel.dart';

/// Session Manager - Handles user session and app state with persistence
class HHSessionManager extends ChangeNotifier {
  static final HHSessionManager _instance = HHSessionManager._internal();
  factory HHSessionManager() => _instance;
  HHSessionManager._internal();

  final HHStorageManager _storage = HHStorageManager();

  // Session data
  String? _bearerToken;
  HHUserModel? _currentUser;
  HHLocationModel? _selectedLocation;
  bool _isInitialized = false;

  // Getters
  String? get bearerToken => _bearerToken;
  HHUserModel? get currentUser => _currentUser;
  HHLocationModel? get selectedLocation => _selectedLocation;
  bool get isLoggedIn => _bearerToken != null && _bearerToken!.isNotEmpty;
  bool get hasSelectedLocation => _selectedLocation != null;
  bool get isInitialized => _isInitialized;

  /// Initialize session from storage
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load bearer token
      _bearerToken = await _storage.getBearerToken();

      // Load user data
      final userData = await _storage.getUserData();
      if (userData != null) {
        _currentUser = HHUserModel.fromJson(userData);
      }

      // Load selected location
      final locationData = await _storage.getSelectedLocation();
      if (locationData != null) {
        _selectedLocation = HHLocationModel.fromJson(locationData);
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing session: $e');
      _isInitialized = true;
    }
  }

  /// Set bearer token
  Future<void> setBearerToken(String token) async {
    _bearerToken = token;
    await _storage.saveBearerToken(token);
    notifyListeners();
  }

  /// Set current user
  Future<void> setCurrentUser(HHUserModel user) async {
    _currentUser = user;
    await _storage.saveUserData(user.toJson());
    notifyListeners();
  }

  /// Set selected location
  Future<void> setSelectedLocation(HHLocationModel location) async {
    _selectedLocation = location;
    await _storage.saveSelectedLocation(location.toJson());
    notifyListeners();
  }

  /// Login
  Future<void> login({
    required String bearerToken,
    required HHUserModel user,
  }) async {
    _bearerToken = bearerToken;
    _currentUser = user;

    await _storage.saveBearerToken(bearerToken);
    await _storage.saveUserData(user.toJson());

    notifyListeners();
  }

  /// Logout
  Future<void> logout() async {
    _bearerToken = null;
    _currentUser = null;
    _selectedLocation = null;

    await _storage.clearBearerToken();
    await _storage.clearUserData();
    await _storage.clearSelectedLocation();

    notifyListeners();
  }

  /// Clear all session data
  Future<void> clear() async {
    await logout();
    await _storage.clearAll();
  }

  /// Check if session is valid
  bool isSessionValid() {
    return isLoggedIn && _currentUser != null;
  }

  @override
  String toString() {
    return 'HHSessionManager(isLoggedIn: $isLoggedIn, user: ${_currentUser?.email}, location: ${_selectedLocation?.title})';
  }
}