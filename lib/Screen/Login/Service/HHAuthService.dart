import 'package:flutter/foundation.dart';
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
          'device_name': deviceName ?? 'android_${generateSimpleUUID().substring(0, 12)}',
          'device_token': deviceToken ?? generateSimpleUUID(),
        },
      );

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
        message: e.toString(),
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

      if (response['type'] == 'error') {
        return ApiResponse.error(
          message: response['msg'] ?? 'Failed to fetch user data',
          errorCode: 'API_ERROR',
        );
      }

      final user = HHUserModel.fromJson(response);
      return ApiResponse.success(
        data: user,
        message: response['msg'],
      );
    } on ApiException catch (e) {
      return ApiResponse.error(
        message: e.message,
        errorCode: e.code,
      );
    } catch (e) {
      return ApiResponse.error(
        message: e.toString(),
        errorCode: 'FETCH_ERROR',
      );
    }
  }

  /// Validate bearer token
  Future<bool> validateToken(String bearerToken) async {
    try {
      final response = await getUserData(bearerToken: bearerToken);
      return response.success;
    } catch (_) {
      return false;
    }
  }

  String generateSimpleUUID() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final random = now.toString() + UniqueKey().toString();
    return random.replaceAll(RegExp(r'[^0-9a-zA-Z]'), '');
  }
}