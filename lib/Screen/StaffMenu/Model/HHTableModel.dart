import 'package:hookahhabibi/Screen/StaffMenu/Model/HHTableType.dart';

/// One row inside `data[].areas[].tables[]`.
class HHTableModel {
  final int id;
  final String tableNumber;
  final int capacity;
  final HHTableType type;
  final int locationId;
  final int areaId;

  // Booking-time fields (not in current API payload — filled when available).
  final int? minutes;
  final String? customerName;

  // Client-side only.
  final bool isSelected;

  const HHTableModel({
    required this.id,
    required this.tableNumber,
    required this.capacity,
    required this.type,
    required this.locationId,
    required this.areaId,
    this.minutes,
    this.customerName,
    this.isSelected = false,
  });

  factory HHTableModel.fromJson(Map<String, dynamic> json) {
    return HHTableModel(
      id: _asInt(json['id']),
      tableNumber: json['table_number']?.toString() ?? '',
      capacity: _asInt(json['capacity']),
      type: HHTableType.fromApi(json['status']?.toString()),
      locationId: _asInt(json['location_id']),
      areaId: _asInt(json['area_id']),
      minutes: _tryInt(json['minutes']),
      customerName: json['customer_name']?.toString(),
    );
  }

  String get displayTableNumber {
    final parsed = int.tryParse(tableNumber);
    return 'T-${parsed ?? tableNumber}';
  }

  HHTableModel copyWith({bool? isSelected}) {
    return HHTableModel(
      id: id,
      tableNumber: tableNumber,
      capacity: capacity,
      type: type,
      locationId: locationId,
      areaId: areaId,
      minutes: minutes,
      customerName: customerName,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

/// One row inside `data[].areas[]`.
class HHTableAreaModel {
  final int areaId;
  final String areaName;
  final List<HHTableModel> tables;

  const HHTableAreaModel({
    required this.areaId,
    required this.areaName,
    required this.tables,
  });

  factory HHTableAreaModel.fromJson(Map<String, dynamic> json) {
    final list = (json['tables'] as List?) ?? const [];
    return HHTableAreaModel(
      areaId: _asInt(json['area_id']),
      areaName: json['area_name']?.toString() ?? '',
      tables: list
          .whereType<Map<String, dynamic>>()
          .map(HHTableModel.fromJson)
          .toList(),
    );
  }
}

/// One element of the top-level `data` array.
class HHTablesLocationModel {
  final int locationId;
  final String locationName;
  final List<HHTableAreaModel> areas;

  const HHTablesLocationModel({
    required this.locationId,
    required this.locationName,
    required this.areas,
  });

  factory HHTablesLocationModel.fromJson(Map<String, dynamic> json) {
    final list = (json['areas'] as List?) ?? const [];
    return HHTablesLocationModel(
      locationId: _asInt(json['location_id']),
      locationName: json['location_name']?.toString() ?? '',
      areas: list
          .whereType<Map<String, dynamic>>()
          .map(HHTableAreaModel.fromJson)
          .toList(),
    );
  }

  /// Parses the entire `data` array (not the wrapping response envelope).
  static List<HHTablesLocationModel> listFromJson(List<dynamic> data) {
    return data
        .whereType<Map<String, dynamic>>()
        .map(HHTablesLocationModel.fromJson)
        .toList();
  }
}

int _asInt(dynamic v) => _tryInt(v) ?? 0;

int? _tryInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}
