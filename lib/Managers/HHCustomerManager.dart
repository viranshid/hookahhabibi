import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hookahhabibi/Managers/HHSessionManager.dart';
import 'package:hookahhabibi/Screen/Customer/Model/HHCustomerModel.dart';
import 'package:hookahhabibi/Screen/Customer/Service/HHCustomerService.dart';

/// Singleton + ChangeNotifier — drives customer autocomplete on the
/// Tables tab Customer Details box.
class HHCustomerManager extends ChangeNotifier {
  static final HHCustomerManager _instance = HHCustomerManager._internal();
  factory HHCustomerManager() => _instance;
  HHCustomerManager._internal();

  final HHCustomerService _service = HHCustomerService();
  final HHSessionManager _session = HHSessionManager();

  static const Duration _debounce = Duration(milliseconds: 300);
  static const int _minQueryLength = 1;

  Timer? _debounceTimer;
  int _requestSeq = 0;

  // State
  List<HHCustomerModel> _searchResults = const [];
  HHCustomerModel? _selectedCustomer;
  bool _isSearching = false;
  bool _isSaving = false;
  String? _error;
  String _lastQuery = '';

  // Getters
  List<HHCustomerModel> get searchResults => _searchResults;
  HHCustomerModel? get selectedCustomer => _selectedCustomer;
  bool get isSearching => _isSearching;
  bool get isSaving => _isSaving;
  String? get error => _error;
  String get lastQuery => _lastQuery;
  bool get hasSelection => _selectedCustomer != null;

  /// Debounced search — call from a TextField `onChanged`.
  void searchDebounced(String query) {
    _lastQuery = query;
    _debounceTimer?.cancel();

    if (query.trim().length < _minQueryLength) {
      _searchResults = const [];
      _isSearching = false;
      _error = null;
      notifyListeners();
      return;
    }

    _debounceTimer = Timer(_debounce, () => _runSearch(query.trim()));
  }

  Future<void> _runSearch(String query) async {
    final token = _session.bearerToken;
    if (token == null || token.isEmpty) {
      _error = 'Session expired. Please log in again.';
      _isSearching = false;
      notifyListeners();
      return;
    }

    final seq = ++_requestSeq;
    _isSearching = true;
    _error = null;
    notifyListeners();

    final response = await _service.getCustomers(
      bearerToken: token,
      search: query,
    );

    // Discard out-of-order responses.
    if (seq != _requestSeq) return;

    _isSearching = false;
    if (response.success) {
      _searchResults = response.data ?? const [];
    } else {
      _searchResults = const [];
      _error = response.message;
    }
    notifyListeners();
  }

  /// Set the active customer (e.g. after user picks one from suggestions).
  void selectCustomer(HHCustomerModel customer) {
    _selectedCustomer = customer;
    _searchResults = const [];
    _lastQuery = customer.name;
    notifyListeners();
  }

  /// Clear the active selection (e.g. when user edits the name field).
  void clearSelection({bool keepResults = false}) {
    if (_selectedCustomer == null && (keepResults || _searchResults.isEmpty)) {
      return;
    }
    _selectedCustomer = null;
    if (!keepResults) _searchResults = const [];
    notifyListeners();
  }

  /// Clear in-flight suggestions (e.g. when popover closes).
  void clearResults() {
    if (_searchResults.isEmpty && _error == null) return;
    _searchResults = const [];
    _error = null;
    notifyListeners();
  }

  /// POST /api/save-customer and auto-select the returned customer.
  Future<HHCustomerModel?> saveAndSelect({
    required String name,
    required String phone,
    String? notes,
  }) async {
    final token = _session.bearerToken;
    if (token == null || token.isEmpty) {
      _error = 'Session expired. Please log in again.';
      notifyListeners();
      return null;
    }

    _isSaving = true;
    _error = null;
    notifyListeners();

    final response = await _service.saveCustomer(
      bearerToken: token,
      name: name,
      phone: phone,
      notes: notes,
    );

    _isSaving = false;

    if (response.success && response.data != null) {
      _selectedCustomer = response.data;
      _searchResults = const [];
      notifyListeners();
      return response.data;
    }

    _error = response.message ?? 'Failed to save customer';
    notifyListeners();
    return null;
  }

  /// Reset on logout / location change.
  void reset() {
    _debounceTimer?.cancel();
    _requestSeq++;
    _searchResults = const [];
    _selectedCustomer = null;
    _isSearching = false;
    _isSaving = false;
    _error = null;
    _lastQuery = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
