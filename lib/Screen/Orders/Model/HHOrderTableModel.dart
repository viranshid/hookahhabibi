/// Minimal table info nested inside order payloads.
class HHOrderTableModel {
  final int id;
  final String tableNumber;
  final int capacity;
  final String status;
  final int? areaId;

  const HHOrderTableModel({
    required this.id,
    required this.tableNumber,
    required this.capacity,
    required this.status,
    this.areaId,
  });

  factory HHOrderTableModel.fromJson(Map<String, dynamic> json) {
    return HHOrderTableModel(
      id: _toInt(json['id']),
      tableNumber: (json['table_number'] ?? '').toString(),
      capacity: _toInt(json['capacity']),
      status: (json['status'] ?? '').toString(),
      areaId: json['area_id'] == null ? null : _toInt(json['area_id']),
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}

/// Minimal location info nested inside order payloads.
class HHOrderLocationModel {
  final int id;
  final String name;

  const HHOrderLocationModel({required this.id, required this.name});

  factory HHOrderLocationModel.fromJson(Map<String, dynamic> json) {
    return HHOrderLocationModel(
      id: HHOrderTableModel._toInt(json['id']),
      name: (json['name'] ?? '').toString(),
    );
  }
}
