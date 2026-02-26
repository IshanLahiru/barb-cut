import '../../domain/entities/auth_user.dart';

/// Remote data source for auth (Firebase Auth).
/// Implementations use Firebase; this abstraction allows testing and clean architecture.
abstract class AuthRemoteDataSource {
  Stream<AuthUser?> get authStateChanges;
  AuthUser? get currentUser;
  Future<AuthUser?> signIn(String email, String password);
  Future<AuthUser?> signUp(String email, String password);
  Future<void> signOut();
  Future<void> ensureAuthenticated();
}
