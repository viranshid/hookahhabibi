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
    print('\n🔐 AUTH SERVICE: Login request');
    print('   Email: $email');
    print('   Device Name: ${deviceName ?? 'default'}');

    try {
      final response = await _apiService.postMultipart(
        endpoint: '/api/login',
        fields: {
          'email': email,
          'password': password,
          'device_name': deviceName ?? "android_${generateSimpleUUID()}",
          'device_token': deviceToken ?? generateSimpleUUID(),
        },
      );

      print('   📬 Login response received');
      print('   Response Type: ${response['type']}');

      // Check if login was successful
      if (response['type'] == 'success') {
        print('   ✅ Login successful');

        final loginResponse = LoginResponse.fromJson(response);
        print('   Bearer Token: ${loginResponse.bearerToken.substring(0, 20)}...');
        print('   Message: ${loginResponse.message}');

        return ApiResponse.success(
          data: loginResponse,
          message: response['msg'],
        );
      } else {
        print('   ❌ Login failed: ${response['msg']}');
        return ApiResponse.error(
          message: response['msg'] ?? 'Login failed',
          errorCode: 'LOGIN_FAILED',
        );
      }
    } on ApiException catch (e) {
      print('   ❌ API Exception: ${e.message}');
      return ApiResponse.error(
        message: e.message,
        errorCode: e.code,
      );
    } catch (e) {
      print('   ❌ Unexpected error: ${e.toString()}');
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
    print('\n👤 AUTH SERVICE: Getting user data');
    print('   Bearer Token: ${bearerToken.substring(0, 20)}...');

    try {
      final response = await _apiService.postMultipart(
        endpoint: '/api/get-user-data',
        fields: {
          'bearer_token': bearerToken,
        },
      );

      print('   📬 User data response received');

      // Check response type
      if (response['type'] == 'error') {
        final errorMsg = response['msg'] ?? 'Unknown error';
        print('   ❌ API returned error: $errorMsg');
        return ApiResponse.error(
          message: errorMsg,
          errorCode: 'API_ERROR',
        );
      }

      print('   🔍 Parsing user data...');
      final user = HHUserModel.fromJson(response);

      print('   ✅ User data parsed successfully');
      print('   User ID: ${user.id}');
      print('   Name: ${user.fullName}');
      print('   Email: ${user.email}');
      print('   Status: ${user.status}');

      return ApiResponse.success(
        data: user,
        message: 'User data fetched successfully',
      );
    } on ApiException catch (e) {
      print('   ❌ API Exception: ${e.message}');
      return ApiResponse.error(
        message: e.message,
        errorCode: e.code,
      );
    } catch (e) {
      print('   ❌ Error parsing user data: ${e.toString()}');
      print('   Stack trace: ${StackTrace.current}');
      return ApiResponse.error(
        message: 'Failed to fetch user data',
        errorCode: 'FETCH_ERROR',
      );
    }
  }

  /// Validate bearer token
  Future<bool> validateToken(String bearerToken) async {
    print('\n🔍 AUTH SERVICE: Validating token');
    print('   Bearer Token: ${bearerToken.substring(0, 20)}...');

    try {
      final response = await getUserData(bearerToken: bearerToken);
      final isValid = response.success;

      print('   ${isValid ? '✅' : '❌'} Token is ${isValid ? 'valid' : 'invalid'}');

      return isValid;
    } catch (e) {
      print('   ❌ Token validation error: ${e.toString()}');
      return false;
    }
  }

  String generateSimpleUUID() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final random = now.toString() + UniqueKey().toString();
    return random.replaceAll(RegExp(r'[^0-9a-zA-Z]'), '');
  }
}