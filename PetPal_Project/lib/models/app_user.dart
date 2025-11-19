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
    );
  }

  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? phone;
  final String? address;
  final String? profileImageUrl;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role.name,
      'phone': phone,
      'address': address,
      'profileImageUrl': profileImageUrl,
    };
  }

  AppUser copyWith({
    String? name,
    String? email,
    UserRole? role,
    String? phone,
    String? address,
    String? profileImageUrl,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
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
  ];
}
