class ProfileEntity {
  final String userId;
  final String username;
  final String email;
  final String bio;
  final int appointmentsCount;
  final int favoritesCount;
  final double averageRating;

  const ProfileEntity({
    required this.userId,
    required this.username,
    required this.email,
    required this.bio,
    required this.appointmentsCount,
    required this.favoritesCount,
    required this.averageRating,
  });
}
