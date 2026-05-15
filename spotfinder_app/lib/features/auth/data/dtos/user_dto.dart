class UserDto {
  const UserDto({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isVerified,
    required this.active,
    required this.roles,
  });

  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final bool isVerified;
  final bool active;
  final List<String> roles;

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: (json['id'] as num).toInt(),
      email: json['email'] as String,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      isVerified: json['isVerified'] as bool? ?? false,
      active: json['active'] as bool? ?? true,
      roles: (json['roles'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}
