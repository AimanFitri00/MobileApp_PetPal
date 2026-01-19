import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/app_user.dart';
import '../../repositories/user_repository.dart';
import '../../services/storage_service.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required UserRepository userRepository,
    required StorageService storageService,
  }) : _userRepository = userRepository,
       _storageService = storageService,
       super(const ProfileState.initial()) {
    on<ProfileRequested>(_onRequested);
    on<ProfileUpdated>(_onUpdated);
    on<ProfileImageUploaded>(_onImageUploaded);
    on<ProfileLocalImageSet>(_onLocalImageSet);
  }

  final UserRepository _userRepository;
  final StorageService _storageService;

  Future<void> _onRequested(
    ProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final user = await _userRepository.fetchUser(event.uid);
      // load saved local profile image path for this user (if any)
      final prefs = await SharedPreferences.getInstance();
      final userKey = 'local_profile_image_${event.uid}';
      final localPath = prefs.getString(userKey);
      emit(state.copyWith(isLoading: false, user: user, localProfileImagePath: localPath));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }

  Future<void> _onUpdated(
    ProfileUpdated event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _userRepository.updateUser(event.user);
      emit(state.copyWith(isLoading: false, user: event.user));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }

  Future<void> _onImageUploaded(
    ProfileImageUploaded event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.user == null) return;
    emit(state.copyWith(isLoading: true));
    try {
      final path = 'profiles/${state.user!.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final url = await _storageService.uploadFile(
        file: event.file,
        path: path,
      );
      final updated = state.user!.copyWith(profileImageUrl: url);
      await _userRepository.updateUser(updated);
      emit(state.copyWith(isLoading: false, user: updated));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }

  Future<void> _onLocalImageSet(
    ProfileLocalImageSet event,
    Emitter<ProfileState> emit,
  ) async {
    // persist selection locally under the provided UID so other screens can read it
    final prefs = await SharedPreferences.getInstance();
    final key = 'local_profile_image_${event.uid}';
    await prefs.setString(key, event.path);
    emit(state.copyWith(localProfileImagePath: event.path));
  }
}
