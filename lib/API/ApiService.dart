import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Base API Service for handling HTTP requests
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String _baseUrl = 'https://myapp.hookahhabibi.co.id';
  final Duration _timeout = const Duration(seconds: 30);

  /// Make a POST request with multipart/form-data
  Future<Map<String, dynamic>> postMultipart({
    required String endpoint,
    required Map<String, String> fields,
    Map<String, String>? headers,
  }) async {
    print('🌐 API POST Request Started');
    print('   Endpoint: $_baseUrl$endpoint');
    print('   Fields: ${fields.keys.join(", ")}');
    print('   Fields: ${fields.values.join(", ")}');

    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final request = http.MultipartRequest('POST', uri);

      // Add fields
      request.fields.addAll(fields);
      print('   ✅ Fields added to request');

      // Add headers if provided
      if (headers != null) {
        request.headers.addAll(headers);
        print('   ✅ Headers added to request');
      }

      print('   ⏳ Sending request...');
      // Send request with timeout
      final streamedResponse = await request.send().timeout(_timeout);
      print('   ✅ Response received - Status: ${streamedResponse.statusCode}');

      final response = await http.Response.fromStream(streamedResponse);
      print('   📦 Response body length: ${response.body.length} bytes');

      final result = _handleResponse(response);
      print('   ✅ Response parsed successfully');
      print('   Response keys: ${result.keys.join(", ")}');

      return result;
    } on SocketException catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('Failed host lookup') || errorMsg.contains('No address associated')) {
        print('   ❌ DNS Error: Cannot resolve hostname');
        print('   Error details: $e');
        throw ApiException('DNS resolution failed - hostname cannot be resolved', 'DNS_ERROR');
      } else if (errorMsg.contains('Connection refused')) {
        print('   ❌ Connection Error: Server refused connection');
        print('   Error details: $e');
        throw ApiException('Connection refused', 'CONNECTION_REFUSED');
      } else {
        print('   ❌ Network Error: ${e.osError?.message ?? "Unknown network error"}');
        print('   Error details: $e');
        throw ApiException('Network error: ${e.osError?.message ?? "Unknown"}', 'NETWORK_ERROR');
      }
    } on TimeoutException catch (e) {
      print('   ❌ Timeout Error: Request took too long');
      print('   Error details: $e');
      throw ApiException('Request timeout', 'TIMEOUT_ERROR');
    } on http.ClientException catch (e) {
      print('   ❌ Client Error: Connection failed');
      print('   Error details: $e');
      throw ApiException('Connection failed', 'CONNECTION_ERROR');
    } on Exception catch (e) {
      print('   ❌ Unknown Error: ${e.toString()}');
      throw ApiException('Request failed: ${e.toString()}', 'UNKNOWN_ERROR');
    }
  }

  /// Make a GET request
  Future<Map<String, dynamic>> get({
    required String endpoint,
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) async {
    print('🌐 API GET Request Started');
    print('   Endpoint: $_baseUrl$endpoint');
    if (queryParams != null) {
      print('   Query Params: ${queryParams.keys.join(", ")}');
    }

    try {
      var uri = Uri.parse('$_baseUrl$endpoint');

      // Add query parameters if provided
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
        print('   ✅ Query params added to URL');
      }

      print('   ⏳ Sending request...');
      final response = await http.get(
        uri,
        headers: headers,
      ).timeout(_timeout);

      print('   ✅ Response received - Status: ${response.statusCode}');
      print('   📦 Response body length: ${response.body.length} bytes');

      final result = _handleResponse(response);
      print('   ✅ Response parsed successfully');

      return result;
    } on SocketException catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('Failed host lookup') || errorMsg.contains('No address associated')) {
        print('   ❌ DNS Error: Cannot resolve hostname');
        print('   Error details: $e');
        throw ApiException('DNS resolution failed - hostname cannot be resolved', 'DNS_ERROR');
      } else if (errorMsg.contains('Connection refused')) {
        print('   ❌ Connection Error: Server refused connection');
        print('   Error details: $e');
        throw ApiException('Connection refused', 'CONNECTION_REFUSED');
      } else {
        print('   ❌ Network Error: ${e.osError?.message ?? "Unknown network error"}');
        print('   Error details: $e');
        throw ApiException('Network error: ${e.osError?.message ?? "Unknown"}', 'NETWORK_ERROR');
      }
    } on TimeoutException catch (e) {
      print('   ❌ Timeout Error: Request took too long');
      print('   Error details: $e');
      throw ApiException('Request timeout', 'TIMEOUT_ERROR');
    } on http.ClientException catch (e) {
      print('   ❌ Client Error: Connection failed');
      print('   Error details: $e');
      throw ApiException('Connection failed', 'CONNECTION_ERROR');
    } on Exception catch (e) {
      print('   ❌ Unknown Error: ${e.toString()}');
      throw ApiException('Request failed: ${e.toString()}', 'UNKNOWN_ERROR');
    }
  }

  /// Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    print('   🔍 Handling response - Status Code: ${response.statusCode}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final decodedBody = utf8.decode(response.bodyBytes);
        print('   ✅ Body decoded successfully');

        final jsonResponse = json.decode(decodedBody) as Map<String, dynamic>;
        print('   ✅ JSON parsed successfully');

        return jsonResponse;
      } catch (e) {
        print('   ❌ Parse Error: Failed to parse response');
        print('   Error details: $e');
        print('   Raw response: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');
        throw ApiException('Failed to parse response', 'PARSE_ERROR');
      }
    } else if (response.statusCode == 401) {
      print('   ❌ Unauthorized - Status: 401');
      throw ApiException('Unauthorized', 'UNAUTHORIZED');
    } else if (response.statusCode == 403) {
      print('   ❌ Forbidden - Status: 403');
      throw ApiException('Forbidden', 'FORBIDDEN');
    } else if (response.statusCode == 404) {
      print('   ❌ Not Found - Status: 404');
      throw ApiException('Not found', 'NOT_FOUND');
    } else if (response.statusCode >= 500) {
      print('   ❌ Server Error - Status: ${response.statusCode}');
      throw ApiException('Server error', 'SERVER_ERROR');
    } else {
      print('   ❌ HTTP Error - Status: ${response.statusCode}');
      throw ApiException(
        'Request failed with status: ${response.statusCode}',
        'HTTP_ERROR',
      );
    }
  }
}

/// Custom API Exception
class ApiException implements Exception {
  final String message;
  final String code;

  ApiException(this.message, this.code);

  @override
  String toString() => 'ApiException: $message (Code: $code)';
}