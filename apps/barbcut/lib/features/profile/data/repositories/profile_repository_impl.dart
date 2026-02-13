import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ProfileEntity>> getProfile() async {
    try {
      final profile = await remoteDataSource.getProfile();
      return Right(profile);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile(ProfileEntity profile) async {
    try {
      await remoteDataSource.updateProfile(profile);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
