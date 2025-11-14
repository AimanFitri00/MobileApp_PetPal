import 'package:equatable/equatable.dart';

class VetProfile extends Equatable {
  const VetProfile({
    required this.id,
    required this.userId,
    required this.clinicName,
    required this.location,
    required this.specialization,
    required this.schedule,
    this.bio,
    this.certificateUrl,
  });

  factory VetProfile.fromMap(String id, Map<String, dynamic> data) {
    return VetProfile(
      id: id,
      userId: data['userId'] ?? '',
      clinicName: data['clinicName'] ?? '',
      location: data['location'] ?? '',
      specialization: data['specialization'] ?? '',
      schedule: List<String>.from(data['schedule'] ?? []),
      bio: data['bio'] as String?,
      certificateUrl: data['certificateUrl'] as String?,
    );
  }

  final String id;
  final String userId;
  final String clinicName;
  final String location;
  final String specialization;
  final List<String> schedule;
  final String? bio;
  final String? certificateUrl;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'clinicName': clinicName,
      'location': location,
      'specialization': specialization,
      'schedule': schedule,
      'bio': bio,
      'certificateUrl': certificateUrl,
    };
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    clinicName,
    location,
    specialization,
    schedule,
    bio,
    certificateUrl,
  ];
}
