import 'package:flutter/foundation.dart';
import 'package:hookahhabibi/Managers/HHSessionManager.dart';
import 'package:hookahhabibi/Screen/Menu/Model/HHDishCategoryModel.dart';
import 'package:hookahhabibi/Screen/Menu/Model/HHOfferModel.dart';
import 'package:hookahhabibi/Screen/Menu/Service/HHDishService.dart';
import 'package:hookahhabibi/Screen/Menu/Service/HHOfferService.dart';

/// Menu Manager - Handles menu state and operations
class HHMenuManager extends ChangeNotifier {
  final HHDishService _dishService = HHDishService();
  final HHOfferService _offerService = HHOfferService();
  final HHSessionManager _sessionManager = HHSessionManager();

  // State
  List<HHDishCategoryModel> _categories = [];
  Map<String, HHDishCategoryModel> _currentDishes = {};
  List<HHOfferModel> _offers = [];
  HHDishCategoryModel? _selectedCategory;
  String? _selectedSubCategory;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<HHDishCategoryModel> get categories => _categories;
  Map<String, HHDishCategoryModel> get currentDishes => _currentDishes;
  List<HHOfferModel> get offers => _offers;
  HHDishCategoryModel? get selectedCategory => _selectedCategory;
  String? get selectedSubCategory => _selectedSubCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all dish categories
  Future<bool> loadCategories() async {
    if (!_sessionManager.isLoggedIn) {
      _error = 'User not logged in';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dishService.getDishCategories(
        bearerToken: _sessionManager.bearerToken!,
      );

      if (response.success && response.data != null) {
        _categories = response.data!;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Failed to load categories';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error loading categories: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Load dishes for a category.
  ///
  /// TEMPORARY: the server's `filters[location_id]` and `filters[dish_cat_id]`
  /// aren't reliable yet, so we fetch the entire menu tree unfiltered and
  /// narrow to the requested category client-side. Once the backend filters
  /// are fixed, switch back to passing `locationId` + `dishCatId` to the
  /// service.
  Future<bool> loadDishes({
    required String categoryId,
  }) async {
    if (!_sessionManager.isLoggedIn) {
      _error = 'User not logged in';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dishService.getDishes(
        bearerToken: _sessionManager.bearerToken!,
        // Filters intentionally left empty — see method doc.
      );

      if (response.success && response.data != null) {
        final all = response.data!;
        // Narrow to the requested parent category. If not found, fall back to
        // the full tree so the UI still has something to render.
        _currentDishes = all.containsKey(categoryId)
            ? {categoryId: all[categoryId]!}
            : all;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Failed to load dishes';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error loading dishes: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Load the entire menu (all parent cats with subcats + dishes), unfiltered.
  /// Useful for "browse everything" / search views.
  Future<bool> loadAllDishes() async {
    if (!_sessionManager.isLoggedIn) {
      _error = 'User not logged in';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dishService.getDishes(
        bearerToken: _sessionManager.bearerToken!,
      );

      if (response.success && response.data != null) {
        _currentDishes = response.data!;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Failed to load dishes';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error loading dishes: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Load offer images
  Future<bool> loadOffers() async {
    if (!_sessionManager.isLoggedIn) {
      _error = 'User not logged in';
      notifyListeners();
      return false;
    }

    try {
      final response = await _offerService.getActiveOffers(
        bearerToken: _sessionManager.bearerToken!,
      );

      if (response.success && response.data != null) {
        _offers = response.data!;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Failed to load offers';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error loading offers: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Select a category
  void selectCategory(HHDishCategoryModel category) {
    _selectedCategory = category;
    _selectedSubCategory = null;
    notifyListeners();

    // Load dishes for this category
    loadDishes(categoryId: category.id);
  }

  /// Select a sub-category
  void selectSubCategory(String subCategoryId) {
    _selectedSubCategory = subCategoryId;
    notifyListeners();
  }

  /// Get dishes for selected category
  List<DishModel> getDisplayDishes() {
    if (_currentDishes.isEmpty) return [];

    final allDishes = <DishModel>[];

    _currentDishes.forEach((key, parentCat) {
      // Add dishes from parent category
      allDishes.addAll(parentCat.dishes);

      // Add dishes from subcategories
      for (final subCat in parentCat.subCategories) {
        if (_selectedSubCategory == null || _selectedSubCategory == subCat.id) {
          allDishes.addAll(subCat.dishes);
        }
      }
    });

    return allDishes;
  }

  /// Get all subcategories from current dishes
  List<HHDishCategoryModel> getSubCategories() {
    final subCats = <HHDishCategoryModel>[];

    _currentDishes.forEach((key, parentCat) {
      subCats.addAll(parentCat.subCategories);
    });

    return subCats;
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reset state
  void reset() {
    _categories = [];
    _currentDishes = {};
    _offers = [];
    _selectedCategory = null;
    _selectedSubCategory = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}