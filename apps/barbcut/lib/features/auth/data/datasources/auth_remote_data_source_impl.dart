import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

import '../../domain/entities/auth_user.dart';

import 'auth_remote_data_source.dart';

/// Firebase Auth implementation of [AuthRemoteDataSource].
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({FirebaseAuth? firebaseAuth})
      : _auth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  static AuthUser? _userFromFirebase(User? user) {
    if (user == null) return null;
    return AuthUser(id: user.uid, email: user.email);
  }

  @override
  Stream<AuthUser?> get authStateChanges =>
      _auth.authStateChanges().map(_userFromFirebase);

  @override
  AuthUser? get currentUser => _userFromFirebase(_auth.currentUser);

  @override
  Future<AuthUser?> signIn(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _userFromFirebase(result.user);
  }

  @override
  Future<AuthUser?> signUp(String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _userFromFirebase(result.user);
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<void> ensureAuthenticated() async {
    try {
      final current = _auth.currentUser;
      if (current == null) {
        developer.log(
          '📝 No user signed in. Signing in anonymously to enable image access...',
          name: 'AuthRemoteDataSource',
        );
        await _auth.signInAnonymously();
        developer.log(
          '✓ Anonymous sign-in successful (UID: ${_auth.currentUser?.uid})',
          name: 'AuthRemoteDataSource',
        );
      } else {
        developer.log(
          '✓ User authenticated: ${current.uid}',
          name: 'AuthRemoteDataSource',
        );
      }
    } catch (e) {
      developer.log(
        '⚠ Error ensuring authentication: $e (images may not load)',
        name: 'AuthRemoteDataSource',
        error: e,
        level: 900,
      );
    }
  }
}
