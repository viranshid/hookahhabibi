import 'package:flutter/foundation.dart';
import 'package:hookahhabibi/Managers/HHStorageManager.dart';
import 'dart:async';

/// Lock Manager - Handles menu lock/unlock state and PIN attempts
class HHLockManager extends ChangeNotifier {
  static final HHLockManager _instance = HHLockManager._internal();
  factory HHLockManager() => _instance;
  HHLockManager._internal() {
    _init();
  }

  final HHStorageManager _storage = HHStorageManager();

  bool _isLocked = true;
  int _failedAttempts = 0;
  DateTime? _lockoutTime;
  Timer? _lockoutTimer;

  static const int maxAttempts = 3;
  static const int lockoutDurationSeconds = 30;

  // Getters
  bool get isLocked => _isLocked;
  int get failedAttempts => _failedAttempts;
  int get remainingAttempts => maxAttempts - _failedAttempts;
  bool get isLockedOut => _lockoutTime != null && DateTime.now().isBefore(_lockoutTime!);
  DateTime? get lockoutTime => _lockoutTime;

  /// Get remaining lockout time in seconds
  int get remainingLockoutSeconds {
    if (!isLockedOut) return 0;
    return _lockoutTime!.difference(DateTime.now()).inSeconds;
  }

  /// Initialize lock manager
  Future<void> _init() async {
    await _loadState();
    _startLockoutTimerIfNeeded();
  }

  /// Load state from storage
  Future<void> _loadState() async {
    _isLocked = await _storage.getLockState();
    _failedAttempts = await _storage.getFailedAttempts();
    _lockoutTime = await _storage.getLockoutTime();

    // Check if lockout has expired
    if (_lockoutTime != null && DateTime.now().isAfter(_lockoutTime!)) {
      await _clearLockout();
    }

    notifyListeners();
  }

  /// Lock the menu
  Future<void> lock() async {
    _isLocked = true;
    await _storage.saveLockState(true);
    notifyListeners();
  }

  /// Unlock the menu
  Future<void> unlock() async {
    _isLocked = false;
    await _storage.saveLockState(false);
    await _clearLockout(); // Clear any lockout when successfully unlocked
    notifyListeners();
  }

  /// Attempt to unlock with PIN
  Future<bool> attemptUnlock(String pin, String? correctPin) async {
    // Check if locked out
    if (isLockedOut) {
      return false;
    }

    // Check if no PIN is set
    if (correctPin == null || correctPin.isEmpty) {
      await unlock();
      return true;
    }

    // Check PIN
    if (pin == correctPin) {
      await unlock();
      return true;
    } else {
      await _recordFailedAttempt();
      return false;
    }
  }

  /// Record a failed unlock attempt
  Future<void> _recordFailedAttempt() async {
    _failedAttempts++;
    await _storage.saveFailedAttempts(_failedAttempts);

    if (_failedAttempts >= maxAttempts) {
      await _startLockout();
    }

    notifyListeners();
  }

  /// Start lockout period
  Future<void> _startLockout() async {
    _lockoutTime = DateTime.now().add(Duration(seconds: lockoutDurationSeconds));
    await _storage.saveLockoutTime(_lockoutTime!);
    _startLockoutTimerIfNeeded();
    notifyListeners();
  }

  /// Start timer to clear lockout after duration
  void _startLockoutTimerIfNeeded() {
    if (_lockoutTime != null && DateTime.now().isBefore(_lockoutTime!)) {
      final duration = _lockoutTime!.difference(DateTime.now());

      _lockoutTimer?.cancel();
      _lockoutTimer = Timer(duration, () {
        _clearLockout();
      });
    }
  }

  /// Clear lockout and reset attempts
  Future<void> _clearLockout() async {
    _failedAttempts = 0;
    _lockoutTime = null;
    _lockoutTimer?.cancel();
    _lockoutTimer = null;

    await _storage.clearFailedAttempts();
    await _storage.clearLockoutTime();

    notifyListeners();
  }

  /// Reset lock manager (for logout)
  Future<void> reset() async {
    _isLocked = true;
    _failedAttempts = 0;
    _lockoutTime = null;
    _lockoutTimer?.cancel();
    _lockoutTimer = null;

    await _storage.saveLockState(true);
    await _storage.clearFailedAttempts();
    await _storage.clearLockoutTime();

    notifyListeners();
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    super.dispose();
  }
}