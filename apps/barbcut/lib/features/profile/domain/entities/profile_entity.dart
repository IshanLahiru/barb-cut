class ProfileEntity {
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
  });
}
