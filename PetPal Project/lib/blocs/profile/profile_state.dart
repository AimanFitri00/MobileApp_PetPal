part of 'profile_bloc.dart';

class ProfileState extends Equatable {
  const ProfileState({required this.isLoading, this.user, this.errorMessage});

  const ProfileState.initial() : this(isLoading: false);

  final bool isLoading;
  final AppUser? user;
  final String? errorMessage;

  ProfileState copyWith({
    bool? isLoading,
    AppUser? user,
    String? errorMessage,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, user, errorMessage];
}
