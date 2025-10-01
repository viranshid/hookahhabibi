import 'package:flutter/foundation.dart';
import 'package:hookahhabibi/Managers/HHSessionManager.dart';
import 'package:hookahhabibi/Screen/Location/Model/HHLocationModel.dart';
import 'package:hookahhabibi/Screen/Location/Service/HHLocationService.dart';

/// Location Manager - Handles location state and operations
class HHLocationManager extends ChangeNotifier {
  final HHLocationService _locationService = HHLocationService();
  final HHSessionManager _sessionManager = HHSessionManager();

  // State
  List<HHLocationModel> _locations = [];
  HHLocationModel? _selectedLocation;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<HHLocationModel> get locations => _locations;
  HHLocationModel? get selectedLocation => _selectedLocation;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasLocations => _locations.isNotEmpty;
  bool get hasSelectedLocation => _selectedLocation != null;

  /// Load all locations
  Future<bool> loadLocations() async {
    if (!_sessionManager.isLoggedIn) {
      _error = 'User not logged in';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _locationService.getLocations(
        bearerToken: _sessionManager.bearerToken!,
      );

      if (response.success && response.data != null) {
        _locations = response.data!;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Failed to load locations';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error loading locations: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Select a location
  void selectLocation(HHLocationModel location) {
    _selectedLocation = location;
    _sessionManager.setSelectedLocation(location);
    notifyListeners();
  }

  /// Select location by ID
  Future<bool> selectLocationById(String locationId) async {
    final location = _locations.firstWhere(
          (loc) => loc.id == locationId,
      orElse: () => throw Exception('Location not found'),
    );

    selectLocation(location);
    return true;
  }

  /// Get location by ID
  HHLocationModel? getLocationById(String locationId) {
    try {
      return _locations.firstWhere((loc) => loc.id == locationId);
    } catch (e) {
      return null;
    }
  }

  /// Check if a dish is available at selected location
  bool isDishAvailable(String dishId) {
    if (_selectedLocation == null) return true;
    return !_selectedLocation!.isDishUnavailable(dishId);
  }

  /// Get available locations (active status)
  List<HHLocationModel> get availableLocations {
    return _locations.where((loc) => loc.isActive).toList();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reset state
  void reset() {
    _locations = [];
    _selectedLocation = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}