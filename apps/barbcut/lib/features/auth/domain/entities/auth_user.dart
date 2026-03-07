import 'package:equatable/equatable.dart';

/// Domain entity for an authenticated user.
/// Used by the auth feature; data layer maps from Firebase User to this.
class AuthUser extends Equatable {
  final String id;
  final String? email;

  const AuthUser({
    required this.id,
    this.email,
  });

  @override
  List<Object?> get props => [id, email];
}
