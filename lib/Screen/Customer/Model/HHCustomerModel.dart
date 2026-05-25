/// Customer model — matches /api/get-customers and /api/save-customer payloads.
class HHCustomerModel {
  final int id;
  final String name;
  final String phone;
  final String? notes;
  final int ordersCount;
  final int kotsCount;
  final String? createdAt;
  final String? updatedAt;

  const HHCustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.notes,
    this.ordersCount = 0,
    this.kotsCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory HHCustomerModel.fromJson(Map<String, dynamic> json) {
    return HHCustomerModel(
      id: _toInt(json['id']),
      name: (json['name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      notes: json['notes']?.toString(),
      ordersCount: _toInt(json['orders_count']),
      kotsCount: _toInt(json['kots_count']),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'notes': notes,
        'orders_count': ordersCount,
        'kots_count': kotsCount,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static List<HHCustomerModel> listFromJson(List<dynamic> raw) =>
      raw
          .whereType<Map<String, dynamic>>()
          .map(HHCustomerModel.fromJson)
          .toList();

  @override
  String toString() => 'HHCustomerModel(id: $id, name: $name, phone: $phone)';
}
