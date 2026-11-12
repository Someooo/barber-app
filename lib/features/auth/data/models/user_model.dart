import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.fullName,
    required super.phoneNumber,
    required super.role,
  });

  static const String internalEmailDomain = 'barbersync.app';
  static const String _emailSuffix = '@$internalEmailDomain';

  static String encodeDisplayName({
    required String fullName,
    required UserRole role,
  }) {
    return '${fullName.trim()}|${role.toStringValue()}';
  }

  static ({String fullName, UserRole? role}) parseDisplayName(
    String? displayName,
  ) {
    final raw = displayName?.trim() ?? '';
    if (raw.isEmpty) {
      return (fullName: '', role: null);
    }

    final separatorIndex = raw.lastIndexOf('|');
    if (separatorIndex == -1) {
      return (fullName: raw, role: null);
    }

    final namePart = raw.substring(0, separatorIndex).trim();
    final rolePart = raw.substring(separatorIndex + 1).trim();

    UserRole? parsedRole;
    if (rolePart.isNotEmpty) {
      try {
        parsedRole = UserRole.fromString(rolePart);
      } on FormatException {
        parsedRole = null;
      }
    }

    return (fullName: namePart, role: parsedRole);
  }

  factory UserModel.fromFirebaseUser(
    User user, {
    String? fallbackFullName,
    UserRole? fallbackRole,
    String? fallbackPhoneNumber,
  }) {
    final parsed = parseDisplayName(user.displayName);
    final resolvedName = parsed.fullName.isNotEmpty
        ? parsed.fullName
        : (fallbackFullName?.trim() ?? '');
    final resolvedRole = parsed.role ?? fallbackRole;

    if (resolvedRole == null) {
      throw const FormatException(
        'Authenticated Firebase user does not have a valid role in displayName.',
      );
    }

    final email = user.email?.trim() ?? '';
    String resolvedPhone = fallbackPhoneNumber?.trim() ?? '';
    if (email.toLowerCase().endsWith(_emailSuffix)) {
      resolvedPhone = email.substring(0, email.length - _emailSuffix.length);
    } else if (resolvedPhone.isEmpty &&
        (user.phoneNumber?.trim().isNotEmpty ?? false)) {
      resolvedPhone = user.phoneNumber!.trim();
    }

    return UserModel(
      uid: user.uid,
      fullName: resolvedName,
      phoneNumber: resolvedPhone,
      role: resolvedRole,
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      fullName: entity.fullName,
      phoneNumber: entity.phoneNumber,
      role: entity.role,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      fullName: map['fullName'] as String,
      phoneNumber: map['phoneNumber'] as String,
      role: UserRole.fromString(map['role'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'role': role.toStringValue(),
    };
  }
}
