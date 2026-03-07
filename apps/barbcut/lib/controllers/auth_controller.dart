import 'package:flutter/material.dart';
import '../features/auth/domain/repositories/auth_repository.dart';

class AuthController with ChangeNotifier {
  final AuthRepository _authRepository;
  bool isLoading = false;
  String? error;

  AuthController(this._authRepository);

  Future<bool> login(String email, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _authRepository.signIn(email, password);
      return true;
    } on AuthException catch (e) {
      error = e.message;
      return false;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String email, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _authRepository.signUp(email, password);
      return true;
    } on AuthException catch (e) {
      error = e.message;
      return false;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authRepository.signOut();
  }
}
