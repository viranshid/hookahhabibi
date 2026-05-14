import 'package:hookahhabibi/API/ApiResponseGeneric.dart';
import 'package:hookahhabibi/API/ApiService.dart';
import 'package:hookahhabibi/Screen/Menu/Model/HHDishCategoryModel.dart';


/// Dish Service
class HHDishService {
  final ApiService _apiService = ApiService();

  /// Get all dish categories
  Future<ApiResponse<List<HHDishCategoryModel>>> getDishCategories({
    required String bearerToken,
  }) async {
    try {
      final response = await _apiService.postMultipart(
        endpoint: '/api/get-dish-cats',
        fields: {
          'bearer_token': bearerToken,
        },
      );

      // Parse paginated response
      final categories = <HHDishCategoryModel>[];
      if (response['items'] != null && response['items']['data'] != null) {
        final dataList = response['items']['data'] as List;
        categories.addAll(
          dataList.map((item) => HHDishCategoryModel.fromJson(item as Map<String, dynamic>)),
        );
      }

      return ApiResponse.success(
        data: categories,
        message: 'Dish categories fetched successfully',
      );
    } on ApiException catch (e) {
      return ApiResponse.error(
        message: e.message,
        errorCode: e.code,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to fetch dish categories',
        errorCode: 'FETCH_ERROR',
      );
    }
  }

  /// Get dishes with filters
  Future<ApiResponse<Map<String, HHDishCategoryModel>>> getDishes({
    required String bearerToken,
    required String locationId,
    required String dishCatId,
  }) async {
    try {
      final response = await _apiService.postMultipart(
        endpoint: '/api/get-dishes',
        fields: {
          'bearer_token': bearerToken,
          'filters[location_id]': locationId,
          'filters[dish_cat_id]': dishCatId,
        },
      );

      // Parse parent dish categories with nested structure
      final parentDishCats = <String, HHDishCategoryModel>{};

      if (response['parent_dish_cats'] != null) {
        final parentCatsMap = response['parent_dish_cats'] as Map<String, dynamic>;

        parentCatsMap.forEach((key, value) {
          final category = HHDishCategoryModel.fromJson(value as Map<String, dynamic>);
          parentDishCats[key] = category;
        });
      }

      return ApiResponse.success(
        data: parentDishCats,
        message: 'Dishes fetched successfully',
      );
    } on ApiException catch (e) {
      return ApiResponse.error(
        message: e.message,
        errorCode: e.code,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to fetch dishes: ${e.toString()}',
        errorCode: 'FETCH_ERROR',
      );
    }
  }

  /// Get all dishes for a location (all categories)
  Future<ApiResponse<List<DishModel>>> getAllDishesForLocation({
    required String bearerToken,
    required String locationId,
  }) async {
    try {
      // First get all categories
      final categoriesResponse = await getDishCategories(bearerToken: bearerToken);

      if (!categoriesResponse.success || categoriesResponse.data == null) {
        return ApiResponse.error(
          message: 'Failed to fetch categories',
          errorCode: 'FETCH_ERROR',
        );
      }

      final allDishes = <DishModel>[];

      // Fetch dishes for each category
      for (final category in categoriesResponse.data!) {
        final dishesResponse = await getDishes(
          bearerToken: bearerToken,
          locationId: locationId,
          dishCatId: category.id,
        );

        if (dishesResponse.success && dishesResponse.data != null) {
          // Extract all dishes from all categories and subcategories
          dishesResponse.data!.forEach((key, parentCat) {
            allDishes.addAll(parentCat.dishes);
            for (final subCat in parentCat.subCategories) {
              allDishes.addAll(subCat.dishes);
            }
          });
        }
      }

      return ApiResponse.success(
        data: allDishes,
        message: 'All dishes fetched successfully',
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to fetch all dishes',
        errorCode: 'FETCH_ERROR',
      );
    }
  }
}