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
    print('\n📍 LOCATION SERVICE: Getting locations');
    print('   Bearer Token: ${bearerToken.substring(0, 20)}...');

    try {
      final response = await _apiService.postMultipart(
        endpoint: '/api/get-locations',
        fields: {
          'bearer_token': bearerToken,
        },
      );

      print('   ✅ API Response received');
      print('   Response Type: ${response['type']}');

      // Check response type
      if (response['type'] == 'error') {
        final errorMsg = response['msg'] ?? 'Unknown error';
        print('   ❌ API returned error: $errorMsg');
        return ApiResponse.error(
          message: errorMsg,
          errorCode: 'API_ERROR',
        );
      }

      // Parse paginated response
      final locations = <HHLocationModel>[];

      print('   🔍 Parsing location data...');

      if (response['items'] == null) {
        print('   ⚠️  Warning: "items" key not found in response');
        print('   Response keys: ${response.keys.join(", ")}');
      }

      if (response['items'] != null && response['items']['data'] != null) {
        final dataList = response['items']['data'] as List;
        print('   📦 Found ${dataList.length} locations in response');

        for (var i = 0; i < dataList.length; i++) {
          try {
            final location = HHLocationModel.fromJson(dataList[i] as Map<String, dynamic>);
            locations.add(location);
            print('   ✅ Parsed location ${i + 1}: ${location.title} (ID: ${location.id})');
          } catch (e) {
            print('   ❌ Error parsing location ${i + 1}: $e');
          }
        }
      } else {
        print('   ⚠️  Warning: No location data found in response');
        print('   Response structure: ${response.toString().substring(0, 200)}...');
      }

      print('   ✅ Total locations parsed: ${locations.length}');

      if (locations.isEmpty) {
        print('   ⚠️  WARNING: No locations returned from API!');
        return ApiResponse.error(
          message: 'No locations available',
          errorCode: 'NO_LOCATIONS',
        );
      }

      return ApiResponse.success(
        data: locations,
        message: 'Locations fetched successfully',
      );
    } on ApiException catch (e) {
      print('   ❌ API Exception: ${e.message}');
      print('   Error Code: ${e.code}');
      return ApiResponse.error(
        message: e.message,
        errorCode: e.code,
      );
    } catch (e) {
      print('   ❌ Unexpected Error: ${e.toString()}');
      print('   Stack trace: ${StackTrace.current}');
      return ApiResponse.error(
        message: 'Failed to fetch locations: ${e.toString()}',
        errorCode: 'FETCH_ERROR',
      );
    }
  }

  /// Get location by ID
  Future<ApiResponse<HHLocationModel>> getLocationById({
    required String bearerToken,
    required String locationId,
  }) async {
    print('\n📍 LOCATION SERVICE: Getting location by ID');
    print('   Location ID: $locationId');

    try {
      final response = await getLocations(bearerToken: bearerToken);

      if (response.success && response.data != null) {
        print('   🔍 Searching for location ID: $locationId');

        try {
          final location = response.data!.firstWhere(
                (loc) => loc.id == locationId,
            orElse: () => throw ApiException('Location not found', 'NOT_FOUND'),
          );

          print('   ✅ Location found: ${location.title}');
          return ApiResponse.success(
            data: location,
            message: 'Location found',
          );
        } catch (e) {
          print('   ❌ Location not found with ID: $locationId');
          return ApiResponse.error(
            message: 'Location not found',
            errorCode: 'NOT_FOUND',
          );
        }
      }

      print('   ❌ Failed to get locations: ${response.message}');
      return ApiResponse.error(
        message: response.message ?? 'Location not found',
        errorCode: 'NOT_FOUND',
      );
    } catch (e) {
      print('   ❌ Error in getLocationById: ${e.toString()}');
      return ApiResponse.error(
        message: 'Failed to fetch location',
        errorCode: 'FETCH_ERROR',
      );
    }
  }
}