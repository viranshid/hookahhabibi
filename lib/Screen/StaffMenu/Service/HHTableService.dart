import 'package:hookahhabibi/API/ApiConstants.dart';
import 'package:hookahhabibi/API/ApiResponseGeneric.dart';
import 'package:hookahhabibi/API/ApiService.dart';
import 'package:hookahhabibi/Screen/StaffMenu/Model/HHTableModel.dart';

class HHTableService {
  final ApiService _apiService = ApiService();

  Future<ApiResponse<List<HHTablesLocationModel>>> getTables({
    required String bearerToken,
    required int locationId,
  }) async {
    try {
      final response = await _apiService.postMultipart(
        endpoint: ApiConstants.getTables,
        fields: {
          ApiConstants.fieldBearerToken: bearerToken,
          'location_id': locationId.toString(),
        },
      );

      if (response[ApiConstants.keyType] == ApiConstants.statusError) {
        return ApiResponse.error(
          message: response[ApiConstants.keyMsg]?.toString() ?? 'Unknown error',
          errorCode: 'API_ERROR',
        );
      }

      final items = response[ApiConstants.keyItems];
      final rawList = (items is Map && items[ApiConstants.keyData] is List)
          ? items[ApiConstants.keyData] as List
          : (response[ApiConstants.keyData] as List? ?? const []);

      final locations = HHTablesLocationModel.listFromJson(rawList);

      return ApiResponse.success(
        data: locations,
        message: 'Tables fetched successfully',
      );
    } on ApiException catch (e) {
      return ApiResponse.error(message: e.message, errorCode: e.code);
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to fetch tables: $e',
        errorCode: 'FETCH_ERROR',
      );
    }
  }
}
