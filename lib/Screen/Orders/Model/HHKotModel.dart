import 'package:hookahhabibi/Screen/Orders/Model/HHKotItemModel.dart';
import 'package:hookahhabibi/Screen/Orders/Model/HHOrderUserModel.dart';

/// A KOT (Kitchen Order Ticket) — a batch of items sent to the kitchen
/// as part of an order. An order may contain multiple KOTs.
class HHKotModel {
  final int id;
  final int orderId;
  final int userId;
  final String status;
  final String statusLabel;
  final String? notes;
  final String? startedAt;
  final String? completedAt;
  final int timeTaken;
  final String? createdAt;
  final String? updatedAt;
  final int itemsCount;
  final num totalAmount;
  final HHOrderUserModel? user;
  final List<HHKotItemModel> items;

  const HHKotModel({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.status,
    required this.statusLabel,
    this.notes,
    this.startedAt,
    this.completedAt,
    this.timeTaken = 0,
    this.createdAt,
    this.updatedAt,
    this.itemsCount = 0,
    this.totalAmount = 0,
    this.user,
    this.items = const [],
  });

  factory HHKotModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final rawUser = json['user'];
    return HHKotModel(
      id: _toInt(json['id'] ?? json['kot_id']),
      orderId: _toInt(json['order_id']),
      userId: _toInt(json['user_id']),
      status: (json['status'] ?? '').toString(),
      statusLabel: (json['status_label'] ?? '').toString(),
      notes: json['notes']?.toString(),
      startedAt: json['started_at']?.toString(),
      completedAt: json['completed_at']?.toString(),
      timeTaken: _toInt(json['time_taken']),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      itemsCount: _toInt(json['items_count']),
      totalAmount: _toNum(json['total_amount']),
      user: rawUser is Map<String, dynamic>
          ? HHOrderUserModel.fromJson(rawUser)
          : null,
      items: rawItems is List
          ? HHKotItemModel.listFromJson(rawItems)
          : const [],
    );
  }

  static List<HHKotModel> listFromJson(List<dynamic> raw) => raw
      .whereType<Map<String, dynamic>>()
      .map(HHKotModel.fromJson)
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
