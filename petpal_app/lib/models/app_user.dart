import 'package:equatable/equatable.dart';

enum UserRole { owner, vet, sitter }

class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.address,
    this.profileImageUrl,
    // Vet specific
    this.specialization,
    this.clinicLocation,
    this.schedule,
    // Sitter specific
    this.experience,
    this.pricing,
    this.serviceArea,
  });

  factory AppUser.fromMap(String id, Map<String, dynamic> data) {
    return AppUser(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: UserRole.values.firstWhere(
        (role) => role.name == data['role'],
        orElse: () => UserRole.owner,
      ),
      phone: data['phone'] as String?,
      address: data['address'] as String?,
      profileImageUrl: data['profileImageUrl'] as String?,
      specialization: data['specialization'] as String?,
      clinicLocation: data['clinicLocation'] as String?,
      schedule: data['schedule'] as String?,
      experience: data['experience'] as String?,
      pricing: (data['pricing'] as num?)?.toDouble(),
      serviceArea: data['serviceArea'] as String?,
    );
  }

  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? phone;
  final String? address;
  final String? profileImageUrl;
  
  // Vet specific
  final String? specialization;
  final String? clinicLocation;
  final String? schedule;

  // Sitter specific
  final String? experience;
  final double? pricing;
  final String? serviceArea;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role.name,
      'phone': phone,
      'address': address,
      'profileImageUrl': profileImageUrl,
      'specialization': specialization,
      'clinicLocation': clinicLocation,
      'schedule': schedule,
      'experience': experience,
      'pricing': pricing,
      'serviceArea': serviceArea,
    };
  }

  AppUser copyWith({
    String? name,
    String? email,
    UserRole? role,
    String? phone,
    String? address,
    String? profileImageUrl,
    String? specialization,
    String? clinicLocation,
    String? schedule,
    String? experience,
    double? pricing,
    String? serviceArea,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      specialization: specialization ?? this.specialization,
      clinicLocation: clinicLocation ?? this.clinicLocation,
      schedule: schedule ?? this.schedule,
      experience: experience ?? this.experience,
      pricing: pricing ?? this.pricing,
      serviceArea: serviceArea ?? this.serviceArea,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    role,
    phone,
    address,
    profileImageUrl,
    specialization,
    clinicLocation,
    schedule,
    experience,
    pricing,
    serviceArea,
  ];
}
