import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:hookahhabibi/API/ApiConstants.dart';

/// Base API Service for handling HTTP requests
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String _baseUrl = ApiConstants.baseUrl;
  final Duration _timeout = const Duration(seconds: 30);

  /// Make a POST request with multipart/form-data
  Future<Map<String, dynamic>> postMultipart({
    required String endpoint,
    required Map<String, String> fields,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final stopwatch = Stopwatch()..start();
    _logRequest(method: 'POST', uri: uri, fields: fields, headers: headers);
    try {
      final request = http.MultipartRequest('POST', uri);

      request.fields.addAll(fields);
      if (headers != null) {
        request.headers.addAll(headers);
      }

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      _logResponse(
        uri: uri,
        statusCode: response.statusCode,
        body: response.body,
        elapsedMs: stopwatch.elapsedMilliseconds,
      );
      return _handleResponse(response);
    } on SocketException catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('Failed host lookup') || errorMsg.contains('No address associated')) {
        throw ApiException('DNS resolution failed - hostname cannot be resolved', 'DNS_ERROR');
      } else if (errorMsg.contains('Connection refused')) {
        throw ApiException('Connection refused by server', 'CONNECTION_REFUSED');
      } else {
        throw ApiException(e.osError?.message ?? 'Network error', 'NETWORK_ERROR');
      }
    } on TimeoutException catch (_) {
      throw ApiException('Request timeout - server took too long to respond', 'TIMEOUT_ERROR');
    } on http.ClientException catch (e) {
      throw ApiException('Connection failed: ${e.message}', 'CONNECTION_ERROR');
    } on Exception catch (e) {
      throw ApiException(e.toString(), 'UNKNOWN_ERROR');
    }
  }

  /// Make a GET request
  Future<Map<String, dynamic>> get({
    required String endpoint,
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) async {
    var uri = Uri.parse('$_baseUrl$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }
    final stopwatch = Stopwatch()..start();
    _logRequest(method: 'GET', uri: uri, fields: queryParams, headers: headers);
    try {
      final response = await http.get(
        uri,
        headers: headers,
      ).timeout(_timeout);

      _logResponse(
        uri: uri,
        statusCode: response.statusCode,
        body: response.body,
        elapsedMs: stopwatch.elapsedMilliseconds,
      );
      return _handleResponse(response);
    } on SocketException catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('Failed host lookup') || errorMsg.contains('No address associated')) {
        throw ApiException('DNS resolution failed - hostname cannot be resolved', 'DNS_ERROR');
      } else if (errorMsg.contains('Connection refused')) {
        throw ApiException('Connection refused by server', 'CONNECTION_REFUSED');
      } else {
        throw ApiException(e.osError?.message ?? 'Network error', 'NETWORK_ERROR');
      }
    } on TimeoutException catch (_) {
      throw ApiException('Request timeout - server took too long to respond', 'TIMEOUT_ERROR');
    } on http.ClientException catch (e) {
      throw ApiException('Connection failed: ${e.message}', 'CONNECTION_ERROR');
    } on Exception catch (e) {
      throw ApiException(e.toString(), 'UNKNOWN_ERROR');
    }
  }

  /// Handle HTTP response and extract backend error messages
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final decodedBody = utf8.decode(response.bodyBytes);
        final jsonResponse = json.decode(decodedBody) as Map<String, dynamic>;
        return jsonResponse;
      } catch (e) {
        throw ApiException('Failed to parse response body', 'PARSE_ERROR');
      }
    }

    String errorMessage = _extractErrorMessage(response);
    String errorCode = _getErrorCode(response.statusCode);

    throw ApiException(errorMessage, errorCode);
  }

  /// Extract error message from backend response
  String _extractErrorMessage(http.Response response) {
    try {
      final decodedBody = utf8.decode(response.bodyBytes);
      final jsonResponse = json.decode(decodedBody) as Map<String, dynamic>;

      if (jsonResponse.containsKey('message')) {
        return jsonResponse['message'] as String;
      } else if (jsonResponse.containsKey('error')) {
        return jsonResponse['error'] as String;
      } else if (jsonResponse.containsKey('errors')) {
        final errors = jsonResponse['errors'];
        if (errors is List && errors.isNotEmpty) {
          return errors.first.toString();
        }
      }
    } catch (_) {}

    return _getDefaultErrorMessage(response.statusCode);
  }

  /// Get error code based on HTTP status
  String _getErrorCode(int statusCode) {
    return switch (statusCode) {
      401 => 'UNAUTHORIZED',
      403 => 'FORBIDDEN',
      404 => 'NOT_FOUND',
      >= 500 => 'SERVER_ERROR',
      _ => 'HTTP_ERROR',
    };
  }

  /// Get default error message for status code
  String _getDefaultErrorMessage(int statusCode) {
    return switch (statusCode) {
      401 => 'Unauthorized - please log in again',
      403 => 'You do not have permission to access this resource',
      404 => 'The requested resource was not found',
      >= 500 => 'Server error - please try again later',
      _ => 'Request failed with status code: $statusCode',
    };
  }

  // ──────────────────────── logging ────────────────────────

  /// Field names whose values should be masked in logs (auth/PII).
  static const Set<String> _sensitiveFields = {
    'password',
    'bearer_token',
    'device_token',
  };

  /// Max characters of any single value to print before truncating.
  static const int _maxValueLen = 2000;

  void _logRequest({
    required String method,
    required Uri uri,
    Map<String, String>? fields,
    Map<String, String>? headers,
  }) {
    final buf = StringBuffer()
      ..writeln('────────── API → $method ${uri.path} ──────────')
      ..writeln('URL    : $uri');
    if (headers != null && headers.isNotEmpty) {
      buf.writeln('Headers: ${_redactedMap(headers)}');
    }
    if (fields != null && fields.isNotEmpty) {
      buf.writeln('Fields :');
      _redactedMap(fields).forEach((k, v) {
        buf.writeln('  $k = $v');
      });
    }
    developer.log(buf.toString(), name: 'API');
  }

  void _logResponse({
    required Uri uri,
    required int statusCode,
    required String body,
    required int elapsedMs,
  }) {
    final marker = (statusCode >= 200 && statusCode < 300) ? '✓' : '✗';
    final buf = StringBuffer()
      ..writeln('────────── API ← $marker $statusCode ${uri.path} (${elapsedMs}ms) ──────────')
      ..writeln(_prettyJsonOrRaw(body));
    developer.log(buf.toString(), name: 'API');
  }

  Map<String, String> _redactedMap(Map<String, String> input) {
    return input.map((k, v) {
      if (_sensitiveFields.contains(k.toLowerCase())) {
        return MapEntry(k, v.isEmpty ? '' : '***redacted (${v.length} chars)***');
      }
      final trimmed = v.length > _maxValueLen
          ? '${v.substring(0, _maxValueLen)}…(truncated ${v.length - _maxValueLen} chars)'
          : v;
      return MapEntry(k, trimmed);
    });
  }

  String _prettyJsonOrRaw(String body) {
    if (body.isEmpty) return '(empty body)';
    try {
      final decoded = json.decode(body);
      final pretty = const JsonEncoder.withIndent('  ').convert(decoded);
      if (pretty.length > _maxValueLen * 4) {
        return '${pretty.substring(0, _maxValueLen * 4)}\n…(truncated ${pretty.length - _maxValueLen * 4} chars)';
      }
      return pretty;
    } catch (_) {
      if (body.length > _maxValueLen) {
        return '${body.substring(0, _maxValueLen)}…(truncated ${body.length - _maxValueLen} chars)';
      }
      return body;
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