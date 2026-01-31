import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileEntity>> getProfile();
  Future<Either<Failure, void>> updateProfile(ProfileEntity profile);
}
