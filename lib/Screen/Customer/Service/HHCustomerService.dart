import 'package:hookahhabibi/API/ApiConstants.dart';
import 'package:hookahhabibi/API/ApiResponseGeneric.dart';
import 'package:hookahhabibi/API/ApiService.dart';
import 'package:hookahhabibi/Screen/Customer/Model/HHCustomerModel.dart';

class HHCustomerService {
  final ApiService _apiService = ApiService();

  /// POST /api/get-customers
  /// Returns a flat list pulled from the top-level `data` array.
  Future<ApiResponse<List<HHCustomerModel>>> getCustomers({
    required String bearerToken,
    required String search,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _apiService.postMultipart(
        endpoint: ApiConstants.getCustomers,
        fields: {
          ApiConstants.fieldBearerToken: bearerToken,
          ApiConstants.fieldSearch: search,
          ApiConstants.fieldPerPage: perPage.toString(),
          ApiConstants.fieldPage: page.toString(),
        },
      );

      if (response[ApiConstants.keyType] == ApiConstants.statusError) {
        return ApiResponse.error(
          message: response[ApiConstants.keyMsg]?.toString() ?? 'Unknown error',
          errorCode: 'API_ERROR',
        );
      }

      final raw = response[ApiConstants.keyData];
      final list = (raw is List)
          ? HHCustomerModel.listFromJson(raw)
          : const <HHCustomerModel>[];

      return ApiResponse.success(data: list);
    } on ApiException catch (e) {
      return ApiResponse.error(message: e.message, errorCode: e.code);
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to fetch customers: $e',
        errorCode: 'FETCH_ERROR',
      );
    }
  }

  /// POST /api/save-customer
  /// Returns the created/updated customer when the API echoes it back.
  Future<ApiResponse<HHCustomerModel>> saveCustomer({
    required String bearerToken,
    required String name,
    required String phone,
    String? notes,
  }) async {
    try {
      final response = await _apiService.postMultipart(
        endpoint: ApiConstants.saveCustomer,
        fields: {
          ApiConstants.fieldBearerToken: bearerToken,
          ApiConstants.fieldName: name,
          ApiConstants.fieldPhone: phone,
          if (notes != null && notes.isNotEmpty)
            ApiConstants.fieldNotes: notes,
        },
      );

      if (response[ApiConstants.keyType] == ApiConstants.statusError) {
        return ApiResponse.error(
          message: response[ApiConstants.keyMsg]?.toString() ?? 'Unknown error',
          errorCode: 'API_ERROR',
        );
      }

      final raw = response[ApiConstants.keyData];
      HHCustomerModel? customer;
      if (raw is Map<String, dynamic>) {
        customer = HHCustomerModel.fromJson(raw);
      } else if (raw is List && raw.isNotEmpty && raw.first is Map) {
        customer = HHCustomerModel.fromJson(
          (raw.first as Map).cast<String, dynamic>(),
        );
      }

      return ApiResponse.success(
        data: customer,
        message: response[ApiConstants.keyMsg]?.toString(),
      );
    } on ApiException catch (e) {
      return ApiResponse.error(message: e.message, errorCode: e.code);
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to save customer: $e',
        errorCode: 'SAVE_ERROR',
      );
    }
  }
}
