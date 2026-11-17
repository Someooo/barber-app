import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  AuthRemoteDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    SharedPreferences? prefs,
  })  : _firebaseAuth = firebaseAuth,
        _prefs = prefs;

  final FirebaseAuth? _firebaseAuth;
  final SharedPreferences? _prefs;
  bool _localOwnerActive = false;

  FirebaseAuth get _auth => _firebaseAuth ?? FirebaseAuth.instance;

  static const String emailDomain = UserModel.internalEmailDomain;
  static const String officialOwnerUid = 'owner_sami_almuhur';
  static const String officialOwnerName = 'سامي المهر';
  static const String officialOwnerPhone = '0799081839';
  static const String officialOwnerPassword = r'12345678';
  static const String officialOwnerSessionKey = 'barbersync_owner_session';

  static String sanitizePhoneNumber(String phoneNumber) {
    return phoneNumber.trim().replaceAll(RegExp(r'[^\d+]'), '');
  }

  static String normalizeJordanPhone(String phoneNumber) {
    final sanitized = sanitizePhoneNumber(phoneNumber);
    if (sanitized.startsWith('+962') && sanitized.length > 4) {
      return '0${sanitized.substring(4)}';
    }
    if (sanitized.startsWith('962') && sanitized.length == 12) {
      return '0${sanitized.substring(3)}';
    }
    return sanitized;
  }

  static bool isOfficialOwnerPhone(String phoneNumber) {
    return normalizeJordanPhone(phoneNumber) == officialOwnerPhone;
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
    final normalizedPhone = normalizeJordanPhone(phoneNumber);
    final trimmedName = fullName.trim();

    if (isOfficialOwnerPhone(normalizedPhone)) {
      if (password != officialOwnerPassword) {
        throw FirebaseAuthException(
          code: 'wrong-password',
          message: 'Invalid password for Shop Owner account.',
        );
      }
      if (selectedRole == UserRole.customer) {
        throw RoleMismatchException(
          expectedRole: selectedRole.toStringValue(),
          actualRole: UserRole.owner.toStringValue(),
        );
      }
      _localOwnerActive = true;
      await _prefs?.setBool(officialOwnerSessionKey, true);
      return const UserModel(
        uid: officialOwnerUid,
        fullName: officialOwnerName,
        phoneNumber: officialOwnerPhone,
        role: UserRole.owner,
      );
    }

    if (selectedRole == UserRole.owner) {
      throw RoleMismatchException(
        expectedRole: UserRole.owner.toStringValue(),
        actualRole: UserRole.customer.toStringValue(),
      );
    }

    final email = phoneToEmail(phoneNumber);

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
    if (_localOwnerActive ||
        (_prefs?.getBool(officialOwnerSessionKey) ?? false)) {
      return const UserModel(
        uid: officialOwnerUid,
        fullName: officialOwnerName,
        phoneNumber: officialOwnerPhone,
        role: UserRole.owner,
      );
    }

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
    _localOwnerActive = false;
    await _prefs?.remove(officialOwnerSessionKey);
    try {
      await _auth.signOut();
    } catch (_) {}
  }
}
