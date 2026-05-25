/// Top-level result of /api/orders/split-bill.
class HHSplitBillResultModel {
  final int orderId;
  /// 'y' when split, 'n' otherwise.
  final String splitBill;
  /// 'i' (item-wise) or 'p' (percentage), null when not split.
  final String? splitBillType;
  final num orderTotal;
  final num splitTotal;
  final num remainingTotal;
  final bool isTotalMatched;
  final List<HHSplitBillEntry> splitBills;

  const HHSplitBillResultModel({
    required this.orderId,
    required this.splitBill,
    this.splitBillType,
    required this.orderTotal,
    required this.splitTotal,
    required this.remainingTotal,
    required this.isTotalMatched,
    this.splitBills = const [],
  });

  factory HHSplitBillResultModel.fromJson(Map<String, dynamic> json) {
    final raw = json['split_bills'];
    return HHSplitBillResultModel(
      orderId: _toInt(json['order_id']),
      splitBill: (json['split_bill'] ?? 'n').toString(),
      splitBillType: json['split_bill_type']?.toString(),
      orderTotal: _toNum(json['order_total']),
      splitTotal: _toNum(json['split_total']),
      remainingTotal: _toNum(json['remaining_total']),
      isTotalMatched: json['is_total_matched'] == true,
      splitBills: raw is List
          ? HHSplitBillEntry.listFromJson(raw)
          : const [],
    );
  }

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

/// One split-bill record (one payer's portion).
class HHSplitBillEntry {
  final int id;
  final int orderId;
  final String splitName;
  /// 'i' or 'p'.
  final String splitType;
  /// Set for percentage splits; null for item-wise.
  final num? percentage;
  /// Set for item-wise splits; empty for percentage.
  final List<HHSplitBillItem> items;
  final num itemTotal;
  /// Server-side status (e.g. 'd' = draft, others TBC once paid flow exists).
  final String status;
  final String? notes;
  final int? createdBy;
  final String? createdAt;
  final String? updatedAt;

  const HHSplitBillEntry({
    required this.id,
    required this.orderId,
    required this.splitName,
    required this.splitType,
    this.percentage,
    this.items = const [],
    required this.itemTotal,
    required this.status,
    this.notes,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory HHSplitBillEntry.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    return HHSplitBillEntry(
      id: HHSplitBillResultModel._toInt(json['id']),
      orderId: HHSplitBillResultModel._toInt(json['order_id']),
      splitName: (json['split_name'] ?? '').toString(),
      splitType: (json['split_type'] ?? '').toString(),
      percentage: json['percentage'] == null
          ? null
          : HHSplitBillResultModel._toNum(json['percentage']),
      items: rawItems is List
          ? HHSplitBillItem.listFromJson(rawItems)
          : const [],
      itemTotal: HHSplitBillResultModel._toNum(json['item_total']),
      status: (json['status'] ?? '').toString(),
      notes: json['notes']?.toString(),
      createdBy: json['created_by'] == null
          ? null
          : HHSplitBillResultModel._toInt(json['created_by']),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  static List<HHSplitBillEntry> listFromJson(List<dynamic> raw) => raw
      .whereType<Map<String, dynamic>>()
      .map(HHSplitBillEntry.fromJson)
      .toList();
}

/// One line item inside an item-wise split entry.
class HHSplitBillItem {
  final int kotItemId;
  final int dishId;
  final int qty;
  final num price;
  final num lineTotal;

  const HHSplitBillItem({
    required this.kotItemId,
    required this.dishId,
    required this.qty,
    required this.price,
    required this.lineTotal,
  });

  factory HHSplitBillItem.fromJson(Map<String, dynamic> json) {
    return HHSplitBillItem(
      kotItemId: HHSplitBillResultModel._toInt(json['kot_item_id']),
      dishId: HHSplitBillResultModel._toInt(json['dish_id']),
      qty: HHSplitBillResultModel._toInt(json['qty']),
      price: HHSplitBillResultModel._toNum(json['price']),
      lineTotal: HHSplitBillResultModel._toNum(json['line_total']),
    );
  }

  static List<HHSplitBillItem> listFromJson(List<dynamic> raw) => raw
      .whereType<Map<String, dynamic>>()
      .map(HHSplitBillItem.fromJson)
      .toList();
}
