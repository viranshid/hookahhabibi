enum HHUserType {
  customer('customer'),
  staff('staff'),
  manager('manager');

  final String value;
  const HHUserType(this.value);

  static HHUserType fromString(String value) {
    return HHUserType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => HHUserType.customer,
    );
  }
}
