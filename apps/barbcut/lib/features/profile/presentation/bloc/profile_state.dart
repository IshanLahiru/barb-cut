import 'package:equatable/equatable.dart';
import '../../domain/entities/profile_entity.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;

  const ProfileLoaded({required this.profile});

  @override
  List<Object> get props => [profile];
}

class ProfileFailure extends ProfileState {
  final String message;

  const ProfileFailure({required this.message});

  @override
  List<Object> get props => [message];
}
