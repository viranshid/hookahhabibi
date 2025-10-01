

import 'package:hookahhabibi/API/ApiResponseGeneric.dart';
import 'package:hookahhabibi/API/ApiService.dart';
import 'package:hookahhabibi/Screen/User/HHUserModel.dart';

/// Authentication Service
class HHAuthService {
  final ApiService _apiService = ApiService();

  /// Login with email and password
  Future<ApiResponse<LoginResponse>> login({
    required String email,
    required String password,
    String? deviceName,
    String? deviceToken,
  }) async {
    try {
      final response = await _apiService.postMultipart(
        endpoint: '/api/login',
        fields: {
          'email': email,
          'password': password,
          'device_name': deviceName ?? 'flutter-tablet',
          'device_token': deviceToken ?? 'default-device-token',
        },
      );

      // Check if login was successful
      if (response['type'] == 'success') {
        final loginResponse = LoginResponse.fromJson(response);
        return ApiResponse.success(
          data: loginResponse,
          message: response['msg'],
        );
      } else {
        return ApiResponse.error(
          message: response['msg'] ?? 'Login failed',
          errorCode: 'LOGIN_FAILED',
        );
      }
    } on ApiException catch (e) {
      return ApiResponse.error(
        message: e.message,
        errorCode: e.code,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'An unexpected error occurred',
        errorCode: 'UNKNOWN_ERROR',
      );
    }
  }

  /// Get user data with bearer token
  Future<ApiResponse<HHUserModel>> getUserData({
    required String bearerToken,
  }) async {
    try {
      final response = await _apiService.postMultipart(
        endpoint: '/api/get-user-data',
        fields: {
          'bearer_token': bearerToken,
        },
      );

      final user = HHUserModel.fromJson(response);
      return ApiResponse.success(
        data: user,
        message: 'User data fetched successfully',
      );
    } on ApiException catch (e) {
      return ApiResponse.error(
        message: e.message,
        errorCode: e.code,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to fetch user data',
        errorCode: 'FETCH_ERROR',
      );
    }
  }

  /// Validate bearer token
  Future<bool> validateToken(String bearerToken) async {
    try {
      final response = await getUserData(bearerToken: bearerToken);
      return response.success;
    } catch (e) {
      return false;
    }
  }
}