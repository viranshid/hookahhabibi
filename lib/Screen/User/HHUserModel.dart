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
  final String? createdBy;
  final String? updatedBy;
  final String? deletedBy;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final String? lockScreenPin;

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
    this.createdBy,
    this.updatedBy,
    this.deletedBy,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.lockScreenPin,
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
      createdBy: json['created_by']?.toString(),
      updatedBy: json['updated_by']?.toString(),
      deletedBy: json['deleted_by']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      deletedAt: json['deleted_at']?.toString(),
      lockScreenPin: json['lock_screen_pin']?.toString(),
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
      'created_by': createdBy,
      'updated_by': updatedBy,
      'deleted_by': deletedBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'lock_screen_pin': lockScreenPin,
    };
  }

  /// Get full name
  String get fullName => '$name $lastName'.trim();

  /// Check if user is active
  bool get isActive => status == 'a';

  /// Check if user has profile image
  bool get hasProfileImage => profileImage != null && profileImage!.isNotEmpty;

  /// Check if user has mobile number
  bool get hasMobileNumber => mobileNumber != null && mobileNumber!.isNotEmpty;

  /// Get formatted mobile number with dial code
  String? get formattedMobileNumber {
    if (!hasMobileNumber) return null;
    return '${mobileDial ?? ''}${mobileNumber ?? ''}'.trim();
  }

  /// Check if email is verified
  bool get isEmailVerified => emailVerifiedAt != null;

  /// Check if user has lock screen pin
  bool get hasLockScreenPin => lockScreenPin != null && lockScreenPin!.isNotEmpty;

  /// Check if user is deleted (soft delete)
  bool get isDeleted => deletedAt != null;

  /// Get user initials for avatar
  String get initials {
    String firstInitial = name.isNotEmpty ? name[0].toUpperCase() : '';
    String lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }

  /// Copy with method for creating modified copies
  HHUserModel copyWith({
    String? id,
    String? userType,
    String? name,
    String? lastName,
    String? mobileDial,
    String? mobileNumber,
    String? loginName,
    String? profileImage,
    String? email,
    String? emailVerifiedAt,
    String? status,
    String? timezone,
    String? lastSeenAt,
    String? createdBy,
    String? updatedBy,
    String? deletedBy,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
    String? lockScreenPin,
  }) {
    return HHUserModel(
      id: id ?? this.id,
      userType: userType ?? this.userType,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      mobileDial: mobileDial ?? this.mobileDial,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      loginName: loginName ?? this.loginName,
      profileImage: profileImage ?? this.profileImage,
      email: email ?? this.email,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      status: status ?? this.status,
      timezone: timezone ?? this.timezone,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      deletedBy: deletedBy ?? this.deletedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      lockScreenPin: lockScreenPin ?? this.lockScreenPin,
    );
  }

  @override
  String toString() {
    return 'HHUserModel(id: $id, name: $fullName, email: $email, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HHUserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
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

  Map<String, dynamic> toJson() {
    return {
      'bearer_token': bearerToken,
      'msg': message,
    };
  }

  @override
  String toString() {
    return 'LoginResponse(bearerToken: ${bearerToken.isNotEmpty ? "***" : "empty"}, message: $message)';
  }
}