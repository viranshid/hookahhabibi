# Phase 2 Implementation Plan — Hookah Habibi POS System

**Status:** Ready for Approval  
**Date:** 2026-04-30  
**Approach:** Small reusable components + Extended managers + Live ValueNotifier reactivity  
**Priorities:** Performance, smooth scrolling, small atoms, static assets

---

## Context & Philosophy

Phase 2 transforms the app into a **staff-facing POS system** with three core requirements:

1. **Small reusable components** — Build atomic UI atoms, not full screens
2. **Reuse Phase 1 infrastructure** — Extend existing managers, don't create new ones
3. **Live reactive data** — ValueNotifier-based services stream updates to UI
4. **Performance first** — Smooth scrolling, lazy loading, efficient rebuilds
5. **Static assets managed** — Images, buttons, cards loaded from helpers; you inject later

---

## Phase 2 Screens & Components Breakdown

From Figma snapshots, break each screen into **atomic, reusable components**:

### Screen 1: Table Selection
**Components to build:**
- `HHTableGrid` — Grid layout of table cards
- `HHTableCard` — Individual table (capacity, status, badge)
- `HHTableStatusBadge` — Status indicator ("available", "occupied", "reserved")
- `HHTableAreaSection` — Collapsible section (Ground Floor, Basement, Balcony)
- `HHCustomerDetailsForm` — Name, phone, guest count input
- `HHTableActionButton` — "Continue" button

### Screen 2: Menu Browser
**Components to build:**
- `HHMenuCategoryFilter` — Sidebar: Soup | Salad | Appetizers | Main | Breads
- `HHMenuItemCard` — Item card with image, name, price, veg/spicy badge
- `HHMenuItemGrid` — Responsive grid of items (lazy-loaded)
- `HHDietaryFilterChip` — Veg/Spicy/Medium toggle buttons
- `HHMenuSearchBar` — Optional search in category

### Screen 3: Order/Cart
**Components to build:**
- `HHCartSummary` — Right sidebar showing items + total
- `HHCartItemRow` — Item row with qty +/- buttons, price
- `HHCartActionButton` — "Save" | "KOT & Print" | "Split" | "Send to Kitchen"
- `HHOrderTotal` — Grand total display
- `HHSpecialRequestsInput` — Customization notes

### Screen 4: KOT Dashboard
**Components to build:**
- `HHKOTOrderCard` — Order card with items + timing
- `HHKOTItemRow` — Item + status + estimated time
- `HHOrderStatusTimeline` — Visual status progression (Pending → In Prep → Ready)

### Screen 5: All Orders Dashboard
**Components to build:**
- `HHOrdersGrid` — Grid of active orders (with status filter tabs)
- `HHAllOrderCard` — Compact order card (customer, table, items, action buttons)
- `HHStatusFilterTabs` — Pending | Accepted | In Prep | Ready | Completed | Cancelled

### Screen 6: Order Settlement
**Components to build:**
- `HHSettlementDialog` — Confirmation modal with total + buttons
- `HHSettlementButton` — "Confirm & Settle" button

### Screen 7: Split Payment
**Components to build:**
- `HHSplitPaymentForm` — Two tabs: Percentage | Item-wise
- `HHPercentageSplitInput` — Input rows: customer name | percentage | calculated amount
- `HHItemWiseSplitList` — List of items + assign to customers

---

## Data Models

**Location:** `lib/Screen/{Feature}/Model/`

### Core Models

```dart
// Table/Model/HHTableModel.dart
class HHTableModel {
  final String id;              // "T-1"
  final String name;
  final int capacity;
  final String area;            // "Ground Floor"
  final ValueNotifier<String> status; // "available" | "occupied" | "reserved"
  final String? currentOrderId;
  DateTime? occupiedSince;
}

// Order/Model/HHOrderModel.dart
class HHOrderModel {
  final String id;
  final List<String> tableIds;
  final String customerId;
  final int guestCount;
  final ValueNotifier<List<HHOrderItemModel>> items; // LIVE updates
  final ValueNotifier<double> totalAmount;
  final ValueNotifier<String> status;               // LIVE status
  DateTime createdAt;
  List<HHPaymentSplitModel>? paymentSplits;
  
  // Computed
  double get subtotal => items.value.fold(0, (sum, item) => sum + item.totalPrice);
}

// Order/Model/HHOrderItemModel.dart
class HHOrderItemModel {
  final String id;
  final String menuItemId;
  final String menuItemName;
  final double unitPrice;
  final ValueNotifier<int> quantity; // LIVE quantity changes
  final String? specialRequests;
  
  double get totalPrice => unitPrice * quantity.value;
}

// Menu/Model/HHMenuItemModel.dart
class HHMenuItemModel {
  final String id;
  final String name;
  final String category;
  final double price;
  final String imageKey;         // Reference to app_images.dart (e.g., "imgMargaLambSoup")
  final bool isVegetarian;
  final int spiceLevel;          // 0, 1, 2, 3
  final ValueNotifier<bool> isAvailable; // LIVE availability from backend
}

// Payment/Model/HHPaymentSplitModel.dart
class HHPaymentSplitModel {
  final String id;
  final String orderId;
  final String splitType;        // "percentage" | "item_wise"
  final List<HHSplitPartModel> parts;
}

class HHSplitPartModel {
  String customerName;
  double percentage;             // For percentage-based
  double amount;                 // Calculated: totalAmount * (percentage / 100)
  List<String>? itemIds;         // For item-wise splits
}
```

---

## Services (With Mock Data & ValueNotifier Reactivity)

**Location:** `lib/Screen/{Feature}/Service/`

**Key:** All services return ValueNotifier or Stream for LIVE updates. No static data fetches.

### 1. HHTableService — `Screen/Table/Service/HHTableService.dart`

```dart
class HHTableService {
  final TableRepository _repo = TableRepository(); // Mock or real API
  late final ValueNotifier<List<HHTableModel>> _tables;
  
  ValueNotifier<List<HHTableModel>> get tables => _tables;
  
  HHTableService() {
    _initializeTables();
  }
  
  void _initializeTables() {
    _tables = ValueNotifier(_repo.getAllTables()); // Mock data initially
    // If using live API: _listenToTableUpdates();
  }
  
  Future<HHOrderModel> selectTablesAndCreateOrder(
    List<String> tableIds, 
    String customerName, 
    int guestCount,
  ) async {
    // Creates order, updates table status
    // Returns new HHOrderModel with ValueNotifier fields
  }
  
  void updateTableStatus(String tableId, String newStatus) {
    // Updates _tables ValueNotifier → UI rebuilds
  }
  
  List<HHTableModel> getAvailableTables() => _tables.value.where((t) => t.status.value == 'available').toList();
}
```

### 2. HHMenuService — `Screen/Menu/Service/HHMenuService.dart`

```dart
class HHMenuService {
  final MenuRepository _repo = MenuRepository();
  late final ValueNotifier<List<HHMenuItemModel>> _allItems;
  late final ValueNotifier<List<String>> _categories;
  late final ValueNotifier<String> _selectedCategory;
  
  HHMenuService() {
    _allItems = ValueNotifier(_repo.getAllMenuItems());
    _categories = ValueNotifier(_repo.getCategories());
    _selectedCategory = ValueNotifier('Soup');
  }
  
  ValueNotifier<List<HHMenuItemModel>> get items => _allItems;
  ValueNotifier<List<String>> get categories => _categories;
  ValueNotifier<String> get selectedCategory => _selectedCategory;
  
  List<HHMenuItemModel> getItemsByCategory(String category) =>
    _allItems.value.where((i) => i.category == category).toList();
  
  List<HHMenuItemModel> filterByDietary({bool veg = false, int? maxSpice}) {
    return _allItems.value.where((i) {
      if (veg && !i.isVegetarian) return false;
      if (maxSpice != null && i.spiceLevel > maxSpice) return false;
      return true;
    }).toList();
  }
  
  void setSelectedCategory(String category) => _selectedCategory.value = category;
}
```

### 3. HHOrderService — `Screen/Order/Service/HHOrderService.dart`

```dart
class HHOrderService {
  final OrderRepository _repo = OrderRepository();
  late final ValueNotifier<HHOrderModel?> _currentOrder;
  late final ValueNotifier<List<HHOrderModel>> _allOrders;
  
  HHOrderService() {
    _currentOrder = ValueNotifier(null);
    _allOrders = ValueNotifier(_repo.getActiveOrders());
  }
  
  ValueNotifier<HHOrderModel?> get currentOrder => _currentOrder;
  ValueNotifier<List<HHOrderModel>> get allOrders => _allOrders;
  
  Future<void> createOrder(List<String> tableIds, String customerId, int guestCount) async {
    final order = HHOrderModel(
      id: generateUUID(),
      tableIds: tableIds,
      customerId: customerId,
      guestCount: guestCount,
      items: ValueNotifier([]),
      totalAmount: ValueNotifier(0),
      status: ValueNotifier('draft'),
      createdAt: DateTime.now(),
    );
    _currentOrder.value = order;
  }
  
  void addItemToCurrentOrder(String menuItemId, int quantity, String? specialRequests) {
    if (_currentOrder.value == null) return;
    
    final newItem = HHOrderItemModel(...);
    final updatedItems = [..._currentOrder.value!.items.value, newItem];
    _currentOrder.value!.items.value = updatedItems; // Trigger ValueNotifier
    _updateOrderTotal();
  }
  
  void removeItemFromCurrentOrder(String itemId) {
    if (_currentOrder.value == null) return;
    
    final updatedItems = _currentOrder.value!.items.value
      .where((i) => i.id != itemId)
      .toList();
    _currentOrder.value!.items.value = updatedItems;
    _updateOrderTotal();
  }
  
  void updateItemQuantity(String itemId, int newQuantity) {
    if (_currentOrder.value == null) return;
    
    final items = _currentOrder.value!.items.value;
    final index = items.indexWhere((i) => i.id == itemId);
    if (index >= 0) {
      items[index].quantity.value = newQuantity;
      _currentOrder.value!.items.value = items; // Force rebuild
      _updateOrderTotal();
    }
  }
  
  void _updateOrderTotal() {
    if (_currentOrder.value == null) return;
    _currentOrder.value!.totalAmount.value = _currentOrder.value!.subtotal;
  }
  
  Future<void> sendOrderToKitchen() async {
    if (_currentOrder.value == null) return;
    _currentOrder.value!.status.value = 'sent';
    _currentOrder.value!.sentToKitchenAt = DateTime.now();
    // Persist & update all orders list
    _allOrders.value = [..._allOrders.value, _currentOrder.value!];
  }
  
  Future<void> saveOrder() async {
    if (_currentOrder.value == null) return;
    // Persist locally (SharedPreferences or DB)
  }
  
  void loadAllOrders() {
    _allOrders.value = _repo.getActiveOrders();
  }
  
  List<HHOrderModel> getOrdersByStatus(String status) =>
    _allOrders.value.where((o) => o.status.value == status).toList();
}
```

### 4. HHPaymentService — `Screen/Payment/Service/HHPaymentService.dart`

```dart
class HHPaymentService {
  Future<void> createPercentageSplit(
    String orderId,
    List<HHSplitPartModel> splits,
  ) async {
    // Validate: sum of percentages == 100
    // Calculate amounts for each split
    // Return payment model
  }
  
  Future<void> settleOrder(String orderId) async {
    // Mark order as settled
    // Update order status to 'completed'
  }
}
```

---

## Managers (Extend Existing)

**Instead of creating new managers, extend existing ones:**

### Extend: HHAppManager

```dart
class HHAppManager extends ChangeNotifier {
  // Existing
  late HHSessionManager sessionManager;
  late HHStorageManager storageManager;
  late HHLocationManager locationManager;
  late HHMenuManager menuManager;
  
  // Phase 2: Add service holders
  late HHTableService tableService;
  late HHOrderService orderService;
  late HHPaymentService paymentService;
  
  @override
  void initialize() async {
    // Existing init
    await sessionManager.initialize();
    await storageManager.initialize();
    
    // Phase 2: Initialize services
    tableService = HHTableService();
    orderService = HHOrderService();
    paymentService = HHPaymentService();
    
    notifyListeners();
  }
}
```

### Extend: HHStorageManager

```dart
class HHStorageManager extends ChangeNotifier {
  // Existing
  Future<void> saveToken(String token) async { ... }
  
  // Phase 2: Add order/cart persistence
  Future<void> saveDraftOrder(HHOrderModel order) async {
    final json = jsonEncode(order.toJson());
    await _prefs.setString('draft_order', json);
  }
  
  Future<HHOrderModel?> getDraftOrder() async {
    final json = _prefs.getString('draft_order');
    if (json == null) return null;
    return HHOrderModel.fromJson(jsonDecode(json));
  }
}
```

**No new managers needed** — services handle Phase 2 state via ValueNotifier.

---

## Asset Management

**Location:** `lib/utils/app_images.dart`

```dart
// Existing
const String imageBaseURL = 'assets/images/';
const String imageBaseURLSVG = 'assets/svg/';

// Phase 2 additions
const String imgMargaLambSoup = '${imageBaseURL}marga_lamb_soup.png';
const String imgHummusDip = '${imageBaseURL}hummus_dip.png';
const String imgTandooriChicken = '${imageBaseURL}tandoori_chicken.png';
const String imgNasiGorerng = '${imageBaseURL}nasi_goreng.png';
const String imgPaneerButter = '${imageBaseURL}paneer_butter.png';
const String imgLentilSoup = '${imageBaseURL}lentil_soup.png';
// ... more items

// Static UI elements (you inject after)
const String icTableAvailable = '${imageBaseURLSVG}table_available.svg';
const String icTableOccupied = '${imageBaseURLSVG}table_occupied.svg';
const String icVegBadge = '${imageBaseURLSVG}veg_badge.svg';
const String icSpicy = '${imageBaseURLSVG}spicy_icon.svg';
```

**Your workflow:**
1. I implement components referencing `imgMargaLambSoup`, etc.
2. You add actual image files to `assets/images/` with those names
3. No code changes needed — just image files populate the app

---

## Implementation Order (Component-Driven)

### Phase 2A: Foundation (Week 1)
1. ✅ Create all data models with ValueNotifier fields
2. ✅ Create HHTableService with mock data
3. ✅ Create HHMenuService with mock data
4. ✅ Extend HHAppManager to initialize services
5. ✅ Create atomic UI components for table selection:
   - `HHTableCard`
   - `HHTableStatusBadge`
   - `HHTableAreaSection`
   - `HHTableGrid`
   - `HHCustomerDetailsForm`

### Phase 2B: Menu & Cart (Week 2)
6. ✅ Create HHOrderService with ValueNotifier state
7. ✅ Create menu components:
   - `HHMenuItemCard`
   - `HHMenuItemGrid` (with lazy loading)
   - `HHMenuCategoryFilter`
   - `HHDietaryFilterChip`
8. ✅ Create cart components:
   - `HHCartSummary`
   - `HHCartItemRow`
   - `HHCartActionButton`
   - `HHOrderTotal`
   - `HHSpecialRequestsInput`

### Phase 2C: Order Management (Week 3)
9. ✅ Create KOT components:
   - `HHKOTOrderCard`
   - `HHKOTItemRow`
   - `HHOrderStatusTimeline`
10. ✅ Create All Orders Dashboard:
   - `HHOrdersGrid`
   - `HHAllOrderCard`
   - `HHStatusFilterTabs`

### Phase 2D: Payment (Week 4)
11. ✅ Create HHPaymentService
12. ✅ Create settlement components:
   - `HHSettlementDialog`
   - `HHSettlementButton`
13. ✅ Create split payment components:
   - `HHSplitPaymentForm`
   - `HHPercentageSplitInput`
   - `HHItemWiseSplitList`

---

## Performance Optimizations (Required)

### 1. Smooth Scrolling
```dart
// HHMenuItemGrid
ListView.builder(
  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
  shrinkWrap: true,
  itemCount: items.length,
  itemBuilder: (context, index) => ...,
)

// Or CustomScrollView for complex layouts
CustomScrollView(
  physics: const BouncingScrollPhysics(),
  slivers: [
    SliverAppBar(...),
    SliverGrid(delegate: ..., gridDelegate: ...),
    SliverList(...),
  ],
)
```

### 2. Lazy Loading (Images & Items)
```dart
// HHMenuItemCard with cached_network_image
CachedNetworkImage(
  imageUrl: menuItem.imageKey,
  placeholder: (context, url) => PlaceholderCard(),
  errorWidget: (context, url, error) => ErrorCard(),
)

// Lazy load items in menu grid
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    if (index == items.length - 1) {
      // Trigger load more
      onLoadMore?.call();
    }
    return HHMenuItemCard(item: items[index]);
  },
)
```

### 3. Efficient Rebuilds
```dart
// Use ValueListenableBuilder instead of full screen rebuild
ValueListenableBuilder<List<HHOrderItemModel>>(
  valueListenable: orderService.currentOrder!.items,
  builder: (context, items, child) {
    return HHCartSummary(items: items); // Only cart rebuilds
  },
)

// Or watch specific ValueNotifier
Obx(() => Text('Total: ${orderService.currentOrder!.totalAmount.value}'))
```

### 4. Image Caching
- Use `cached_network_image ^3.4.1` (already in pubspec)
- Pre-cache commonly used images at app startup
- Image placeholder should be instant (not fetch heavy)

### 5. No Unnecessary Rebuilds
- Split large widgets into smaller components
- Use `const` constructors everywhere possible
- Separate cart from menu grid (different scroll axes)

---

## File Structure

```
lib/
├── Screen/
│   ├── Table/
│   │   ├── View/
│   │   │   ├── Components/
│   │   │   │   ├── HHTableCard.dart
│   │   │   │   ├── HHTableStatusBadge.dart
│   │   │   │   ├── HHTableAreaSection.dart
│   │   │   │   ├── HHTableGrid.dart
│   │   │   │   └── HHCustomerDetailsForm.dart
│   │   │   └── HHTableSelectionScreen.dart (composes components)
│   │   ├── Model/
│   │   │   └── HHTableModel.dart
│   │   └── Service/
│   │       └── HHTableService.dart
│   ├── Menu/
│   │   ├── View/
│   │   │   ├── Components/
│   │   │   │   ├── HHMenuItemCard.dart
│   │   │   │   ├── HHMenuItemGrid.dart
│   │   │   │   ├── HHMenuCategoryFilter.dart
│   │   │   │   └── HHDietaryFilterChip.dart
│   │   │   └── HHMenuBrowserScreen.dart
│   │   ├── Model/
│   │   │   └── HHMenuItemModel.dart
│   │   └── Service/
│   │       └── HHMenuService.dart
│   ├── Order/
│   │   ├── View/
│   │   │   ├── Components/
│   │   │   │   ├── HHCartSummary.dart
│   │   │   │   ├── HHCartItemRow.dart
│   │   │   │   ├── HHCartActionButton.dart
│   │   │   │   ├── HHOrderTotal.dart
│   │   │   │   └── HHSpecialRequestsInput.dart
│   │   │   └── HHOrderCartScreen.dart
│   │   ├── Model/
│   │   │   ├── HHOrderModel.dart
│   │   │   └── HHOrderItemModel.dart
│   │   └── Service/
│   │       └── HHOrderService.dart
│   ├── KOT/
│   │   ├── View/
│   │   │   ├── Components/
│   │   │   │   ├── HHKOTOrderCard.dart
│   │   │   │   └── HHKOTItemRow.dart
│   │   │   └── HHKOTDashboardScreen.dart
│   │   └── Service/
│   │       └── HHKOTService.dart
│   ├── Orders/
│   │   ├── View/
│   │   │   ├── Components/
│   │   │   │   ├── HHOrdersGrid.dart
│   │   │   │   ├── HHAllOrderCard.dart
│   │   │   │   └── HHStatusFilterTabs.dart
│   │   │   └── HHAllOrdersScreen.dart
│   │   └── Service/
│   │       └── HHAllOrdersService.dart
│   └── Payment/
│       ├── View/
│       │   ├── Components/
│       │   │   ├── HHSettlementDialog.dart
│       │   │   ├── HHSettlementButton.dart
│       │   │   ├── HHSplitPaymentForm.dart
│       │   │   ├── HHPercentageSplitInput.dart
│       │   │   └── HHItemWiseSplitList.dart
│       │   └── HHSplitPaymentScreen.dart
│       ├── Model/
│       │   └── HHPaymentSplitModel.dart
│       └── Service/
│           └── HHPaymentService.dart
├── Managers/
│   ├── HHAppManager.dart (extend with services)
│   ├── HHSessionManager.dart (reuse)
│   ├── HHStorageManager.dart (extend with order persistence)
│   └── MockData.dart (Phase 2 mock data)
├── API/
│   ├── ApiService.dart (reuse)
│   └── ApiConstants.dart (add Phase 2 endpoints when ready)
└── utils/
    ├── app_images.dart (add Phase 2 image keys)
    ├── app_colors.dart (reuse design tokens)
    ├── AppTextStyle.dart (reuse)
    └── ...
```

---

## Mock Data Strategy

**File:** `lib/Managers/MockData.dart`

```dart
class MockData {
  static final List<HHTableModel> tables = [
    HHTableModel(
      id: 'T-1',
      name: 'T-1',
      capacity: 4,
      area: 'Ground Floor',
      status: ValueNotifier('available'),
      currentOrderId: null,
    ),
    // ... 25 more tables
  ];

  static final List<HHMenuItemModel> menuItems = [
    HHMenuItemModel(
      id: 'SOUP-1',
      name: 'Lentil Soup',
      category: 'Soup',
      price: 40000,
      imageKey: appImages.imgLentilSoup, // References app_images.dart
      isVegetarian: true,
      spiceLevel: 1,
      isAvailable: ValueNotifier(true),
    ),
    // ... 50+ menu items
  ];

  static List<HHMenuItemModel> getItemsByCategory(String category) =>
    menuItems.where((i) => i.category == category).toList();
}
```

Services use this mock data initially. **Zero changes to services** when APIs arrive — just swap repository.

---

## Key Implementation Notes

1. **ValueNotifier for live updates** — Cart updates, table status, order status all reactive
2. **Small components** — Each component ~100-200 lines, reusable, testable
3. **Performance** — Smooth scrolling via BouncingScrollPhysics, lazy loading, efficient builders
4. **Asset management** — All image references in `app_images.dart`, you inject files
5. **Design system** — Use `AppColors`, `AppTextStyle`, `app_dimens` from Phase 1
6. **No new managers** — Extend `HHAppManager` & `HHStorageManager` only
7. **Mock-first** — Build with mock data, swap with APIs later

---

## Verification Checklist

✅ All components render without errors  
✅ Smooth scrolling (BouncingScrollPhysics)  
✅ Cart updates in real-time (ValueNotifier)  
✅ Table selection multi-select works  
✅ Menu filters (veg/spicy) update live  
✅ Images lazy-load and cache  
✅ No console errors in DevTools  
✅ Landscape orientation maintained  
✅ Text scaling disabled  
✅ Color/font tokens applied  
✅ Navigation animations smooth  

---

## Summary

**30+ small reusable components** built with:
- ✅ Extended managers (no new ones)
- ✅ Live ValueNotifier reactivity
- ✅ Performance-first (smooth scrolling, lazy loading)
- ✅ Static assets managed in app_images.dart
- ✅ Mock data → Real API swap (zero refactoring)
- ✅ Design system consistency

**Ready for component-by-component implementation via Claude Code agents.**
