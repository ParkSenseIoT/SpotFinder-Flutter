import 'package:equatable/equatable.dart';

class AuthenticatedUser extends Equatable {
  const AuthenticatedUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.roles,
    required this.token,
  });

  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final List<String> roles;
  final String token;

  String get fullName => '$firstName $lastName'.trim();

  bool hasRole(String role) => roles.contains(role);

  @override
  List<Object?> get props => [id, email, firstName, lastName, roles, token];
}
