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
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final request = http.MultipartRequest('POST', uri);

      // Add fields
      request.fields.addAll(fields);

      // Add headers if provided
      if (headers != null) {
        request.headers.addAll(headers);
      }

      // Send request with timeout
      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection', 'NETWORK_ERROR');
    } on http.ClientException {
      throw ApiException('Connection failed', 'CONNECTION_ERROR');
    } on Exception catch (e) {
      throw ApiException('Request failed: ${e.toString()}', 'UNKNOWN_ERROR');
    }
  }

  /// Make a GET request
  Future<Map<String, dynamic>> get({
    required String endpoint,
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) async {
    try {
      var uri = Uri.parse('$_baseUrl$endpoint');

      // Add query parameters if provided
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(
        uri,
        headers: headers,
      ).timeout(_timeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection', 'NETWORK_ERROR');
    } on http.ClientException {
      throw ApiException('Connection failed', 'CONNECTION_ERROR');
    } on Exception catch (e) {
      throw ApiException('Request failed: ${e.toString()}', 'UNKNOWN_ERROR');
    }
  }

  /// Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final decodedBody = utf8.decode(response.bodyBytes);
        final jsonResponse = json.decode(decodedBody) as Map<String, dynamic>;
        return jsonResponse;
      } catch (e) {
        throw ApiException('Failed to parse response', 'PARSE_ERROR');
      }
    } else if (response.statusCode == 401) {
      throw ApiException('Unauthorized', 'UNAUTHORIZED');
    } else if (response.statusCode == 403) {
      throw ApiException('Forbidden', 'FORBIDDEN');
    } else if (response.statusCode == 404) {
      throw ApiException('Not found', 'NOT_FOUND');
    } else if (response.statusCode >= 500) {
      throw ApiException('Server error', 'SERVER_ERROR');
    } else {
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