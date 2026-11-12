import 'package:equatable/equatable.dart';

import 'user_role.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.uid,
    required this.fullName,
    required this.phoneNumber,
    required this.role,
  });

  final String uid;
  final String fullName;
  final String phoneNumber;
  final UserRole role;

  @override
  List<Object?> get props => [uid, fullName, phoneNumber, role];
}
