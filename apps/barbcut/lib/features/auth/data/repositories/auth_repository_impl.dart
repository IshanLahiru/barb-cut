import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
      : _remote = remoteDataSource;

  final AuthRemoteDataSource _remote;

  @override
  Stream<AuthUser?> get authStateChanges => _remote.authStateChanges;

  @override
  AuthUser? get currentUser => _remote.currentUser;

  @override
  Future<AuthUser?> signIn(String email, String password) async {
    try {
      return await _remote.signIn(email, password);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? e.code);
    }
  }

  @override
  Future<AuthUser?> signUp(String email, String password) async {
    try {
      return await _remote.signUp(email, password);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? e.code);
    }
  }

  @override
  Future<void> signOut() async {
    await _remote.signOut();
  }

  @override
  Future<void> ensureAuthenticated() async {
    await _remote.ensureAuthenticated();
  }
}
