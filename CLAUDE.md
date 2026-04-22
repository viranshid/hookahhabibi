# hookahhabibi — Agent Reference

Flutter app: Shisha Lounge & Cafe digital menu for Hookah Habibi brand.
**Phase 1 complete. Phase 2 in progress.**

---

## Project Config
- **Orientation:** Landscape only (left + right, enforced in main.dart)
- **Text scaling:** Disabled (clamped 1.0–1.0)
- **API Base URL:** `https://myapp.hookahhabibi.co.id` (30s timeout)
- **State management:** Singleton + ChangeNotifier + `provider ^6.1.2` (MultiProvider in main.dart)
- **Flutter SDK:** ^3.8.1

---

## lib/ Structure

```
lib/
├── API/                  ApiConstants.dart, ApiService.dart, ApiResponseGeneric.dart
├── Enums/                HHButtonType, HHWelcomeMenuType, AppString
├── Managers/             HHAppManager, HHSessionManager, HHStorageManager,
│                         HHLocationManager, HHMenuManager, HHLockManager
├── Screen/               SplashScreen.dart + feature folders (Location, Login, Menu, User, Welcom)
├── Widgets/              HHButton.dart, HHTextField.dart
├── utils/                app_colors, app_dimens, app_fonts, app_routes, app_images,
│                         app_Strings, AppTextStyle, AppText, routes_generator,
│                         CustomPageRoute, FormateDate, ImageCacheManager,
│                         KeyboardUtils, hex_color, upper_case_text_formatter
├── l10n/                 app_localizations.dart, app_localizations_en.dart
└── main.dart
```

Each Screen folder contains: Screen file + `/Model/` + `/Service/`

---

## Design Tokens

### Colors — `lib/utils/app_colors.dart`
| Var | Hex | Role |
|---|---|---|
| `colorBB7A24` | #BB7A24 | Primary dark brown |
| `colorECC16E` | #ECC16E | Primary gold |
| `colorBD7D28` | #BD7D28 | Orange accent |
| `colorFFFFFF` | #FFFFFF | White |
| `colorBlack` | #000000 | Black |
| `color171717` | #171717 | Very dark gray |
| `color2B2B2B` | #2B2B2B | Dark gray |
| `color484848` | #484848 | Medium gray |
| `color949494` | #949494 | Light gray |
| `color30271C` | #30271C | Heading |
| `colorFF928A` | — | Error/red |
| `colorD9D9D9` | #D9D9D9 | Divider/light |
| `color6C757D` | #6C757D | Muted text |
| `colorEFEFEF` | #EFEFEF | Off-white |
| `color00541A` | #00541A | Green |

**Gradients:** `linearGradientPrimary`, `linearGradientFB9400FFAB38`, `linearGradient5A8D9D265260`

### Fonts — `lib/utils/app_fonts.dart`
`regular`(w400) · `mediumBold`(w500) · `semiBold`(w600) · `bold`(w700) · `highBold`(w800) · `highLevelBold`(w900)

**Font families:** Jost, Rubik, Oswald, Merriweather

### Dimensions — `lib/utils/app_dimens.dart`
All doubles. `margin0` → `margin1200` for spacing. `textSize8` → `textSize75` for font sizes.

### Text Styles — `lib/utils/AppTextStyle.dart`
Enum-based. Always use `AppText(text: '...', style: AppTextStyle.xyz)` instead of raw `Text`.

Key styles: `jostSemiBold18White`, `jostBold26Heading`, `rubikRegular14Muted`, `oswaldBold54White`, `oswaldSemiBold26Light`, `merriweatherItalic22White`

---

## Packages Added (Phase 2 prep)
- `provider: ^6.1.2` — All 5 managers provided via MultiProvider in main.dart. Use `context.watch<T>()` for reactive reads in build, `context.read<T>()` for mutations in event handlers.
- `cached_network_image: ^3.4.1` — Use for Phase 2 screens. Phase 1 uses custom `ImageCacheManager`.

---

## Reusable Components

### HHButton — `lib/Widgets/HHButton.dart`
```dart
HHButton(
  text: 'Login',
  type: HHButtonType.normal,      // normal | rounded | onlyText | iconWithText
  onPressed: () {},
  width: double?,
  backgroundColor: Color?,
  isEnabled: true,
)
```
Default: Jost w600 18pt white, height 56, borderRadius 60.

### HHTextField — `lib/Widgets/HHTextField.dart`
```dart
HHTextField(
  controller: _ctrl,
  hintText: 'Email',
  isSecureField: false,           // true for password (shows toggle)
  keyboardType: TextInputType.emailAddress,
  validator: (v) => ...,
)
```
Default: borderRadius 30, dark bg with opacity.

### HHLoadingView — `lib/Widgets/HHLoadingView.dart`
```dart
HHLoadingView(message: 'Loading...', indicatorColor: AppColors.colorECC16E)
```

### HHErrorView — `lib/Widgets/HHErrorView.dart`
```dart
HHErrorView(message: 'Something went wrong', retryLabel: 'Retry', onRetry: () {})
```

### AppText — `lib/utils/AppText.dart`
```dart
AppText(text: 'Hello', style: AppTextStyle.jostSemiBold18White, color: Colors.white)
```

### Asset Paths — `lib/utils/app_images.dart`
```dart
imageBaseURL     = 'assets/images/'
imageBaseURLSVG  = 'assets/svg/'
// Keys: icLoginBg, icLoginLogo, imgWelcomeBg, imgHookahMenuLogo,
//       icAvatar, icLock, icMapPin, icChilli, icVeg, icProfile, icLogout
```

---

## API Layer

### ApiService — `lib/API/ApiService.dart` (Singleton)
```dart
await ApiService.instance.postMultipart(ApiConstants.login, {fields})
await ApiService.instance.get(ApiConstants.getLocations, {params})
```

### Endpoints — `lib/API/ApiConstants.dart`
`/api/login` · `/api/get-user-data` · `/api/get-locations` · `/api/get-dish-cats` · `/api/get-dishes` · `/api/get-offer-imgs`

### Response wrapper — `lib/API/ApiResponseGeneric.dart`
```dart
ApiResponse<T> { bool success; T? data; String? message; String? errorCode; }
PaginatedResponse<T> { int currentPage, lastPage, total, perPage; }
```

---

## Managers (State)

All are `Singleton + ChangeNotifier`. Access via `.instance`.

| Manager | Key Responsibility |
|---|---|
| `HHAppManager` | Central coordinator — login/logout/init flow |
| `HHSessionManager` | bearerToken, currentUser, selectedLocation |
| `HHStorageManager` | SharedPreferences wrapper (keys: bearer_token, user_data, is_locked…) |
| `HHLocationManager` | Locations list, selection, dish availability, retry logic |
| `HHMenuManager` | Categories, dishes (location-filtered), offers |
| `HHLockManager` | PIN lock — maxAttempts=3, lockout=30s |

---

## Models

| Model | Location | Key Fields |
|---|---|---|
| `HHUserModel` | Screen/Login or User/Model | id, name, lastName, email, status, lockScreenPin. Computed: fullName, isActive, initials |
| `HHLocationModel` | Screen/Location/Model | id, title, address, image, unavailableDishIds, status |
| `HHLocationCardModel` | Screen/Location/Model | id, title, subtitle, imageUrl, isSelected |
| `HHDishCategoryModel` | Screen/Menu/Model | id, title, parentCatId, subCategories, dishes |
| `DishModel` (nested) | Screen/Menu/Model | id, title, dishPrice, dishType(v=veg), spicyType(y=spicy), isUnavailable, isRecommended |
| `HHOfferModel` | Screen/Menu/Model | id, title, image, linkUrl, status |

---

## Navigation

### Route constants — `lib/utils/app_routes.dart`
`routesSplash` · `routesLogin` · `routesWelcome` · `routesLocation` · `routesProductList` · `routesProductDetail` · `routesAllProduct` · `routesCart` · `routesViewCart` · `routesCheckOut` · `routesNotification`

### Phase 2 screen stubs
| Route | Screen | File |
|---|---|---|
| routesProductList | HHProductListScreen | Screen/Product/View/ |
| routesProductDetail | HHProductDetailScreen | Screen/Product/View/ |
| routesAllProduct | HHAllProductScreen | Screen/Product/View/ |
| routesCart | HHCartScreen | Screen/Cart/View/ |
| routesViewCart | HHViewCartScreen | Screen/Cart/View/ |
| routesCheckOut | HHCheckoutScreen | Screen/Cart/View/ |
| routesNotification | HHNotificationsScreen | Screen/Notifications/View/ |

### Transitions — `lib/utils/routes_generator.dart`
- `FadePageRouteBuilder` (300ms) → Splash, Login
- `CustomPageRouteBuilder` (400ms slide+fade) → Welcome
- `ScalePageRouteBuilder` (400ms scale+fade) → Location

```dart
RouteGenerator.navigateWithAnimation(context, AppRoutes.routesLocation, AnimationType.scale)
RouteGenerator.navigateAndReplaceWithAnimation(context, AppRoutes.routesLogin, AnimationType.fade)
```

---

## Feature Services
- `HHAuthService` — login(), getUserData(), validateToken()
- `HHLocationService` — getLocations() with exponential backoff retry (2s, 4s, 6s, max 3)
- `HHDishService` — getDishCategories(), getDishes(locationId, catId)
- `HHOfferService` — getOfferImages(), getActiveOffers()

---

## Utilities
- `HexColor('#BB7A24')` — hex string to Color
- `UpperCaseTextFormatter()` — force uppercase in TextField
- `KeyboardUtils` — hide keyboard helper
- `ImageCacheManager` — cached network image loading
- `FormateDate` — API date string formatting
