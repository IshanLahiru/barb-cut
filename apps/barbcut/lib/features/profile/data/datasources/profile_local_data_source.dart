import '../../domain/entities/profile_entity.dart';
import '../models/profile_model.dart';
import '../../../../core/constants/app_data.dart';

class ProfileLocalDataSource {
  ProfileEntity getProfile() {
    return ProfileModel.fromMap(AppData.defaultProfile);
  }
}
