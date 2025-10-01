/// User Model
class HHUserModel {
  final String id;
  final String userType;
  final String name;
  final String lastName;
  final String? mobileDial;
  final String? mobileNumber;
  final String loginName;
  final String? profileImage;
  final String email;
  final String? emailVerifiedAt;
  final String status;
  final String timezone;
  final String? lastSeenAt;
  final String? createdAt;
  final String? updatedAt;

  HHUserModel({
    required this.id,
    required this.userType,
    required this.name,
    required this.lastName,
    this.mobileDial,
    this.mobileNumber,
    required this.loginName,
    this.profileImage,
    required this.email,
    this.emailVerifiedAt,
    required this.status,
    required this.timezone,
    this.lastSeenAt,
    this.createdAt,
    this.updatedAt,
  });

  factory HHUserModel.fromJson(Map<String, dynamic> json) {
    return HHUserModel(
      id: json['id']?.toString() ?? '',
      userType: json['user_type']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      mobileDial: json['mobile_dial']?.toString(),
      mobileNumber: json['mobile_number']?.toString(),
      loginName: json['login_name']?.toString() ?? '',
      profileImage: json['profile_image']?.toString(),
      email: json['email']?.toString() ?? '',
      emailVerifiedAt: json['email_verified_at']?.toString(),
      status: json['status']?.toString() ?? '',
      timezone: json['timezone']?.toString() ?? 'UTC',
      lastSeenAt: json['last_seen_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_type': userType,
      'name': name,
      'last_name': lastName,
      'mobile_dial': mobileDial,
      'mobile_number': mobileNumber,
      'login_name': loginName,
      'profile_image': profileImage,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'status': status,
      'timezone': timezone,
      'last_seen_at': lastSeenAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  String get fullName => '$name $lastName';

  bool get isActive => status == 'a';

  bool get hasProfileImage => profileImage != null && profileImage!.isNotEmpty;

  @override
  String toString() {
    return 'UserModel(id: $id, name: $fullName, email: $email)';
  }
}

/// Login Response Model
class LoginResponse {
  final String bearerToken;
  final String message;

  LoginResponse({
    required this.bearerToken,
    required this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      bearerToken: json['bearer_token']?.toString() ?? '',
      message: json['msg']?.toString() ?? '',
    );
  }
}