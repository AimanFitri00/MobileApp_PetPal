import 'package:equatable/equatable.dart';

class SitterProfile extends Equatable {
  const SitterProfile({
    required this.id,
    required this.userId,
    required this.experience,
    required this.location,
    required this.pricing,
    this.services,
    this.certificateUrl,
  });

  factory SitterProfile.fromMap(String id, Map<String, dynamic> data) {
    return SitterProfile(
      id: id,
      userId: data['userId'] ?? '',
      experience: data['experience'] ?? '',
      location: data['location'] ?? '',
      pricing: data['pricing'] ?? '',
      services: List<String>.from(data['services'] ?? []),
      certificateUrl: data['certificateUrl'] as String?,
    );
  }

  final String id;
  final String userId;
  final String experience;
  final String location;
  final String pricing;
  final List<String>? services;
  final String? certificateUrl;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'experience': experience,
      'location': location,
      'pricing': pricing,
      'services': services,
      'certificateUrl': certificateUrl,
    };
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    experience,
    location,
    pricing,
    services,
    certificateUrl,
  ];
}
