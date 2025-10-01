

import 'package:hookahhabibi/API/ApiResponseGeneric.dart';
import 'package:hookahhabibi/API/ApiService.dart';
import 'package:hookahhabibi/Screen/Location/Model/HHLocationModel.dart';

/// Location Service
class HHLocationService {
  final ApiService _apiService = ApiService();

  /// Get all locations
  Future<ApiResponse<List<HHLocationModel>>> getLocations({
    required String bearerToken,
  }) async {
    try {
      final response = await _apiService.postMultipart(
        endpoint: '/api/get-locations',
        fields: {
          'bearer_token': bearerToken,
        },
      );

      // Parse paginated response
      final locations = <HHLocationModel>[];
      if (response['items'] != null && response['items']['data'] != null) {
        final dataList = response['items']['data'] as List;
        locations.addAll(
          dataList.map((item) => HHLocationModel.fromJson(item as Map<String, dynamic>)),

        );
      }

      return ApiResponse.success(
        data: locations,
        message: 'Locations fetched successfully',
      );
    } on ApiException catch (e) {
      return ApiResponse.error(
        message: e.message,
        errorCode: e.code,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to fetch locations',
        errorCode: 'FETCH_ERROR',
      );
    }
  }

  /// Get location by ID
  Future<ApiResponse<HHLocationModel>> getLocationById({
    required String bearerToken,
    required String locationId,
  }) async {
    try {
      final response = await getLocations(bearerToken: bearerToken);

      if (response.success && response.data != null) {
        final location = response.data!.firstWhere(
              (loc) => loc.id == locationId,
          orElse: () => throw ApiException('Location not found', 'NOT_FOUND'),
        );

        return ApiResponse.success(
          data: location,
          message: 'Location found',
        );
      }

      return ApiResponse.error(
        message: response.message ?? 'Location not found',
        errorCode: 'NOT_FOUND',
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to fetch location',
        errorCode: 'FETCH_ERROR',
      );
    }
  }
}