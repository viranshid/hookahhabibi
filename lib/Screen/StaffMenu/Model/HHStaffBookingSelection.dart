/// Snapshot of what the staff picked on the Tables tab — used to render
/// the KOT-panel header on the Menu tab and to drive `save-order-with-kot`
/// when Save / KOT&Print / Send to Kitchen is pressed.
///
/// Two flavours of fields:
///  * **Display** (`*Label`) — formatted strings for the right-bar UI.
///  * **Actionable** (`*Id`, list of ids, etc.) — primitives passed to the
///    API service.
///
/// Once an order is created via `/api/save-order-with-kot`, the returned
/// `HHOrderModel` becomes the source of truth instead of this snapshot.
class HHStaffBookingSelection {
  // ----- Display (KOT panel header) -----
  final String customerName;
  final String tableLabel;
  final String floorLabel;

  // ----- Actionable (place-order API) -----
  /// Raw phone (no country code prefix). Used in the walk-in path when
  /// [customerId] is null.
  final String customerPhone;

  /// Existing customer id (selected via the autocomplete). Null = walk-in
  /// — the place-order call will fall back to `customerName` + `customerPhone`.
  final int? customerId;

  /// Server table ids the staff selected. `/api/save-order-with-kot`
  /// currently accepts a single `table_id`; we'll send `tableIds.first`
  /// and treat the rest as future-work / linked tables.
  final List<int> tableIds;

  /// Location id from the active session, captured at Continue time so it
  /// can't drift if the user changes location mid-flow.
  final int? locationId;

  /// Guest count. UI doesn't expose a stepper yet (PENDING_UI_WORK #2);
  /// defaults to 1.
  final int guestCount;

  const HHStaffBookingSelection({
    required this.customerName,
    required this.tableLabel,
    required this.floorLabel,
    this.customerPhone = '',
    this.customerId,
    this.tableIds = const [],
    this.locationId,
    this.guestCount = 1,
  });

  static const HHStaffBookingSelection empty = HHStaffBookingSelection(
    customerName: '—',
    tableLabel: '—',
    floorLabel: '—',
  );

  /// True iff we have the minimum info to call `/api/save-order-with-kot`:
  /// a table to book against, a location, and either a customer id or
  /// name+phone.
  bool get canPlaceOrder {
    final hasTable = tableIds.isNotEmpty;
    final hasLocation = locationId != null;
    final hasCustomer = customerId != null ||
        (customerName.trim().isNotEmpty &&
            customerName != '—' &&
            customerPhone.trim().isNotEmpty);
    return hasTable && hasLocation && hasCustomer;
  }

  HHStaffBookingSelection copyWith({
    String? customerName,
    String? tableLabel,
    String? floorLabel,
    String? customerPhone,
    int? customerId,
    List<int>? tableIds,
    int? locationId,
    int? guestCount,
  }) {
    return HHStaffBookingSelection(
      customerName: customerName ?? this.customerName,
      tableLabel: tableLabel ?? this.tableLabel,
      floorLabel: floorLabel ?? this.floorLabel,
      customerPhone: customerPhone ?? this.customerPhone,
      customerId: customerId ?? this.customerId,
      tableIds: tableIds ?? this.tableIds,
      locationId: locationId ?? this.locationId,
      guestCount: guestCount ?? this.guestCount,
    );
  }
}
