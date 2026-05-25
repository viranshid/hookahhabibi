import 'package:hookahhabibi/Enums/HHOrderStatus.dart';
import 'package:hookahhabibi/Screen/Orders/Model/HHOrderModel.dart' as api;

class HHOrderItem {
  final String name;
  final int qty;

  const HHOrderItem({required this.name, required this.qty});
}

class HHKotEntry {
  final int kotNumber;
  final String time;
  final List<HHOrderItem> items;

  const HHKotEntry({
    required this.kotNumber,
    required this.time,
    required this.items,
  });
}

class HHOrderModel {
  final String id;
  final String customerName;
  final String tableNumber;
  final int viewCount;
  final List<HHKotEntry> kotEntries;
  final HHOrderStatus status;

  const HHOrderModel({
    required this.id,
    required this.customerName,
    required this.tableNumber,
    required this.viewCount,
    required this.kotEntries,
    required this.status,
  });

  bool get isTerminal => status.isTerminal;

  /// Adapts the API-aligned order to the card-friendly UI model.
  /// Orders with no KOTs get a single empty placeholder entry so the card
  /// renders its header + footer without crashing on `.first`.
  factory HHOrderModel.fromApi(api.HHOrderModel src) {
    final entries = src.kots
        .map(
          (k) => HHKotEntry(
            kotNumber: k.id,
            time: _hhmm(k.startedAt ?? k.createdAt),
            items: k.items
                .map((it) => HHOrderItem(
                      name: it.dishTitle.isNotEmpty ? it.dishTitle : it.dishName,
                      qty: it.quantity,
                    ))
                .toList(),
          ),
        )
        .toList();

    if (entries.isEmpty) {
      entries.add(HHKotEntry(
        kotNumber: 0,
        time: _hhmm(src.createdAt),
        items: const [],
      ));
    }

    return HHOrderModel(
      id: src.id.toString(),
      customerName: src.customer?.name ?? '—',
      tableNumber: src.table?.tableNumber ?? '—',
      viewCount: 0,
      kotEntries: entries,
      status: _mapStatus(src),
    );
  }

  static HHOrderStatus _mapStatus(api.HHOrderModel src) {
    if (src.cancelledAt != null) return HHOrderStatus.cancelled;
    if (src.completedAt != null) return HHOrderStatus.completed;
    switch (src.orderStatus.toLowerCase()) {
      case 'p':
        return HHOrderStatus.pending;
      case 'a':
        return HHOrderStatus.accepted;
      case 'i':
      case 'ip':
        return HHOrderStatus.inPreparation;
      case 's':
      case 'r':
        return HHOrderStatus.readyServed;
      case 'co':
        return HHOrderStatus.completed;
      case 'c':
        return HHOrderStatus.cancelled;
      default:
        return HHOrderStatus.pending;
    }
  }

  /// Extract "HH:MM" from "YYYY-MM-DD HH:MM:SS"; falls back to "--:--".
  static String _hhmm(String? raw) {
    if (raw == null || raw.isEmpty) return '--:--';
    final parts = raw.split(' ');
    final timePart = parts.length > 1 ? parts[1] : parts[0];
    final hms = timePart.split(':');
    if (hms.length >= 2) return '${hms[0]}:${hms[1]}';
    return '--:--';
  }
}
