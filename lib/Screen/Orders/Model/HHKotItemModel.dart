/// A single line item within a KOT (Kitchen Order Ticket).
class HHKotItemModel {
  final int id;
  final int orderId;
  final int kotId;
  final int dishId;
  final String dishName;
  final String dishTitle;
  final String? dishSubtitle;
  final String? priceTitle;
  final int quantity;
  final num dishPrice;
  final num lineTotal;
  final String status;
  final String statusLabel;
  final String? notes;
  final String? startedAt;
  final String? completedAt;
  final int timeTaken;
  final String? createdAt;
  final String? updatedAt;

  const HHKotItemModel({
    required this.id,
    required this.orderId,
    required this.kotId,
    required this.dishId,
    required this.dishName,
    required this.dishTitle,
    this.dishSubtitle,
    this.priceTitle,
    required this.quantity,
    required this.dishPrice,
    required this.lineTotal,
    required this.status,
    required this.statusLabel,
    this.notes,
    this.startedAt,
    this.completedAt,
    this.timeTaken = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory HHKotItemModel.fromJson(Map<String, dynamic> json) {
    return HHKotItemModel(
      id: _toInt(json['id']),
      orderId: _toInt(json['order_id']),
      kotId: _toInt(json['kot_id']),
      dishId: _toInt(json['dish_id']),
      dishName: (json['dish_name'] ?? '').toString(),
      dishTitle: (json['dish_title'] ?? '').toString(),
      dishSubtitle: json['dish_subtitle']?.toString(),
      priceTitle: json['price_title']?.toString(),
      quantity: _toInt(json['quantity'] ?? json['qty']),
      dishPrice: _toNum(json['dish_price'] ?? json['price']),
      lineTotal: _toNum(json['line_total']),
      status: (json['status'] ?? '').toString(),
      statusLabel: (json['status_label'] ?? '').toString(),
      notes: json['notes']?.toString(),
      startedAt: json['started_at']?.toString(),
      completedAt: json['completed_at']?.toString(),
      timeTaken: _toInt(json['time_taken']),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  static List<HHKotItemModel> listFromJson(List<dynamic> raw) => raw
      .whereType<Map<String, dynamic>>()
      .map(HHKotItemModel.fromJson)
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
