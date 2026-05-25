/// Minimal user info nested inside order / KOT payloads.
class HHOrderUserModel {
  final int id;
  final String name;
  final String? lastName;
  final String? fullName;
  final String? email;
  final String? userType;

  const HHOrderUserModel({
    required this.id,
    required this.name,
    this.lastName,
    this.fullName,
    this.email,
    this.userType,
  });

  factory HHOrderUserModel.fromJson(Map<String, dynamic> json) {
    return HHOrderUserModel(
      id: _toInt(json['id']),
      name: (json['name'] ?? '').toString(),
      lastName: json['last_name']?.toString(),
      fullName: json['full_name']?.toString(),
      email: json['email']?.toString(),
      userType: json['user_type']?.toString(),
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}
