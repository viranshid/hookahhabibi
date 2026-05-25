/// Request payload entries for /api/orders/split-bill.
///
/// The `splits` field is a JSON-encoded string of an array of these.
/// Use [HHBillSplitRequest.itemWise] for `split_type = "i"` or
/// [HHBillSplitRequest.percentage] for `split_type = "p"`.
class HHBillSplitRequest {
  /// Display name for this split (e.g. "Customer A", "Ayush").
  /// Splits are not tied to stored customer ids — the server keys by name.
  final String splitName;

  /// Item-wise splits: which KOT items belong to this person and at what
  /// qty/price. Null for percentage splits.
  final List<HHBillSplitItem>? items;

  /// Percentage of the total bill this split owes (0-100). Null for
  /// item-wise splits. Serialized as `percentage` in the request.
  final num? percentage;

  /// Optional note attached to this split.
  final String? notes;

  const HHBillSplitRequest._({
    required this.splitName,
    this.items,
    this.percentage,
    this.notes,
  });

  /// Item-wise split — list the items (and their qty + price) assigned to
  /// this person.
  factory HHBillSplitRequest.itemWise({
    required String splitName,
    required List<HHBillSplitItem> items,
    String? notes,
  }) {
    return HHBillSplitRequest._(
      splitName: splitName,
      items: items,
      notes: notes,
    );
  }

  /// Percentage split — this person owes [percentage]% of the total bill.
  factory HHBillSplitRequest.percentage({
    required String splitName,
    required num percentage,
    String? notes,
  }) {
    return HHBillSplitRequest._(
      splitName: splitName,
      percentage: percentage,
      notes: notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'split_name': splitName,
      if (items != null) 'items': items!.map((e) => e.toJson()).toList(),
      if (percentage != null) 'percentage': percentage,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }
}

/// One line in an item-wise split — which KOT item, how many of it, and
/// at what price.
class HHBillSplitItem {
  final int kotItemId;
  final int qty;
  final num price;

  const HHBillSplitItem({
    required this.kotItemId,
    required this.qty,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
        'kot_item_id': kotItemId,
        'qty': qty,
        'price': price,
      };
}
