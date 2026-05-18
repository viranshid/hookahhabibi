/// A meal a staff member has added to the current KOT order.
///
/// `unitPrice` is the per-unit price; the row's total is `unitPrice * quantity`.
class HHSelectedMealItem {
  final String id;
  final String title;
  final double unitPrice;
  final int quantity;
  final String? imageUrl;
  final String? subtitle;
  final String? notes;

  const HHSelectedMealItem({
    required this.id,
    required this.title,
    required this.unitPrice,
    this.quantity = 1,
    this.imageUrl,
    this.subtitle,
    this.notes,
  });

  double get totalPrice => unitPrice * quantity;

  HHSelectedMealItem copyWith({
    int? quantity,
    String? imageUrl,
    String? subtitle,
    String? notes,
  }) {
    return HHSelectedMealItem(
      id: id,
      title: title,
      unitPrice: unitPrice,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      subtitle: subtitle ?? this.subtitle,
      notes: notes ?? this.notes,
    );
  }

  /// Parse a price string into a double. Handles common locale formats:
  ///   "130000"          → 130000
  ///   "130000.50"       → 130000.50   (US decimal)
  ///   "130,000"         → 130000      (US thousands)
  ///   "130,000.50"      → 130000.50   (US thousands + decimal)
  ///   "130.000"         → 130000      (Indonesian/EU thousands — IDR)
  ///   "130.000,50"      → 130000.50   (EU thousands + decimal)
  ///   "RP. 130.000"     → 130000      (currency prefix stripped)
  /// Returns 0 if no number can be extracted.
  static double parsePrice(String raw) {
    // Keep only digits, dot, comma.
    final stripped = raw.replaceAll(RegExp(r'[^0-9.,]'), '');
    if (stripped.isEmpty) return 0;

    final hasDot = stripped.contains('.');
    final hasComma = stripped.contains(',');

    String normalized;
    if (hasDot && hasComma) {
      // The last-occurring separator is the decimal point.
      final lastDot = stripped.lastIndexOf('.');
      final lastComma = stripped.lastIndexOf(',');
      if (lastComma > lastDot) {
        normalized = stripped.replaceAll('.', '').replaceAll(',', '.');
      } else {
        normalized = stripped.replaceAll(',', '');
      }
    } else if (hasComma) {
      final parts = stripped.split(',');
      // Trailing group of exactly 3 digits → thousands separator.
      if (parts.length > 1 && parts.last.length == 3) {
        normalized = stripped.replaceAll(',', '');
      } else {
        normalized = stripped.replaceAll(',', '.');
      }
    } else if (hasDot) {
      final parts = stripped.split('.');
      if (parts.length > 1 && parts.last.length == 3) {
        normalized = stripped.replaceAll('.', '');
      } else {
        normalized = stripped;
      }
    } else {
      normalized = stripped;
    }

    return double.tryParse(normalized) ?? 0;
  }
}
