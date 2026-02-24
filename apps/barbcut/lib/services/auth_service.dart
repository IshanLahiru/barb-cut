import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Initialize anonymous authentication to allow image access
  /// This is called on app startup to ensure the user can access Firebase Storage
  Future<void> ensureAuthenticated() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        developer.log(
          '📝 No user signed in. Signing in anonymously to enable image access...',
          name: 'AuthService',
        );
        await _auth.signInAnonymously();
        developer.log(
          '✓ Anonymous sign-in successful (UID: ${_auth.currentUser?.uid})',
          name: 'AuthService',
        );
      } else {
        developer.log(
          '✓ User authenticated: ${currentUser.uid}',
          name: 'AuthService',
        );
      }
    } catch (e) {
      developer.log(
        '⚠ Error ensuring authentication: $e (images may not load)',
        name: 'AuthService',
        error: e,
        level: 900,
      );
      // Continue anyway - app can still load external images
    }
  }

  Future<User?> signIn(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  Future<User?> register(String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<User?> get userChanges => _auth.authStateChanges();
  
  User? get currentUser => _auth.currentUser;
}
