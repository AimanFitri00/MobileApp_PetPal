part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileRequested extends ProfileEvent {
  const ProfileRequested(this.uid);

  final String uid;

  @override
  List<Object?> get props => [uid];
}

class ProfileUpdated extends ProfileEvent {
  const ProfileUpdated(this.user);

  final AppUser user;

  @override
  List<Object?> get props => [user];
}

class ProfileImageUploaded extends ProfileEvent {
  const ProfileImageUploaded(this.file);

  final File file;

  @override
  List<Object?> get props => [file];
}
