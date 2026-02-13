import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/profile_model.dart';
import '../../domain/entities/profile_entity.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
  Future<void> updateProfile(ProfileEntity profile);
  Future<void> createProfile(ProfileEntity profile);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ProfileRemoteDataSourceImpl({required this.firestore, required this.auth});

  String get _userId {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }

  @override
  Future<ProfileModel> getProfile() async {
    try {
      final doc = await firestore.collection('users').doc(_userId).get();

      if (!doc.exists) {
        // Create default profile if it doesn't exist
        final defaultProfile = ProfileModel(
          userId: _userId,
          username: auth.currentUser?.displayName ?? 'User',
          email: auth.currentUser?.email ?? '',
          bio: '',
          appointmentsCount: 0,
          favoritesCount: 0,
          averageRating: 0.0,
        );
        await createProfile(defaultProfile);
        return defaultProfile;
      }

      return ProfileModel.fromMap({...doc.data()!, 'userId': doc.id});
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  @override
  Future<void> updateProfile(ProfileEntity profile) async {
    try {
      final profileModel = ProfileModel(
        userId: profile.userId,
        username: profile.username,
        email: profile.email,
        bio: profile.bio,
        appointmentsCount: profile.appointmentsCount,
        favoritesCount: profile.favoritesCount,
        averageRating: profile.averageRating,
      );

      await firestore.collection('users').doc(_userId).update({
        ...profileModel.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  @override
  Future<void> createProfile(ProfileEntity profile) async {
    try {
      final profileModel = ProfileModel(
        userId: _userId,
        username: profile.username,
        email: profile.email,
        bio: profile.bio,
        appointmentsCount: profile.appointmentsCount,
        favoritesCount: profile.favoritesCount,
        averageRating: profile.averageRating,
      );

      await firestore.collection('users').doc(_userId).set({
        ...profileModel.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create profile: $e');
    }
  }
}
