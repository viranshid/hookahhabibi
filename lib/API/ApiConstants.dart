/// API Constants for the application
class ApiConstants {
  // Base URL
  static const String baseUrl = 'https://myapp.hookahhabibi.co.id';

  // API Endpoints
  static const String login = '/api/login';
  static const String getUserData = '/api/get-user-data';
  static const String getLocations = '/api/get-locations';
  static const String getDishCats = '/api/get-dish-cats';
  static const String getDishes = '/api/get-dishes';
  static const String getOfferImgs = '/api/get-offer-imgs';

  // Request Headers
  static const String contentTypeMultipart = 'multipart/form-data';
  static const String contentTypeJson = 'application/json';

  // Form Field Names
  static const String fieldEmail = 'email';
  static const String fieldPassword = 'password';
  static const String fieldDeviceName = 'device_name';
  static const String fieldDeviceToken = 'device_token';
  static const String fieldBearerToken = 'bearer_token';
  static const String fieldLocationId = 'filters[location_id]';
  static const String fieldDishCatId = 'filters[dish_cat_id]';

  // Response Keys
  static const String keyType = 'type';
  static const String keyMsg = 'msg';
  static const String keyBearerToken = 'bearer_token';
  static const String keyData = 'data';
  static const String keyItems = 'items';
  static const String keyParentDishCats = 'parent_dish_cats';

  // Status Values
  static const String statusSuccess = 'success';
  static const String statusError = 'error';

  // Device Info
  // static String get defaultDeviceName => 'flutter-tablet';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}