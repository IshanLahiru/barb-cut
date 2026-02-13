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
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      userId: map['userId'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      bio: map['bio'] as String,
      appointmentsCount: map['appointmentsCount'] as int,
      favoritesCount: map['favoritesCount'] as int,
      averageRating: map['averageRating'] as double,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'bio': bio,
      'appointmentsCount': appointmentsCount,
      'favoritesCount': favoritesCount,
      'averageRating': averageRating,
    };
  }
}
