import '../../domain/entities/profile_entity.dart';
import '../models/profile_model.dart';

class ProfileLocalDataSource {
  ProfileEntity getProfile() {
    final profileData = _getProfileData();
    return ProfileModel.fromMap(profileData);
  }

  static Map<String, dynamic> _getProfileData() {
    return {
      'userId': 'user_123',
      'username': 'alexporter',
      'email': 'alex@example.com',
      'bio': 'Barber enthusiast & AI style explorer',
      'appointmentsCount': 24,
      'favoritesCount': 12,
      'averageRating': 4.8,
    };
  }
}
