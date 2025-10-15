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
  int _retryCount = 0;
  static const int _maxRetries = 3;

  // Getters
  List<HHLocationModel> get locations => _locations;
  HHLocationModel? get selectedLocation => _selectedLocation;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasLocations => _locations.isNotEmpty;
  bool get hasSelectedLocation => _selectedLocation != null;

  /// Load all locations with retry mechanism
  Future<bool> loadLocations({bool isRetry = false}) async {
    print('\n🗺️  LOCATION MANAGER: Loading locations');
    print('   Is Retry: $isRetry, Retry Count: $_retryCount');

    if (!_sessionManager.isLoggedIn) {
      print('   ❌ User not logged in');
      _error = 'User not logged in';
      notifyListeners();
      return false;
    }

    print('   ✅ User is logged in');
    print('   Bearer Token: ${_sessionManager.bearerToken?.substring(0, 20)}...');

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('   📡 Calling location service...');

      final response = await _locationService.getLocations(
        bearerToken: _sessionManager.bearerToken!,
      );

      print('   📬 Response received - Success: ${response.success}');

      if (response.success && response.data != null) {
        print('   ✅ Locations loaded successfully');
        print('   Total locations: ${response.data!.length}');

        _locations = response.data!;
        _retryCount = 0; // Reset retry count on success
        _isLoading = false;

        // Log each location
        for (var i = 0; i < _locations.length; i++) {
          print('      ${i + 1}. ${_locations[i].title} (${_locations[i].id})');
        }

        notifyListeners();
        return true;
      } else {
        print('   ⚠️  Load failed: ${response.message}');
        print('   Error Code: ${response.errorCode}');

        _error = response.message ?? 'Failed to load locations';

        // Retry logic for network errors
        if (_shouldRetry(response.errorCode) && _retryCount < _maxRetries) {
          _retryCount++;
          print('   🔄 Retrying... (Attempt $_retryCount of $_maxRetries)');

          _isLoading = false;
          notifyListeners();

          // Wait before retrying (exponential backoff)
          await Future.delayed(Duration(seconds: _retryCount * 2));

          return await loadLocations(isRetry: true);
        }

        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('   ❌ Exception occurred: ${e.toString()}');
      print('   Stack trace: ${StackTrace.current}');

      _error = 'Error loading locations: ${e.toString()}';

      // Retry on exception
      if (_retryCount < _maxRetries) {
        _retryCount++;
        print('   🔄 Retrying after exception... (Attempt $_retryCount of $_maxRetries)');

        _isLoading = false;
        notifyListeners();

        await Future.delayed(Duration(seconds: _retryCount * 2));

        return await loadLocations(isRetry: true);
      }

      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Determine if we should retry based on error code
  bool _shouldRetry(String? errorCode) {
    if (errorCode == null) return true;

    final retryableCodes = [
      'NETWORK_ERROR',
      'TIMEOUT_ERROR',
      'CONNECTION_ERROR',
      'SERVER_ERROR',
      'UNKNOWN_ERROR',
    ];

    return retryableCodes.contains(errorCode);
  }

  /// Select a location
  void selectLocation(HHLocationModel location) {
    print('\n📍 Selecting location: ${location.title} (${location.id})');
    _selectedLocation = location;
    _sessionManager.setSelectedLocation(location);
    print('   ✅ Location selected and saved to session');
    notifyListeners();
  }

  /// Select location by ID
  Future<bool> selectLocationById(String locationId) async {
    print('\n📍 Selecting location by ID: $locationId');

    try {
      final location = _locations.firstWhere(
            (loc) => loc.id == locationId,
        orElse: () => throw Exception('Location not found'),
      );

      print('   ✅ Location found: ${location.title}');
      selectLocation(location);
      return true;
    } catch (e) {
      print('   ❌ Error: ${e.toString()}');
      return false;
    }
  }

  /// Get location by ID
  HHLocationModel? getLocationById(String locationId) {
    try {
      return _locations.firstWhere((loc) => loc.id == locationId);
    } catch (e) {
      print('   ⚠️  Location not found: $locationId');
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
    print('\n🔄 Resetting Location Manager');
    _locations = [];
    _selectedLocation = null;
    _isLoading = false;
    _error = null;
    _retryCount = 0;
    notifyListeners();
  }
}