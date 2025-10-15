import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage Manager - Handles local storage operations
class HHStorageManager {
  static final HHStorageManager _instance = HHStorageManager._internal();
  factory HHStorageManager() => _instance;
  HHStorageManager._internal();

  static const String _keyBearerToken = 'bearer_token';
  static const String _keyUserData = 'user_data';
  static const String _keySelectedLocation = 'selected_location';
  static const String _keyIsLocked = 'is_locked';
  static const String _keyFailedAttempts = 'failed_attempts';
  static const String _keyLockoutTime = 'lockout_time';

  SharedPreferences? _prefs;

  /// Initialize storage
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Ensure preferences are initialized
  Future<SharedPreferences> get _preferences async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  // Token Management
  Future<void> saveBearerToken(String token) async {
    final prefs = await _preferences;
    await prefs.setString(_keyBearerToken, token);
  }

  Future<String?> getBearerToken() async {
    final prefs = await _preferences;
    return prefs.getString(_keyBearerToken);
  }

  Future<void> clearBearerToken() async {
    final prefs = await _preferences;
    await prefs.remove(_keyBearerToken);
  }

  // User Data Management
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await _preferences;
    final jsonString = json.encode(userData);
    await prefs.setString(_keyUserData, jsonString);
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await _preferences;
    final jsonString = prefs.getString(_keyUserData);
    if (jsonString == null) return null;
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  Future<void> clearUserData() async {
    final prefs = await _preferences;
    await prefs.remove(_keyUserData);
  }

  // Location Management
  Future<void> saveSelectedLocation(Map<String, dynamic> locationData) async {
    final prefs = await _preferences;
    final jsonString = json.encode(locationData);
    await prefs.setString(_keySelectedLocation, jsonString);
  }

  Future<Map<String, dynamic>?> getSelectedLocation() async {
    final prefs = await _preferences;
    final jsonString = prefs.getString(_keySelectedLocation);
    if (jsonString == null) return null;
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  Future<void> clearSelectedLocation() async {
    final prefs = await _preferences;
    await prefs.remove(_keySelectedLocation);
  }

  // Lock State Management
  Future<void> saveLockState(bool isLocked) async {
    final prefs = await _preferences;
    await prefs.setBool(_keyIsLocked, isLocked);
  }

  Future<bool> getLockState() async {
    final prefs = await _preferences;
    return prefs.getBool(_keyIsLocked) ?? true; // Default to locked
  }

  // Failed Attempts Management
  Future<void> saveFailedAttempts(int attempts) async {
    final prefs = await _preferences;
    await prefs.setInt(_keyFailedAttempts, attempts);
  }

  Future<int> getFailedAttempts() async {
    final prefs = await _preferences;
    return prefs.getInt(_keyFailedAttempts) ?? 0;
  }

  Future<void> clearFailedAttempts() async {
    final prefs = await _preferences;
    await prefs.remove(_keyFailedAttempts);
  }

  // Lockout Time Management
  Future<void> saveLockoutTime(DateTime lockoutTime) async {
    final prefs = await _preferences;
    await prefs.setString(_keyLockoutTime, lockoutTime.toIso8601String());
  }

  Future<DateTime?> getLockoutTime() async {
    final prefs = await _preferences;
    final timeString = prefs.getString(_keyLockoutTime);
    if (timeString == null) return null;
    return DateTime.parse(timeString);
  }

  Future<void> clearLockoutTime() async {
    final prefs = await _preferences;
    await prefs.remove(_keyLockoutTime);
  }

  // Clear All Data
  Future<void> clearAll() async {
    final prefs = await _preferences;
    await prefs.clear();
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getBearerToken();
    return token != null && token.isNotEmpty;
  }
}