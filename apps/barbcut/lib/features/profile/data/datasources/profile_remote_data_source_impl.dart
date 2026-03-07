import '../../../../services/firebase_data_service.dart';
import 'profile_remote_data_source.dart';

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  @override
  Future<Map<String, dynamic>> getProfile() =>
      FirebaseDataService.fetchProfile();
}
