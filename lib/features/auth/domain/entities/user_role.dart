enum UserRole {
  barber,
  customer,
  owner;

  String toStringValue() => name;

  static UserRole fromString(String value) {
    final normalized = value.trim().toLowerCase();
    return switch (normalized) {
      'barber' => UserRole.barber,
      'customer' => UserRole.customer,
      'owner' => UserRole.owner,
      _ => throw FormatException('Unknown UserRole: "$value"'),
    };
  }
}
