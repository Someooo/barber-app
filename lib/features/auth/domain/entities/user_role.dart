enum UserRole {
  barber,
  customer;

  String toStringValue() => name;

  static UserRole fromString(String value) {
    final normalized = value.trim().toLowerCase();
    return switch (normalized) {
      'barber' => UserRole.barber,
      'customer' => UserRole.customer,
      _ => throw FormatException('Unknown UserRole: "$value"'),
    };
  }
}
