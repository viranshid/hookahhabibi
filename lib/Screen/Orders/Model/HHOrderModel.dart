import 'package:hookahhabibi/Screen/Customer/Model/HHCustomerModel.dart';
import 'package:hookahhabibi/Screen/Orders/Model/HHKotModel.dart';
import 'package:hookahhabibi/Screen/Orders/Model/HHOrderTableModel.dart';
import 'package:hookahhabibi/Screen/Orders/Model/HHOrderUserModel.dart';

/// API-aligned order model — matches /api/save-order-with-kot,
/// /api/add-kot-to-order, /api/get-orders payloads.
class HHOrderModel {
  final int id;
  final int locationId;
  final int tableId;
  final int? customerId;
  final int userId;
  final String orderStatus;
  final String orderStatusLabel;
  final String splitBill;
  final String? splitBillType;
  final num totalAmount;
  final int guestCount;
  final String? notes;
  final String? cancelledAt;
  final String? completedAt;
  final String? createdAt;
  final String? updatedAt;
  final int orderKotsCount;
  final int kotItemsCount;
  final HHCustomerModel? customer;
  final HHOrderLocationModel? location;
  final HHOrderTableModel? table;
  final HHOrderUserModel? user;
  final List<HHKotModel> kots;

  const HHOrderModel({
    required this.id,
    required this.locationId,
    required this.tableId,
    this.customerId,
    required this.userId,
    required this.orderStatus,
    required this.orderStatusLabel,
    this.splitBill = 'n',
    this.splitBillType,
    this.totalAmount = 0,
    this.guestCount = 0,
    this.notes,
    this.cancelledAt,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
    this.orderKotsCount = 0,
    this.kotItemsCount = 0,
    this.customer,
    this.location,
    this.table,
    this.user,
    this.kots = const [],
  });

  factory HHOrderModel.fromJson(Map<String, dynamic> json) {
    final rawCustomer = json['customer'];
    final rawLocation = json['location'];
    final rawTable = json['table'];
    final rawUser = json['user'];
    final rawKots = json['kots'];

    return HHOrderModel(
      id: _toInt(json['id']),
      locationId: _toInt(json['location_id']),
      tableId: _toInt(json['table_id']),
      customerId: json['customer_id'] == null ? null : _toInt(json['customer_id']),
      userId: _toInt(json['user_id']),
      orderStatus: (json['order_status'] ?? '').toString(),
      orderStatusLabel: (json['order_status_label'] ?? '').toString(),
      splitBill: (json['split_bill'] ?? 'n').toString(),
      splitBillType: json['split_bill_type']?.toString(),
      totalAmount: _toNum(json['total_amount']),
      guestCount: _toInt(json['guest_count']),
      notes: json['notes']?.toString(),
      cancelledAt: json['cancelled_at']?.toString(),
      completedAt: json['completed_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      orderKotsCount: _toInt(json['order_kots_count']),
      kotItemsCount: _toInt(json['kot_items_count']),
      customer: rawCustomer is Map<String, dynamic>
          ? HHCustomerModel.fromJson(rawCustomer)
          : null,
      location: rawLocation is Map<String, dynamic>
          ? HHOrderLocationModel.fromJson(rawLocation)
          : null,
      table: rawTable is Map<String, dynamic>
          ? HHOrderTableModel.fromJson(rawTable)
          : null,
      user: rawUser is Map<String, dynamic>
          ? HHOrderUserModel.fromJson(rawUser)
          : null,
      kots: rawKots is List ? HHKotModel.listFromJson(rawKots) : const [],
    );
  }

  bool get isCancelled => cancelledAt != null;
  bool get isCompleted => completedAt != null;

  static List<HHOrderModel> listFromJson(List<dynamic> raw) => raw
      .whereType<Map<String, dynamic>>()
      .map(HHOrderModel.fromJson)
      .toList();

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static num _toNum(dynamic v) {
    if (v is num) return v;
    return num.tryParse(v?.toString() ?? '') ?? 0;
  }
}

/// Request payload for a single item line on /api/save-order-with-kot.
/// Save flow requires full dish details so the server can persist them
/// against the KOT item even if the dish record later changes.
class HHOrderItemRequest {
  final int dishId;
  final int quantity;
  final String dishTitle;
  final String? dishSubtitle;
  final num dishPrice;
  final String? notes;

  const HHOrderItemRequest({
    required this.dishId,
    required this.quantity,
    required this.dishTitle,
    this.dishSubtitle,
    required this.dishPrice,
    this.notes,
  });
}

/// Request payload for a single item line on /api/add-kot-to-order.
/// Add-KOT flow only needs the dish reference; title/subtitle/price are
/// resolved server-side from `dish_id`.
class HHAddKotItemRequest {
  final int dishId;
  final int quantity;
  final String? notes;

  const HHAddKotItemRequest({
    required this.dishId,
    required this.quantity,
    this.notes,
  });
}
