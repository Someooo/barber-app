import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user_role.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> authenticateWithPhone({
    required String fullName,
    required String phoneNumber,
    required String password,
    required UserRole selectedRole,
  });

  Future<UserModel?> getCurrentUserSession();

  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth;

  final FirebaseAuth? _firebaseAuth;

  FirebaseAuth get _auth => _firebaseAuth ?? FirebaseAuth.instance;

  static const String emailDomain = UserModel.internalEmailDomain;

  static String sanitizePhoneNumber(String phoneNumber) {
    return phoneNumber.trim().replaceAll(RegExp(r'[^\d+]'), '');
  }

  static String phoneToEmail(String phoneNumber) {
    final sanitized = sanitizePhoneNumber(phoneNumber);
    if (sanitized.isEmpty) {
      throw const FormatException('Phone number cannot be empty.');
    }
    return '$sanitized@$emailDomain';
  }

  @override
  Future<UserModel> authenticateWithPhone({
    required String fullName,
    required String phoneNumber,
    required String password,
    required UserRole selectedRole,
  }) async {
    final sanitizedPhone = sanitizePhoneNumber(phoneNumber);
    final email = phoneToEmail(phoneNumber);
    final trimmedName = fullName.trim();

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException(
          message: 'Authentication failed: no Firebase user returned.',
          code: 'null-user',
        );
      }

      final parsed = UserModel.parseDisplayName(user.displayName);
      if (parsed.role == null || parsed.role != selectedRole) {
        await _auth.signOut();
        throw RoleMismatchException(
          expectedRole: selectedRole.toStringValue(),
          actualRole: parsed.role?.toStringValue() ?? 'unknown',
        );
      }

      return UserModel.fromFirebaseUser(
        user,
        fallbackFullName: trimmedName,
        fallbackRole: selectedRole,
        fallbackPhoneNumber: sanitizedPhone,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        return _registerNewUser(
          email: email,
          sanitizedPhone: sanitizedPhone,
          fullName: trimmedName,
          password: password,
          selectedRole: selectedRole,
        );
      }
      rethrow;
    }
  }

  Future<UserModel> _registerNewUser({
    required String email,
    required String sanitizedPhone,
    required String fullName,
    required String password,
    required UserRole selectedRole,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final newUser = credential.user;
      if (newUser == null) {
        throw const AuthException(
          message: 'Account creation failed: no Firebase user returned.',
          code: 'null-user',
        );
      }

      final encodedProfile = UserModel.encodeDisplayName(
        fullName: fullName,
        role: selectedRole,
      );
      await newUser.updateDisplayName(encodedProfile);

      return UserModel.fromFirebaseUser(
        newUser,
        fallbackFullName: fullName,
        fallbackRole: selectedRole,
        fallbackPhoneNumber: sanitizedPhone,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw FirebaseAuthException(
          code: 'wrong-password',
          message: 'Invalid password for existing account.',
        );
      }
      rethrow;
    }
  }

  @override
  Future<UserModel?> getCurrentUserSession() async {
    final User? user;
    try {
      user = _auth.currentUser;
    } catch (_) {
      return null;
    }
    if (user == null) {
      return null;
    }

    try {
      final idToken = await user.getIdToken(false);
      if (idToken == null || idToken.isEmpty) {
        await _auth.signOut();
        return null;
      }

      return UserModel.fromFirebaseUser(user);
    } on FirebaseAuthException {
      await _auth.signOut();
      return null;
    } on FormatException {
      await _auth.signOut();
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
