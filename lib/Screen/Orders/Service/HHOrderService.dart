import 'dart:convert';

import 'package:hookahhabibi/API/ApiConstants.dart';
import 'package:hookahhabibi/API/ApiResponseGeneric.dart';
import 'package:hookahhabibi/API/ApiService.dart';
import 'package:hookahhabibi/Screen/Orders/Model/HHBillSplitRequest.dart';
import 'package:hookahhabibi/Screen/Orders/Model/HHOrderModel.dart';
import 'package:hookahhabibi/Screen/Orders/Model/HHSplitBillResultModel.dart';

/// Result of /api/add-kot-to-order — the full updated order plus the
/// id of the newly created KOT (top-level `kot_id` in the response).
class HHAddKotResult {
  final HHOrderModel order;
  final int newKotId;

  const HHAddKotResult({required this.order, required this.newKotId});
}

class HHOrderService {
  final ApiService _apiService = ApiService();

  /// POST /api/save-order-with-kot
  /// Books the table and creates an order with its first KOT.
  ///
  /// Pass either [customerId] (existing customer) OR
  /// [customerName] + [customerPhone] (walk-in). [customerNotes] is optional
  /// metadata stored against the customer record server-side.
  Future<ApiResponse<HHOrderModel>> saveOrderWithKot({
    required String bearerToken,
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
    try {
      final fields = <String, String>{
        ApiConstants.fieldBearerToken: bearerToken,
        ApiConstants.fieldLocationIdPlain: locationId.toString(),
        ApiConstants.fieldTableId: tableId.toString(),
        ApiConstants.fieldGuestCount: guestCount.toString(),
        if (customerId != null)
          ApiConstants.fieldCustomerId: customerId.toString(),
        if (customerName != null && customerName.isNotEmpty)
          ApiConstants.fieldCustomerName: customerName,
        if (customerPhone != null && customerPhone.isNotEmpty)
          ApiConstants.fieldCustomerPhone: customerPhone,
        if (customerNotes != null && customerNotes.isNotEmpty)
          ApiConstants.fieldCustomerNotes: customerNotes,
        if (notes != null && notes.isNotEmpty) ApiConstants.fieldNotes: notes,
      };

      for (var i = 0; i < items.length; i++) {
        final item = items[i];
        fields['items[$i][dish_id]'] = item.dishId.toString();
        fields['items[$i][quantity]'] = item.quantity.toString();
        fields['items[$i][dish_title]'] = item.dishTitle;
        if (item.dishSubtitle != null && item.dishSubtitle!.isNotEmpty) {
          fields['items[$i][dish_subtitle]'] = item.dishSubtitle!;
        }
        fields['items[$i][dish_price]'] = item.dishPrice.toString();
        if (item.notes != null && item.notes!.isNotEmpty) {
          fields['items[$i][notes]'] = item.notes!;
        }
      }

      final response = await _apiService.postMultipart(
        endpoint: ApiConstants.saveOrderWithKot,
        fields: fields,
      );

      if (response[ApiConstants.keyType] == ApiConstants.statusError) {
        return ApiResponse.error(
          message: response[ApiConstants.keyMsg]?.toString() ?? 'Unknown error',
          errorCode: 'API_ERROR',
        );
      }

      final raw = response[ApiConstants.keyData];
      if (raw is! Map<String, dynamic>) {
        return ApiResponse.error(
          message: 'Malformed response: missing order data',
          errorCode: 'PARSE_ERROR',
        );
      }

      return ApiResponse.success(
        data: HHOrderModel.fromJson(raw),
        message: response[ApiConstants.keyMsg]?.toString(),
      );
    } on ApiException catch (e) {
      return ApiResponse.error(message: e.message, errorCode: e.code);
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to create order: $e',
        errorCode: 'CREATE_ORDER_ERROR',
      );
    }
  }

  /// POST /api/add-kot-to-order
  /// Adds a new KOT (batch of items) to an existing order. Server resolves
  /// dish title/price from `dish_id`, so item payload is slim.
  Future<ApiResponse<HHAddKotResult>> addKotToOrder({
    required String bearerToken,
    required int orderId,
    String? notes,
    required List<HHAddKotItemRequest> items,
  }) async {
    try {
      final fields = <String, String>{
        ApiConstants.fieldBearerToken: bearerToken,
        ApiConstants.fieldOrderId: orderId.toString(),
        if (notes != null && notes.isNotEmpty) ApiConstants.fieldNotes: notes,
      };

      for (var i = 0; i < items.length; i++) {
        final item = items[i];
        fields['items[$i][dish_id]'] = item.dishId.toString();
        fields['items[$i][quantity]'] = item.quantity.toString();
        if (item.notes != null && item.notes!.isNotEmpty) {
          fields['items[$i][notes]'] = item.notes!;
        }
      }

      final response = await _apiService.postMultipart(
        endpoint: ApiConstants.addKotToOrder,
        fields: fields,
      );

      if (response[ApiConstants.keyType] == ApiConstants.statusError) {
        return ApiResponse.error(
          message: response[ApiConstants.keyMsg]?.toString() ?? 'Unknown error',
          errorCode: 'API_ERROR',
        );
      }

      final raw = response[ApiConstants.keyData];
      if (raw is! Map<String, dynamic>) {
        return ApiResponse.error(
          message: 'Malformed response: missing order data',
          errorCode: 'PARSE_ERROR',
        );
      }

      final order = HHOrderModel.fromJson(raw);
      final newKotId = _toInt(response['kot_id']);

      return ApiResponse.success(
        data: HHAddKotResult(order: order, newKotId: newKotId),
        message: response[ApiConstants.keyMsg]?.toString(),
      );
    } on ApiException catch (e) {
      return ApiResponse.error(message: e.message, errorCode: e.code);
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to add KOT: $e',
        errorCode: 'ADD_KOT_ERROR',
      );
    }
  }

  /// POST /api/update-qty — change the quantity of a single KOT item.
  /// Returns the full updated order.
  Future<ApiResponse<HHOrderModel>> updateQty({
    required String bearerToken,
    required int kotItemId,
    required int newQty,
  }) {
    return _postAndParseOrder(
      endpoint: ApiConstants.updateQty,
      fields: {
        ApiConstants.fieldBearerToken: bearerToken,
        ApiConstants.fieldKotItemId: kotItemId.toString(),
        ApiConstants.fieldNewQty: newQty.toString(),
      },
      errorCode: 'UPDATE_QTY_ERROR',
      errorMessage: 'Failed to update quantity',
    );
  }

  /// POST /api/edit-item-note — change a KOT item's note.
  /// Pass an empty string to clear the note (server accepts it).
  Future<ApiResponse<HHOrderModel>> editItemNote({
    required String bearerToken,
    required int kotItemId,
    required String newNote,
  }) {
    return _postAndParseOrder(
      endpoint: ApiConstants.editItemNote,
      fields: {
        ApiConstants.fieldBearerToken: bearerToken,
        ApiConstants.fieldKotItemId: kotItemId.toString(),
        ApiConstants.fieldNewNote: newNote,
      },
      errorCode: 'EDIT_ITEM_NOTE_ERROR',
      errorMessage: 'Failed to update item note',
    );
  }

  /// POST /api/edit-order-note — change the order-level note.
  /// Pass an empty string to clear it.
  Future<ApiResponse<HHOrderModel>> editOrderNote({
    required String bearerToken,
    required int orderId,
    required String note,
  }) {
    return _postAndParseOrder(
      endpoint: ApiConstants.editOrderNote,
      fields: {
        ApiConstants.fieldBearerToken: bearerToken,
        ApiConstants.fieldOrderId: orderId.toString(),
        ApiConstants.fieldNote: note,
      },
      errorCode: 'EDIT_ORDER_NOTE_ERROR',
      errorMessage: 'Failed to update order note',
    );
  }

  /// POST /api/cancel-kot-item — cancel a single item (when [dishId] is
  /// provided) or the whole KOT (when [dishId] is omitted; server reports
  /// `cancelled_scope: "kot"` in that case). The cancelled item is
  /// hard-removed from `kots[].items[]` in the returned order.
  Future<ApiResponse<HHOrderModel>> cancelKotItem({
    required String bearerToken,
    required int kotId,
    int? dishId,
    required String reason,
  }) {
    return _postAndParseOrder(
      endpoint: ApiConstants.cancelKotItem,
      fields: {
        ApiConstants.fieldBearerToken: bearerToken,
        ApiConstants.fieldKotId: kotId.toString(),
        if (dishId != null) ApiConstants.fieldDishId: dishId.toString(),
        ApiConstants.fieldReason: reason,
      },
      errorCode: 'CANCEL_KOT_ITEM_ERROR',
      errorMessage: 'Failed to cancel item',
    );
  }

  /// POST /api/cancel-order — cancel the entire order. Response sets
  /// `order_status = "c"`, `cancelled_at`, empties `kots` and zeroes totals.
  Future<ApiResponse<HHOrderModel>> cancelOrder({
    required String bearerToken,
    required int orderId,
    required String reason,
  }) {
    return _postAndParseOrder(
      endpoint: ApiConstants.cancelOrder,
      fields: {
        ApiConstants.fieldBearerToken: bearerToken,
        ApiConstants.fieldOrderId: orderId.toString(),
        ApiConstants.fieldReason: reason,
      },
      errorCode: 'CANCEL_ORDER_ERROR',
      errorMessage: 'Failed to cancel order',
    );
  }

  /// POST /api/get-orders — list orders, optionally filtered by customer.
  /// Returns the flat top-level `data` array (each order with full nested
  /// kots[].items[]). Includes cancelled and completed orders. Newest first.
  Future<ApiResponse<List<HHOrderModel>>> getOrders({
    required String bearerToken,
    int? customerId,
    String? customerName,
    String? customerPhone,
  }) async {
    try {
      final response = await _apiService.postMultipart(
        endpoint: ApiConstants.getOrders,
        fields: {
          ApiConstants.fieldBearerToken: bearerToken,
          if (customerId != null)
            ApiConstants.fieldCustomerId: customerId.toString(),
          if (customerName != null && customerName.isNotEmpty)
            ApiConstants.fieldCustomerName: customerName,
          if (customerPhone != null && customerPhone.isNotEmpty)
            ApiConstants.fieldCustomerPhone: customerPhone,
        },
      );

      if (response[ApiConstants.keyType] == ApiConstants.statusError) {
        return ApiResponse.error(
          message: response[ApiConstants.keyMsg]?.toString() ?? 'Unknown error',
          errorCode: 'API_ERROR',
        );
      }

      final raw = response[ApiConstants.keyData];
      final list = (raw is List)
          ? HHOrderModel.listFromJson(raw)
          : const <HHOrderModel>[];

      return ApiResponse.success(data: list);
    } on ApiException catch (e) {
      return ApiResponse.error(message: e.message, errorCode: e.code);
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to fetch orders: $e',
        errorCode: 'FETCH_ORDERS_ERROR',
      );
    }
  }

  /// POST /api/orders/split-bill — split a bill across multiple payers.
  ///
  /// Pass [ApiConstants.splitTypeItemWise] (`"i"`) with item-wise splits, or
  /// [ApiConstants.splitTypePercentage] (`"p"`) with percentage splits.
  /// [splits] is JSON-encoded as a string for the `splits` form field.
  ///
  /// Response envelope differs from the order endpoints:
  ///   - Success: `{"success": true, "message": "...", "data": {split summary}}`
  ///   - Error (422): `{"success": false, "message": "..."}` — surfaced as
  ///     [ApiException] from the HTTP layer.
  ///
  /// `data` is NOT an `HHOrderModel`; it's a separate split-bill summary
  /// (totals + a list of per-payer entries). To reflect `split_bill="y"`
  /// on the order itself, refetch via `getOrders` after a successful split.
  ///
  /// Business rule: once any split bill is paid, the split cannot be
  /// recreated — the API returns 422 with a descriptive message.
  Future<ApiResponse<HHSplitBillResultModel>> splitBill({
    required String bearerToken,
    required int orderId,
    required String splitType,
    required List<HHBillSplitRequest> splits,
  }) async {
    try {
      final splitsJson = jsonEncode(splits.map((s) => s.toJson()).toList());

      final response = await _apiService.postMultipart(
        endpoint: ApiConstants.splitBill,
        fields: {
          ApiConstants.fieldBearerToken: bearerToken,
          ApiConstants.fieldOrderId: orderId.toString(),
          ApiConstants.fieldSplitType: splitType,
          ApiConstants.fieldSplits: splitsJson,
        },
      );

      // Success body uses {"success": true, ...} envelope (not "type"). A
      // 200 with success:false would still indicate an error — handle both.
      if (response['success'] == false) {
        return ApiResponse.error(
          message: response['message']?.toString() ?? 'Failed to split bill',
          errorCode: 'API_ERROR',
        );
      }

      final raw = response[ApiConstants.keyData];
      if (raw is! Map<String, dynamic>) {
        return ApiResponse.error(
          message: 'Malformed response: missing split-bill data',
          errorCode: 'PARSE_ERROR',
        );
      }

      return ApiResponse.success(
        data: HHSplitBillResultModel.fromJson(raw),
        message: response['message']?.toString(),
      );
    } on ApiException catch (e) {
      return ApiResponse.error(message: e.message, errorCode: e.code);
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to split bill: $e',
        errorCode: 'SPLIT_BILL_ERROR',
      );
    }
  }

  /// Shared helper for endpoints that mutate an order and return the full
  /// updated order in `data`. Covers update-qty, edit-item-note,
  /// edit-order-note, cancel-kot-item, cancel-order.
  Future<ApiResponse<HHOrderModel>> _postAndParseOrder({
    required String endpoint,
    required Map<String, String> fields,
    required String errorCode,
    required String errorMessage,
  }) async {
    try {
      final response = await _apiService.postMultipart(
        endpoint: endpoint,
        fields: fields,
      );

      if (response[ApiConstants.keyType] == ApiConstants.statusError) {
        return ApiResponse.error(
          message: response[ApiConstants.keyMsg]?.toString() ?? 'Unknown error',
          errorCode: 'API_ERROR',
        );
      }

      final raw = response[ApiConstants.keyData];
      if (raw is! Map<String, dynamic>) {
        return ApiResponse.error(
          message: 'Malformed response: missing order data',
          errorCode: 'PARSE_ERROR',
        );
      }

      return ApiResponse.success(
        data: HHOrderModel.fromJson(raw),
        message: response[ApiConstants.keyMsg]?.toString(),
      );
    } on ApiException catch (e) {
      return ApiResponse.error(message: e.message, errorCode: e.code);
    } catch (e) {
      return ApiResponse.error(
        message: '$errorMessage: $e',
        errorCode: errorCode,
      );
    }
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}
