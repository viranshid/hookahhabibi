import 'package:flutter/foundation.dart';
import 'package:hookahhabibi/Screen/Location/Model/HHLocationModel.dart';
import 'package:hookahhabibi/Screen/User/HHUserModel.dart';


/// Session Manager - Handles user session and app state
class HHSessionManager extends ChangeNotifier {
  static final HHSessionManager _instance = HHSessionManager._internal();
  factory HHSessionManager() => _instance;
  HHSessionManager._internal();

  // Session data
  String? _bearerToken;
  HHUserModel? _currentUser;
  HHLocationModel? _selectedLocation;

  // Getters
  String? get bearerToken => _bearerToken;
  HHUserModel? get currentUser => _currentUser;
  HHLocationModel? get selectedLocation => _selectedLocation;

  bool get isLoggedIn => _bearerToken != null && _bearerToken!.isNotEmpty;
  bool get hasSelectedLocation => _selectedLocation != null;

  /// Set bearer token
  void setBearerToken(String token) {
    _bearerToken = token;
    notifyListeners();
  }

  /// Set current user
  void setCurrentUser(HHUserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  /// Set selected location
  void setSelectedLocation(HHLocationModel location) {
    _selectedLocation = location;
    notifyListeners();
  }

  /// Login
  void login({
    required String bearerToken,
    required HHUserModel user,
  }) {
    _bearerToken = bearerToken;
    _currentUser = user;
    notifyListeners();
  }

  /// Logout
  void logout() {
    _bearerToken = null;
    _currentUser = null;
    _selectedLocation = null;
    notifyListeners();
  }

  /// Clear all session data
  void clear() {
    logout();
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