import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.userId,
    required super.username,
    required super.email,
    required super.bio,
    required super.appointmentsCount,
    required super.favoritesCount,
    required super.averageRating,
    super.hairType,
    super.faceShape,
    super.preferredLength,
    super.hasBeard,
    super.beardStyle,
    super.lifestyle,
    super.photoPaths,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    final photoPathsRaw = map['photoPaths'];
    final photoPaths = photoPathsRaw is List
        ? photoPathsRaw.map((value) => value.toString()).toList()
        : const <String>[];
    final username =
        map['username'] as String? ?? map['name'] as String? ?? 'User';
    final appointmentsCount = (map['appointmentsCount'] as num?)?.toInt() ?? 0;
    final favoritesCount = (map['favoritesCount'] as num?)?.toInt() ?? 0;
    final averageRating = (map['averageRating'] as num?)?.toDouble() ?? 0.0;

    return ProfileModel(
      userId: map['userId'] as String? ?? 'user_123',
      username: username,
      email: map['email'] as String? ?? '',
      bio: map['bio'] as String? ?? '',
      appointmentsCount: appointmentsCount,
      favoritesCount: favoritesCount,
      averageRating: averageRating,
      hairType: map['hairType'] as String? ?? 'Straight',
      faceShape: map['faceShape'] as String? ?? 'Oval',
      preferredLength: map['preferredLength'] as String? ?? 'Medium',
      hasBeard: map['hasBeard'] as bool? ?? false,
      beardStyle: map['beardStyle'] as String? ?? 'None',
      lifestyle: map['lifestyle'] as String? ?? 'Active',
      photoPaths: photoPaths,
    );
  }
}
