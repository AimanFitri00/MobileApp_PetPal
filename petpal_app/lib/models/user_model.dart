import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum UserRole { owner, vet, sitter }

class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? phone;
  final String? address;
  final String? profileImageUrl;
  final VetProfile? vetProfile;
  final SitterProfile? sitterProfile;
  final String? fcmToken;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.address,
    this.profileImageUrl,
    this.vetProfile,
    this.sitterProfile,
    this.fcmToken,
    required this.createdAt,
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: UserRole.values.firstWhere(
        (r) => r.name == map['role'],
        orElse: () => UserRole.owner,
      ),
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      profileImageUrl: map['profileImageUrl'] as String?,
      vetProfile: map['vetProfile'] != null
          ? VetProfile.fromMap(map['vetProfile'] as Map<String, dynamic>)
          : null,
      sitterProfile: map['sitterProfile'] != null
          ? SitterProfile.fromMap(map['sitterProfile'] as Map<String, dynamic>)
          : null,
      fcmToken: map['fcmToken'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role.name,
      'phone': phone,
      'address': address,
      'profileImageUrl': profileImageUrl,
      'vetProfile': vetProfile?.toMap(),
      'sitterProfile': sitterProfile?.toMap(),
      'fcmToken': fcmToken,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    UserRole? role,
    String? phone,
    String? address,
    String? profileImageUrl,
    VetProfile? vetProfile,
    SitterProfile? sitterProfile,
    String? fcmToken,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      vetProfile: vetProfile ?? this.vetProfile,
      sitterProfile: sitterProfile ?? this.sitterProfile,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
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
        vetProfile,
        sitterProfile,
        fcmToken,
        createdAt,
      ];
}

class VetProfile extends Equatable {
  final String clinicName;
  final String location;
  final List<String> specialties;
  final bool verified;

  const VetProfile({
    required this.clinicName,
    required this.location,
    required this.specialties,
    this.verified = false,
  });

  factory VetProfile.fromMap(Map<String, dynamic> map) {
    return VetProfile(
      clinicName: map['clinicName'] ?? '',
      location: map['location'] ?? '',
      specialties: List<String>.from(map['specialties'] ?? []),
      verified: map['verified'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clinicName': clinicName,
      'location': location,
      'specialties': specialties,
      'verified': verified,
    };
  }

  @override
  List<Object?> get props => [clinicName, location, specialties, verified];
}

class SitterProfile extends Equatable {
  final String experience;
  final double pricePerHour;
  final List<String> availability;

  const SitterProfile({
    required this.experience,
    required this.pricePerHour,
    required this.availability,
  });

  factory SitterProfile.fromMap(Map<String, dynamic> map) {
    return SitterProfile(
      experience: map['experience'] ?? '',
      pricePerHour: (map['pricePerHour'] as num?)?.toDouble() ?? 0.0,
      availability: List<String>.from(map['availability'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'experience': experience,
      'pricePerHour': pricePerHour,
      'availability': availability,
    };
  }

  @override
  List<Object?> get props => [experience, pricePerHour, availability];
}

