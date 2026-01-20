part of 'profile_bloc.dart';

class ProfileState extends Equatable {
  const ProfileState({required this.isLoading, this.user, this.errorMessage, this.localProfileImagePath});

  const ProfileState.initial() : this(isLoading: false);

  final bool isLoading;
  final AppUser? user;
  final String? errorMessage;
  final String? localProfileImagePath;

  ProfileState copyWith({
    bool? isLoading,
    AppUser? user,
    String? errorMessage,
    String? localProfileImagePath,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: errorMessage,
      localProfileImagePath: localProfileImagePath ?? this.localProfileImagePath,
    );
  }

  @override
  List<Object?> get props => [isLoading, user, errorMessage, localProfileImagePath];
}
