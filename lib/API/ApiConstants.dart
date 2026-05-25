/// API Constants for the application
class ApiConstants {
  // Base URL
  static const String baseUrl = 'https://vp83.8therate.com/app.hookahhabibi.co.id'; //'https://myapp.hookahhabibi.co.id';

  // API Endpoints
  static const String login = '/api/login';
  static const String getUserData = '/api/get-user-data';
  static const String getLocations = '/api/get-locations';
  static const String getDishCats = '/api/get-dish-cats';
  static const String getDishes = '/api/get-dishes';
  static const String getOfferImgs = '/api/get-offer-imgs';
  static const String getTables = '/api/get-tables';
  static const String getCustomers = '/api/get-customers';
  static const String saveCustomer = '/api/save-customer';
  static const String saveOrderWithKot = '/api/save-order-with-kot';
  static const String addKotToOrder = '/api/add-kot-to-order';
  static const String updateQty = '/api/update-qty';
  static const String editItemNote = '/api/edit-item-note';
  static const String editOrderNote = '/api/edit-order-note';
  static const String cancelKotItem = '/api/cancel-kot-item';
  static const String cancelOrder = '/api/cancel-order';
  static const String getOrders = '/api/get-orders';
  static const String splitBill = '/api/orders/split-bill';

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
  static const String fieldSearch = 'search';
  static const String fieldPage = 'page';
  static const String fieldPerPage = 'per_page';
  static const String fieldName = 'name';
  static const String fieldPhone = 'phone';
  static const String fieldNotes = 'notes';
  static const String fieldLocationIdPlain = 'location_id';
  static const String fieldTableId = 'table_id';
  static const String fieldCustomerId = 'customer_id';
  static const String fieldCustomerName = 'customer_name';
  static const String fieldCustomerPhone = 'customer_phone';
  static const String fieldCustomerNotes = 'customer_notes';
  static const String fieldGuestCount = 'guest_count';
  static const String fieldOrderId = 'order_id';
  static const String fieldKotItemId = 'kot_item_id';
  static const String fieldNewQty = 'new_qty';
  static const String fieldNewNote = 'new_note';
  static const String fieldNote = 'note';
  static const String fieldKotId = 'kot_id';
  static const String fieldDishId = 'dish_id';
  static const String fieldReason = 'reason';
  static const String fieldSplitType = 'split_type';
  static const String fieldSplits = 'splits';

  // Split bill type values
  static const String splitTypeItemWise = 'i';
  static const String splitTypePercentage = 'p';

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