import 'package:flutter/foundation.dart';
import 'package:hookahhabibi/API/ApiResponseGeneric.dart';
import 'package:hookahhabibi/Managers/HHSessionManager.dart';
import 'package:hookahhabibi/Screen/Orders/Model/HHBillSplitRequest.dart';
import 'package:hookahhabibi/Screen/Orders/Model/HHOrderModel.dart';
import 'package:hookahhabibi/Screen/Orders/Model/HHSplitBillResultModel.dart';
import 'package:hookahhabibi/Screen/Orders/Service/HHOrderService.dart';

/// Singleton + ChangeNotifier — owns the active/current order state plus
/// the in-memory orders list. Wires into save-order-with-kot,
/// add-kot-to-order, update-qty, edit-*-note, cancel-*, and get-orders.
class HHOrderManager extends ChangeNotifier {
  static final HHOrderManager _instance = HHOrderManager._internal();
  factory HHOrderManager() => _instance;
  HHOrderManager._internal();

  final HHOrderService _service = HHOrderService();
  final HHSessionManager _session = HHSessionManager();

  // State
  HHOrderModel? _currentOrder;
  final List<HHOrderModel> _orders = [];
  bool _isCreating = false;
  bool _isAddingKot = false;
  bool _isMutating = false;
  bool _isLoadingList = false;
  bool _isSplittingBill = false;
  HHSplitBillResultModel? _lastSplitResult;
  int? _lastAddedKotId;
  String? _error;

  // Getters
  HHOrderModel? get currentOrder => _currentOrder;
  List<HHOrderModel> get orders => List.unmodifiable(_orders);
  bool get isCreating => _isCreating;
  bool get isAddingKot => _isAddingKot;
  bool get isMutating => _isMutating;
  bool get isLoadingList => _isLoadingList;
  bool get isSplittingBill => _isSplittingBill;
  HHSplitBillResultModel? get lastSplitResult => _lastSplitResult;
  int? get lastAddedKotId => _lastAddedKotId;
  String? get error => _error;

  /// POST /api/save-order-with-kot — books the table and creates the order.
  /// On success, the returned order is set as the current order and prepended
  /// to the in-memory list.
  Future<HHOrderModel?> createOrderWithKot({
    required int locationId,
    required int tableId,
    int? customerId,
    String? customerName,
    String? customerPhone,
    String? customerNotes,
    required int guestCount,
    String? notes,
    required List<HHOrderItemRequest> items,
  }) async {
    final token = _session.bearerToken;
    if (token == null || token.isEmpty) {
      _error = 'Session expired. Please log in again.';
      notifyListeners();
      return null;
    }

    if (items.isEmpty) {
      _error = 'Please add at least one item to the order.';
      notifyListeners();
      return null;
    }

    _isCreating = true;
    _error = null;
    notifyListeners();

    final response = await _service.saveOrderWithKot(
      bearerToken: token,
      locationId: locationId,
      tableId: tableId,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      customerNotes: customerNotes,
      guestCount: guestCount,
      notes: notes,
      items: items,
    );

    _isCreating = false;

    if (response.success && response.data != null) {
      _currentOrder = response.data;
      _orders.insert(0, response.data!);
      notifyListeners();
      return response.data;
    }

    _error = response.message ?? 'Failed to create order';
    notifyListeners();
    return null;
  }

  /// POST /api/add-kot-to-order — append a new KOT to an existing order.
  /// Updates [currentOrder] and replaces the order in the in-memory list.
  /// Returns the new KOT id (top-level `kot_id` in the response) or null on failure.
  Future<int?> addKotToOrder({
    required int orderId,
    String? notes,
    required List<HHAddKotItemRequest> items,
  }) async {
    final token = _session.bearerToken;
    if (token == null || token.isEmpty) {
      _error = 'Session expired. Please log in again.';
      notifyListeners();
      return null;
    }

    if (items.isEmpty) {
      _error = 'Please add at least one item to the KOT.';
      notifyListeners();
      return null;
    }

    _isAddingKot = true;
    _error = null;
    notifyListeners();

    final response = await _service.addKotToOrder(
      bearerToken: token,
      orderId: orderId,
      notes: notes,
      items: items,
    );

    _isAddingKot = false;

    if (response.success && response.data != null) {
      _applyUpdatedOrder(response.data!.order);
      _lastAddedKotId = response.data!.newKotId;
      notifyListeners();
      return _lastAddedKotId;
    }

    _error = response.message ?? 'Failed to add KOT';
    notifyListeners();
    return null;
  }

  /// POST /api/update-qty — change a KOT item's quantity.
  /// Returns the updated order on success, null on failure.
  Future<HHOrderModel?> updateItemQty({
    required int kotItemId,
    required int newQty,
  }) async {
    if (newQty < 1) {
      _error = 'Quantity must be at least 1.';
      notifyListeners();
      return null;
    }
    return _runOrderMutation(
      action: (token) => _service.updateQty(
        bearerToken: token,
        kotItemId: kotItemId,
        newQty: newQty,
      ),
      defaultErrorMessage: 'Failed to update quantity',
    );
  }

  /// POST /api/edit-item-note — change a KOT item's note. Pass an empty
  /// string to clear it.
  Future<HHOrderModel?> editItemNote({
    required int kotItemId,
    required String newNote,
  }) async {
    return _runOrderMutation(
      action: (token) => _service.editItemNote(
        bearerToken: token,
        kotItemId: kotItemId,
        newNote: newNote,
      ),
      defaultErrorMessage: 'Failed to update item note',
    );
  }

  /// POST /api/edit-order-note — change the order-level note. Pass an
  /// empty string to clear it.
  Future<HHOrderModel?> editOrderNote({
    required int orderId,
    required String note,
  }) {
    return _runOrderMutation(
      action: (token) => _service.editOrderNote(
        bearerToken: token,
        orderId: orderId,
        note: note,
      ),
      defaultErrorMessage: 'Failed to update order note',
    );
  }

  /// POST /api/cancel-kot-item — cancel a single item (when [dishId] is
  /// provided) or the entire KOT (when [dishId] is omitted).
  Future<HHOrderModel?> cancelKotItem({
    required int kotId,
    int? dishId,
    required String reason,
  }) {
    return _runOrderMutation(
      action: (token) => _service.cancelKotItem(
        bearerToken: token,
        kotId: kotId,
        dishId: dishId,
        reason: reason,
      ),
      defaultErrorMessage: 'Failed to cancel item',
    );
  }

  /// POST /api/cancel-order — cancel the entire order. The returned order
  /// will have `orderStatus == "c"`, `cancelledAt` set, empty `kots`, and
  /// totals zeroed.
  Future<HHOrderModel?> cancelOrder({
    required int orderId,
    required String reason,
  }) {
    return _runOrderMutation(
      action: (token) => _service.cancelOrder(
        bearerToken: token,
        orderId: orderId,
        reason: reason,
      ),
      defaultErrorMessage: 'Failed to cancel order',
    );
  }

  /// POST /api/get-orders — replace [_orders] with the server list.
  /// Optionally filter by customer. Returns true on success.
  Future<bool> loadOrders({
    int? customerId,
    String? customerName,
    String? customerPhone,
  }) async {
    final token = _session.bearerToken;
    if (token == null || token.isEmpty) {
      _error = 'Session expired. Please log in again.';
      notifyListeners();
      return false;
    }

    _isLoadingList = true;
    _error = null;
    notifyListeners();

    final response = await _service.getOrders(
      bearerToken: token,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
    );

    _isLoadingList = false;

    if (response.success) {
      _orders
        ..clear()
        ..addAll(response.data ?? const []);
      notifyListeners();
      return true;
    }

    _error = response.message ?? 'Failed to load orders';
    notifyListeners();
    return false;
  }

  /// POST /api/orders/split-bill — split the bill across multiple payers.
  /// Build splits with [HHBillSplitRequest.itemWise] or
  /// [HHBillSplitRequest.percentage]. On success, the result is cached in
  /// [lastSplitResult] and returned.
  ///
  /// The split-bill endpoint does NOT return the full order, so this method
  /// does NOT update [currentOrder] or [orders]. Call [loadOrders] after a
  /// successful split if the UI needs to reflect `split_bill="y"` on the
  /// order itself.
  Future<HHSplitBillResultModel?> splitBill({
    required int orderId,
    required String splitType,
    required List<HHBillSplitRequest> splits,
  }) async {
    if (splits.isEmpty) {
      _error = 'At least one split is required.';
      notifyListeners();
      return null;
    }

    final token = _session.bearerToken;
    if (token == null || token.isEmpty) {
      _error = 'Session expired. Please log in again.';
      notifyListeners();
      return null;
    }

    _isSplittingBill = true;
    _error = null;
    notifyListeners();

    final response = await _service.splitBill(
      bearerToken: token,
      orderId: orderId,
      splitType: splitType,
      splits: splits,
    );

    _isSplittingBill = false;

    if (response.success && response.data != null) {
      _lastSplitResult = response.data;
      notifyListeners();
      return response.data;
    }

    _error = response.message ?? 'Failed to split bill';
    notifyListeners();
    return null;
  }

  /// Shared driver for order-mutation endpoints that toggle [isMutating]
  /// and call [_applyUpdatedOrder] on success.
  Future<HHOrderModel?> _runOrderMutation({
    required Future<ApiResponse<HHOrderModel>> Function(String token) action,
    required String defaultErrorMessage,
  }) async {
    final token = _session.bearerToken;
    if (token == null || token.isEmpty) {
      _error = 'Session expired. Please log in again.';
      notifyListeners();
      return null;
    }

    _isMutating = true;
    _error = null;
    notifyListeners();

    final response = await action(token);

    _isMutating = false;

    if (response.success && response.data != null) {
      _applyUpdatedOrder(response.data!);
      notifyListeners();
      return response.data;
    }

    _error = response.message ?? defaultErrorMessage;
    notifyListeners();
    return null;
  }

  /// Replace the order in [_orders] and update [_currentOrder] if it matches.
  void _applyUpdatedOrder(HHOrderModel updated) {
    if (_currentOrder?.id == updated.id) {
      _currentOrder = updated;
    }
    final idx = _orders.indexWhere((o) => o.id == updated.id);
    if (idx >= 0) {
      _orders[idx] = updated;
    } else {
      _orders.insert(0, updated);
    }
  }

  void clearCurrentOrder() {
    if (_currentOrder == null) return;
    _currentOrder = null;
    notifyListeners();
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  void reset() {
    _currentOrder = null;
    _orders.clear();
    _isCreating = false;
    _isAddingKot = false;
    _isMutating = false;
    _isLoadingList = false;
    _isSplittingBill = false;
    _lastAddedKotId = null;
    _lastSplitResult = null;
    _error = null;
    notifyListeners();
  }
}
