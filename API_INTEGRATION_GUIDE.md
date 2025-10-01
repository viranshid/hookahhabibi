# API Integration Guide - Hookah Habibi

## Overview
This guide covers the complete API integration architecture for the Hookah Habibi Flutter tablet application.

## Architecture

### Layer Structure
```
┌─────────────────────────────────────┐
│          UI Layer (Screens)         │
│  - HHLoginWithAPI                   │
│  - HHLocationScreenWithAPI          │
│  - HHMenuContentAreaWithAPI         │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│       Manager Layer (State)         │
│  - AppManager (Coordinator)         │
│  - SessionManager                   │
│  - LocationManager                  │
│  - MenuManager                      │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│       Service Layer (API)           │
│  - AuthService                      │
│  - LocationService                  │
│  - DishService                      │
│  - OfferService                     │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│      Base Service (HTTP)            │
│  - ApiService                       │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│         API Endpoints               │
│  - myapp.hookahhabibi.co.id         │
└─────────────────────────────────────┘
```

## File Structure

### Models (`lib/models/`)
- `ApiResponse.dart` - Generic API response wrapper
- `UserModel.dart` - User and login response models
- `LocationModel.dart` - Restaurant location model
- `DishCategoryModel.dart` - Menu category and dish models
- `OfferModel.dart` - Special offer images model

### Services (`lib/services/`)
- `ApiService.dart` - Base HTTP service
- `AuthService.dart` - Authentication endpoints
- `LocationService.dart` - Location endpoints
- `DishService.dart` - Menu and dishes endpoints
- `OfferService.dart` - Offer images endpoints

### Managers (`lib/managers/`)
- `AppManager.dart` - Main app coordinator
- `SessionManager.dart` - User session management
- `LocationManager.dart` - Location state management
- `MenuManager.dart` - Menu state management

### Constants (`lib/constants/`)
- `ApiConstants.dart` - API endpoints and configuration

## Usage Examples

### 1. Login Flow

```dart
import 'package:hookahhabibi/managers/AppManager.dart';

final appManager = AppManager();

// Login
final response = await appManager.login(
  email: 'mt11@example.com',
  password: 'Test@123',
);

if (response.success) {
  // Login successful
  print('Bearer Token: ${appManager.sessionManager.bearerToken}');
  print('User: ${appManager.sessionManager.currentUser?.fullName}');
  
  // Navigate to next screen
  Navigator.pushReplacement(context, ...);
} else {
  // Handle error
  print('Error: ${response.message}');
}
```

### 2. Load Locations

```dart
final appManager = AppManager();

// Load locations (automatically called after login)
await appManager.locationManager.loadLocations();

// Access locations
final locations = appManager.locationManager.locations;

// Select a location
await appManager.selectLocation(locationId);

// Check selected location
final selectedLoc = appManager.sessionManager.selectedLocation;
print('Selected: ${selectedLoc?.title}');
```

### 3. Load Menu

```dart
final appManager = AppManager();

// Load categories
await appManager.menuManager.loadCategories();

// Load dishes for a category
await appManager.menuManager.loadDishes(categoryId: '1');

// Get dishes
final dishes = appManager.menuManager.getDisplayDishes();

// Load offers
await appManager.menuManager.loadOffers();
final offers = appManager.menuManager.offers;
```

### 4. Check Dish Availability

```dart
final appManager = AppManager();

// Check if dish is available at selected location
final isAvailable = appManager.locationManager.isDishAvailable('51');

if (isAvailable) {
  print('Dish is available');
} else {
  print('Dish is not available at this location');
}
```

## API Endpoints

### Authentication

#### Login
```
POST /api/login
Content-Type: multipart/form-data

Fields:
- email: string
- password: string
- device_name: string (optional)
- device_token: string (optional)

Response:
{
  "type": "success",
  "msg": "Login Success",
  "bearer_token": "token_here"
}
```

#### Get User Data
```
POST /api/get-user-data
Content-Type: multipart/form-data

Fields:
- bearer_token: string

Response: UserModel JSON
```

### Locations

#### Get All Locations
```
POST /api/get-locations
Content-Type: multipart/form-data

Fields:
- bearer_token: string

Response:
{
  "page_title": "All Locations",
  "total_items_count": 2,
  "items": {
    "data": [LocationModel, ...]
  }
}
```

### Menu

#### Get Dish Categories
```
POST /api/get-dish-cats
Content-Type: multipart/form-data

Fields:
- bearer_token: string

Response:
{
  "page_title": "All Dish Categories",
  "total_items_count": 9,
  "items": {
    "data": [DishCategoryModel, ...]
  }
}
```

#### Get Dishes
```
POST /api/get-dishes
Content-Type: multipart/form-data

Fields:
- bearer_token: string
- filters[location_id]: string
- filters[dish_cat_id]: string

Response:
{
  "page_title": "All Dishes",
  "parent_dish_cats": {
    "1": {
      "id": "1",
      "title": "MAIN COURSE",
      "dish_cats": {
        "2": {
          "dishes": {...}
        }
      }
    }
  }
}
```

### Offers

#### Get Offer Images
```
POST /api/get-offer-imgs
Content-Type: multipart/form-data

Fields:
- bearer_token: string

Response:
{
  "page_title": "All Offer Images",
  "total_items_count": 4,
  "items": {
    "data": [OfferModel, ...]
  }
}
```

## Error Handling

All API responses are wrapped in `ApiResponse<T>`:

```dart
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final String? errorCode;
}
```

Common error codes:
- `NETWORK_ERROR` - No internet connection
- `CONNECTION_ERROR` - Connection failed
- `UNAUTHORIZED` - Invalid bearer token
- `SERVER_ERROR` - Server error (5xx)
- `PARSE_ERROR` - Failed to parse response
- `NOT_FOUND` - Resource not found

Example error handling:

```dart
final response = await authService.login(...);

if (!response.success) {
  switch (response.errorCode) {
    case 'NETWORK_ERROR':
      showError('No internet connection');
      break;
    case 'UNAUTHORIZED':
      showError('Invalid credentials');
      break;
    default:
      showError(response.message ?? 'Unknown error');
  }
}
```

## State Management

The app uses ChangeNotifier for state management:

```dart
// Listen to changes
appManager.addListener(() {
  // State changed
});

// Access state
final isLoggedIn = appManager.isLoggedIn;
final user = appManager.sessionManager.currentUser;
final location = appManager.sessionManager.selectedLocation;
```

## Integration Steps

### Step 1: Add Dependencies to pubspec.yaml
```yaml
dependencies:
  http: ^1.1.0
  provider: ^6.0.0  # Optional for state management
```

### Step 2: Create Folder Structure
```
lib/
├── models/
├── services/
├── managers/
└── constants/
```

### Step 3: Update Existing Screens

Replace your existing screens with API-integrated versions:
- `HHLogin.dart` → `HHLoginWithAPI.dart`
- `HHLocationScreen.dart` → `HHLocationScreenWithAPI.dart`
- `HHMenuContentArea.dart` → `HHMenuContentAreaWithAPI.dart`

### Step 4: Initialize AppManager

In your `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize app manager
  final appManager = AppManager();
  await appManager.initialize();
  
  runApp(MyApp());
}
```

### Step 5: Update Routes

Update your route generator to use new screens.

## Testing

Test credentials:
- Email: `mt11@example.com`
- Password: `Test@123`

## Best Practices

1. **Always check login status** before making API calls
2. **Handle errors gracefully** with user-friendly messages
3. **Show loading indicators** during API calls
4. **Cache data** when appropriate to reduce API calls
5. **Validate bearer token** on app startup
6. **Clear session** on logout

## Troubleshooting

### Issue: "User not logged in" error
**Solution**: Ensure login is successful before accessing other endpoints

### Issue: "Failed to parse response"
**Solution**: Check API response format matches model structure

### Issue: "Network error"
**Solution**: Verify internet connection and API endpoint URL

### Issue: Dishes not showing
**Solution**:
1. Verify location is selected
2. Check if category has dishes
3. Verify bearer token is valid

## Next Steps

1. Implement cart functionality
2. Add order management
3. Implement user profile updates
4. Add offline mode with local caching
5. Implement push notifications

## Support

For issues or questions, contact the development team.