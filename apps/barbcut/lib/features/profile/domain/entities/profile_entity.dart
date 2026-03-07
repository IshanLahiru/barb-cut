import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String userId;
  final String username;
  final String email;
  final String bio;
  final int appointmentsCount;
  final int favoritesCount;
  final double averageRating;
  final String hairType;
  final String faceShape;
  final String preferredLength;
  final bool hasBeard;
  final String beardStyle;
  final String lifestyle;
  final List<String> photoPaths;

  /// Profile avatar URL (Firebase Storage gs:// or download URL).
  final String profilePhotoUrl;

  /// Credits/points for AI generations (read-only from Firestore users doc).
  final int points;

  const ProfileEntity({
    required this.userId,
    required this.username,
    required this.email,
    required this.bio,
    required this.appointmentsCount,
    required this.favoritesCount,
    required this.averageRating,
    this.hairType = 'Straight',
    this.faceShape = 'Oval',
    this.preferredLength = 'Medium',
    this.hasBeard = false,
    this.beardStyle = 'None',
    this.lifestyle = 'Active',
    this.photoPaths = const [],
    this.profilePhotoUrl = '',
    this.points = 0,
  });

  @override
  List<Object?> get props => [
    userId,
    username,
    email,
    bio,
    appointmentsCount,
    favoritesCount,
    averageRating,
    hairType,
    faceShape,
    preferredLength,
    hasBeard,
    beardStyle,
    lifestyle,
    photoPaths,
    profilePhotoUrl,
    points,
  ];
}
