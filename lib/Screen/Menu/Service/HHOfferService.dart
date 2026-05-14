

import 'package:hookahhabibi/API/ApiResponseGeneric.dart';
import 'package:hookahhabibi/API/ApiService.dart';
import 'package:hookahhabibi/Screen/Menu/Model/HHOfferModel.dart';

/// Offer Service
class HHOfferService {
  final ApiService _apiService = ApiService();

  /// Get all offer images
  Future<ApiResponse<List<HHOfferModel>>> getOfferImages({
    required String bearerToken,
  }) async {
    try {
      final response = await _apiService.postMultipart(
        endpoint: '/api/get-offer-imgs',
        fields: {
          'bearer_token': bearerToken,
        },
      );

      // Parse paginated response
      final offers = <HHOfferModel>[];
      if (response['items'] != null && response['items']['data'] != null) {
        final dataList = response['items']['data'] as List;
        offers.addAll(
          dataList.map((item) => HHOfferModel.fromJson(item as Map<String, dynamic>)),
        );
      }

      return ApiResponse.success(
        data: offers,
        message: 'Offer images fetched successfully',
      );
    } on ApiException catch (e) {
      return ApiResponse.error(
        message: e.message,
        errorCode: e.code,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to fetch offer images',
        errorCode: 'FETCH_ERROR',
      );
    }
  }

  /// Get active offers only
  Future<ApiResponse<List<HHOfferModel>>> getActiveOffers({
    required String bearerToken,
  }) async {
    try {
      final response = await getOfferImages(bearerToken: bearerToken);

      if (response.success && response.data != null) {
        final activeOffers = response.data!.where((offer) => offer.isActive).toList();

        return ApiResponse.success(
          data: activeOffers,
          message: 'Active offers fetched successfully',
        );
      }

      return ApiResponse.error(
        message: response.message ?? 'Failed to fetch active offers',
        errorCode: response.errorCode ?? 'FETCH_ERROR',
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to fetch active offers',
        errorCode: 'FETCH_ERROR',
      );
    }
  }
}