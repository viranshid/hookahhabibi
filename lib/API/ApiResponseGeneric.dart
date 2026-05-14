/// Generic API Response Model
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final String? errorCode;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errorCode,
  });

  factory ApiResponse.success({T? data, String? message}) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
    );
  }

  factory ApiResponse.error({String? message, String? errorCode}) {
    return ApiResponse<T>(
      success: false,
      message: message,
      errorCode: errorCode,
    );
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, errorCode: $errorCode)';
  }
}

/// Paginated Response Model
class PaginatedResponse<T> {
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;
  final List<T> data;
  final String? nextPageUrl;
  final String? prevPageUrl;

  PaginatedResponse({
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
    required this.data,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory PaginatedResponse.fromJson(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>) fromJsonT,
      ) {
    final dataList = (json['data'] as List?)
        ?.map((item) => fromJsonT(item as Map<String, dynamic>))
        .toList() ?? [];

    return PaginatedResponse<T>(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      total: json['total'] ?? 0,
      perPage: json['per_page'] ?? 0,
      data: dataList,
      nextPageUrl: json['next_page_url'],
      prevPageUrl: json['prev_page_url'],
    );
  }

  bool get hasNextPage => nextPageUrl != null;
  bool get hasPrevPage => prevPageUrl != null;
}