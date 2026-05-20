import 'package:hookahhabibi/Enums/HHOrderStatus.dart';

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
}
