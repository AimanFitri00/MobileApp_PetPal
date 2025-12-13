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
    this.birthday,
    // Vet specific
    this.specialization,
    this.clinicLocation,
    this.schedule,
    // Sitter specific
    this.experience, // experienceDescription
    this.yearsOfExperience,
    this.pricing,
    this.serviceArea,
    this.hotelImageUrls,
    this.petTypesAccepted,
    this.servicesProvided,
    this.availableDays,
    this.availableHours,
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
      birthday: data['birthday'] as String?,
      specialization: data['specialization'] as String?,
      clinicLocation: data['clinicLocation'] as String?,
      schedule: data['schedule'] as String?,
      // Sitter
      experience: data['experience'] as String?, // experienceDescription
      yearsOfExperience: data['yearsOfExperience'] as int?,
      pricing: (data['pricing'] as num?)?.toDouble(),
      serviceArea: data['serviceArea'] as String?,
      petTypesAccepted: (data['petTypesAccepted'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      servicesProvided: (data['servicesProvided'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      availableDays: (data['availableDays'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      availableHours: (data['availableHours'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v as String)),
          
      hotelImageUrls: (data['hotelImageUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? phone;
  final String? address;
  final String? profileImageUrl;
  final String? birthday;
  
  // Vet specific
  final String? specialization;
  final String? clinicLocation;
  final String? schedule;
  final List<String>? hotelImageUrls;

  // Sitter specific
  final String? experience; // Used for Description
  final int? yearsOfExperience;
  final double? pricing;
  final String? serviceArea;
  final List<String>? petTypesAccepted;
  final List<String>? servicesProvided;
  final List<String>? availableDays;
  final Map<String, String>? availableHours;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role.name,
      'phone': phone,
      'address': address,
      'profileImageUrl': profileImageUrl,
      'birthday': birthday,
      'specialization': specialization,
      'clinicLocation': clinicLocation,
      'schedule': schedule,
      'experience': experience,
      'yearsOfExperience': yearsOfExperience,
      'pricing': pricing,
      'serviceArea': serviceArea,
      'hotelImageUrls': hotelImageUrls,
      'petTypesAccepted': petTypesAccepted,
      'servicesProvided': servicesProvided,
      'availableDays': availableDays,
      'availableHours': availableHours,
    };
  }

  AppUser copyWith({
    String? name,
    String? email,
    UserRole? role,
    String? phone,
    String? address,
    String? profileImageUrl,
    String? birthday,
    String? specialization,
    String? clinicLocation,
    String? schedule,
    String? experience,
    int? yearsOfExperience,
    double? pricing,
    String? serviceArea,
    List<String>? hotelImageUrls,
    List<String>? petTypesAccepted,
    List<String>? servicesProvided,
    List<String>? availableDays,
    Map<String, String>? availableHours,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      birthday: birthday ?? this.birthday,
      specialization: specialization ?? this.specialization,
      clinicLocation: clinicLocation ?? this.clinicLocation,
      schedule: schedule ?? this.schedule,
      experience: experience ?? this.experience,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      pricing: pricing ?? this.pricing,
      serviceArea: serviceArea ?? this.serviceArea,
      hotelImageUrls: hotelImageUrls ?? this.hotelImageUrls,
      petTypesAccepted: petTypesAccepted ?? this.petTypesAccepted,
      servicesProvided: servicesProvided ?? this.servicesProvided,
      availableDays: availableDays ?? this.availableDays,
      availableHours: availableHours ?? this.availableHours,
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
    birthday,
    specialization,
    clinicLocation,
    schedule,
    experience,
    yearsOfExperience,
    pricing,
    serviceArea,
    hotelImageUrls,
    petTypesAccepted,
    servicesProvided,
    availableDays,
    availableHours,
  ];
}
