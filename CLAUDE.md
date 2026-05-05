# hookahhabibi — Agent Reference

Flutter app: Staff-facing POS (Point of Sale) system for Hookah Habibi restaurant.
**Phase 1 complete (Authentication & Menu Browsing). Phase 2 complete (POS System: Table Selection → Menu → Orders → KOT → Settlement).**

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

## Phase 2A: Table Selection Components

### Models — `lib/Screen/Table/Model/`
| Model | Key Fields |
|---|---|
| `HHTableModel` | id, name, capacity, area ("Ground Floor"/"Basement"/"Balcony"), status ValueNotifier ("available"/"occupied"/"reserved"), currentOrderId, occupiedSince |

### Service — `lib/Screen/Table/Service/HHTableService.dart`
- `getAvailableTables()` — List of tables with status='available'
- `getTablesByArea(area)` — Group tables by seating area
- `updateTableStatus(tableId, status)` — Live status updates via ValueNotifier
- `updateTableWithOrder(tableId, orderId)` — Mark table occupied with order
- `releaseTable(tableId)` — Clear order, mark available

### Components — `lib/Screen/Table/View/Components/`
| Component | Purpose |
|---|---|
| `HHTableStatusBadge.dart` | Status indicator: green (available), orange (occupied), yellow (reserved) |
| `HHTableCard.dart` | Individual table card: T-1, capacity, area, status badge. Green border when selected. Tap to select. 120x140. |
| `HHTableAreaSection.dart` | Collapsible section grouping tables (Ground Floor/Basement/Balcony). Brown header bar, toggle expand/collapse. |
| `HHTableGrid.dart` | Main scrollable container with CustomScrollView + BouncingScrollPhysics. Auto-groups by area via HHTableAreaSection. |
| `HHCustomerDetailsForm.dart` | Form: Customer Name (HHTextField), Phone (HHTextField), Guest Count (min=1, max=20 with +/- buttons). Continue button. ValueNotifier<int> for count. |
| `HHTableActionButton.dart` | Gold "Continue" button wrapper (HHButton). Full width, height 56. |

### Main Screen — `lib/Screen/Table/View/`
| Component | Purpose |
|---|---|
| `HHTableSelectionScreen.dart` | Landscape 2-split layout: tables (left, 60%) + customer form (right, 40%). Composes HHTableGrid + HHCustomerDetailsForm. Validates & passes to menu flow. |

---

## Phase 2B: Menu Browser & Cart Components

### Menu Components — `lib/Screen/Menu/View/Components/`
| Component | Purpose |
|---|---|
| `HHMenuItemCard.dart` | Single menu item card with image placeholder, name, price, dietary tags (Veg/Spicy) |
| `HHMenuItemGrid.dart` | 3-column GridView for items, SliverGrid lazy loading, BouncingScrollPhysics |
| `HHMenuCategoryFilter.dart` | Left sidebar category filter with ValueNotifier, toggle highlight in gold |
| `HHDietaryFilterChip.dart` | Horizontal filter chips: Vegetarian, Mild, Medium, Hot (4 toggles) |
| `HHMenuSearchBar.dart` | Top search input with 500ms debounce, clear button, search icon |

### Cart Components — `lib/Screen/Order/View/Components/`
| Component | Purpose |
|---|---|
| `HHCartItemRow.dart` | Cart item row: name, qty +/- buttons, unit price, remove (X) button |
| `HHCartActionButton.dart` | 4 action buttons: Save, KOT & Print, Split, Send to Kitchen |
| `HHOrderTotal.dart` | Subtotal & item count display with ValueListenableBuilder reactivity |
| `HHCartSummary.dart` | 380w right sidebar: header, scrollable items, divider, total, actions |
| `HHSpecialRequestsInput.dart` | Multiline input for item notes (modal or inline), Save/Cancel |

### Main Screen — `lib/Screen/Menu/View/`
| Component | Purpose |
|---|---|
| `HHMenuBrowserScreen.dart` | 60/40 landscape layout: menu (left) + cart (right), search + filters + grid |

---

## Phase 2C: KOT Dashboard & Orders Management

### KOT Components — `lib/Screen/KOT/View/Components/`
| Component | Purpose | Lines |
|---|---|---|
| `HHKOTItemRow.dart` | Single kitchen item: name (left) \| qty badge (center) \| status color-badge (right) \| Tap to cycle status pending→in_prep→ready→served |120|
| `HHKOTOrderCard.dart` | Order card with header (ID, customer, tables, guests), scrollable item list, status timeline footer. Width: 100%, adaptive height |200|
| `HHOrderStatusTimeline.dart` | Horizontal timeline: Draft→Sent→In Prep→Ready→Completed with circle progress + timestamps. Colors: green (done), gold (current), gray (pending) |150|

### Orders Dashboard Components — `lib/Screen/Orders/View/Components/`
| Component | Purpose | Lines |
|---|---|---|
| `HHStatusFilterTabs.dart` | Horizontal scrollable tabs: Pending \| Accepted \| In Prep \| Ready \| Completed \| Cancelled. Selected = gold bg + bold, unselected = dark + gray |100|
| `HHAllOrderCard.dart` | Compact order card (~280x180): header (ID, customer, tables) \| info (qty, guests, time) \| preview (first 2 items + "+N more") \| footer (status badge + "Settle" button) |160|
| `HHOrdersGrid.dart` | GridView.builder with SliverGrid: 2-3 columns (responsive), aspect 1.5, empty state message, BouncingScrollPhysics. Filters by selectedStatus |100|

### KOT & Orders Screens — `lib/Screen/{KOT,Orders}/View/`
| Screen | Purpose | Lines |
|---|---|---|
| `HHKOTDashboardScreen.dart` | Real-time KOT display: AppBar + auto-scrolling list of HHKOTOrderCards filtered for active orders. Listens to orderService.allOrders, refresh button (manual) |180|
| `HHAllOrdersScreen.dart` | Dashboard: AppBar + HHStatusFilterTabs + HHOrdersGrid. Filtered by selectedStatus ValueNotifier. Settle action with confirmation dialog |200|

**Status colors (all components):**
- pending: Yellow (#FFC107)
- accepted/in_preparation: Orange (#BD7D28)
- ready: Green (#00541A)
- completed/served: Gray (#2B2B2B or #949494)
- cancelled: Red (#FF928A)

**Models integrated:**
- `HHOrderModel` — ValueNotifier<status>, tableIds[], customerId, guestCount, items (ValueNotifier<List>), timestamps
- `HHOrderItemModel` — menuItemName, quantity (ValueNotifier), status (ValueNotifier), unitPrice

**Service methods used:**
- `orderService.allOrders` — ValueNotifier<List<HHOrderModel>> for reactivity
- `orderService.getActiveOrders()` — Filter for KOT (status != completed/cancelled)
- `orderService.updateOrderItemStatus(orderId, itemId, newStatus)` — Item status changes
- `orderService.settleOrder(orderId)` — Mark complete
- `orderService.updateOrderStatus(orderId, newStatus)` — Order status changes
- `orderService.loadAllOrders()` — Manual refresh

---

## Phase 2D: Settlement & Split Payment Components

### Models — `lib/Screen/Payment/Model/`
| Model | Key Fields |
|---|---|
| `HHPaymentSplitModel` | id, orderId, splitType ("percentage"/"item_wise"), parts List<HHSplitPartModel> |
| `HHSplitPartModel` | customerName, percentage (0-100), amount (calculated), itemIds (for item-wise) |

### Service — `lib/Screen/Payment/Service/HHPaymentService.dart`
- `createPercentageSplit(orderId, totalAmount, customerNames[], percentages[])` — Validate sum=100%, calculate amounts
- `createItemWiseSplit(orderId, totalAmount, customerItemsMap)` — Map items to customers
- `calculateItemWiseSplitAmounts(items[], customerItemsMap)` — Compute totals per customer
- `validateSplitTotal(splits[], totalAmount)` — Verify split ≈ order total
- `processPayment(orderId, split, paymentMethod)` — Simulate payment (future: API call)

### Components — `lib/Screen/Payment/View/Components/`
| Component | Purpose |
|---|---|
| `HHSettlementButton.dart` | Gold "Confirm & Settle" button (HHButton wrapper). Enabled/disabled state. |
| `HHSettlementDialog.dart` | Modal dialog: checkmark icon, title, message, total amount (gold), Cancel/Confirm buttons, "Split Payment" link. |
| `HHPercentageSplitInput.dart` | Input row: customer name (HHTextField) \| percentage (HHTextField, 0-100) \| calculated amount (read-only, gold). Live calculation as percentage changes. |
| `HHPercentageSplitCalculator.dart` | Validation component: summary table (customer \| % \| amount), totals row, error msg if != 100%. Color feedback (red if invalid, green if valid). |
| `HHItemWiseSplitList.dart` | Item selection list with checkboxes, customer dropdown, assignment. Expandable sections per customer showing assigned items + totals. |

### Composed Screens — `lib/Screen/Payment/View/`
| Screen | Purpose | Feature |
|---|---|---|
| `HHSplitPaymentScreen.dart` | Tabbed form: "Percentage Wise" tab (HHPercentageSplitInput rows + HHPercentageSplitCalculator) \| "Item Wise" tab (HHItemWiseSplitList). Add split rows (percentage) or assign items. Validate before save. Call paymentService.createPercentageSplit/createItemWiseSplit. |
| `HHOrderSettlementFlow.dart` | Orchestration screen managing full settlement: Dialog (single settle or split choice) → HHSplitPaymentScreen (if split) → Success/error dialogs. Stateful tracking of steps: confirmation → split creation → final completion. |

**Split Validation Rules:**
- **Percentage-wise:** Sum of percentages must = 100% (±0.01 tolerance)
- **Item-wise:** All items must be assigned to a customer
- **Amount check:** Sum of split amounts ≈ order total (±RP 1 tolerance)

---

## Phase 2 Models — All Models (New)

| Model | Location | Key Fields |
|---|---|---|
| `HHTableModel` | Screen/Table/Model | id, name, capacity, area, status ValueNotifier, currentOrderId |
| `HHMenuItemModel` | Screen/Menu/Model | id, name, category, price, imageKey, isVegetarian, spiceLevel, isAvailable ValueNotifier |
| `HHOrderModel` | Screen/Order/Model | id, tableIds[], customerId, guestCount, items ValueNotifier, totalAmount ValueNotifier, status ValueNotifier, timestamps |
| `HHOrderItemModel` | Screen/Order/Model | id, menuItemId, menuItemName, unitPrice, quantity ValueNotifier, specialRequests, status ValueNotifier |
| `HHPaymentSplitModel` | Screen/Payment/Model | id, orderId, splitType, parts List<HHSplitPartModel> |
| `HHSplitPartModel` | Screen/Payment/Model | customerName, percentage, amount, itemIds |

## Phase 2 Services — All Services (New)

| Service | File | Key Methods |
|---|---|---|
| `HHTableService` | Screen/Table/Service | getAvailableTables(), getTablesByArea(), updateTableStatus(), updateTableWithOrder(), releaseTable() |
| `HHMenuService` (POS) | Screen/Menu/Service | getItemsByCategory(), filterByDietary(), searchItems(), setSelectedCategory(), updateItemAvailability() |
| `HHOrderService` | Screen/Order/Service | createOrder(), addItemToCurrentOrder(), removeItemFromCurrentOrder(), updateItemQuantity(), sendOrderToKitchen(), updateOrderStatus(), getOrdersByStatus(), settleOrder() |
| `HHOrdersService` | Screen/Orders/Service | getOrdersByStatus(status), getFilteredOrders(statuses), searchOrders(query), setSelectedStatus(), getActiveOrders(), refreshOrders() |
| `HHKOTService` | Screen/KOT/Service | getActiveOrders(), getOrdersByStatus(status), getPendingOrders(), getInPreparationOrders(), getReadyOrders(), cycleItemStatus(), getKOTMetrics() |
| `HHPaymentService` | Screen/Payment/Service | createPercentageSplit(), createItemWiseSplit(), calculateItemWiseSplitAmounts(), validateSplitTotal(), processPayment() |

## Phase 2 Integration with HHAppManager

`HHAppManager` extended with Phase 2 services (initialized in `initialize()` method):
- `tableService` — HHTableService instance
- `posMenuService` — HHMenuService instance (Phase 2 menu, separate from Phase 1 HHMenuManager)
- `orderService` — HHOrderService instance (core order management)
- `ordersService` — HHOrdersService instance (dashboard queries & filtering for All Orders screen)
- `kotService` — HHKOTService instance (KOT dashboard queries & item status management)
- `paymentService` — HHPaymentService instance

All services use **ValueNotifier** for reactive state updates. UI components use **ValueListenableBuilder** for efficient rebuilds.

---

## Utilities
- `HexColor('#BB7A24')` — hex string to Color
- `UpperCaseTextFormatter()` — force uppercase in TextField
- `KeyboardUtils` — hide keyboard helper
- `ImageCacheManager` — cached network image loading
- `FormateDate` — API date string formatting
