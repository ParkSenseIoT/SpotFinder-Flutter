class SignUpRequestDto {
  const SignUpRequestDto({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.requestedRole,
  });

  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String requestedRole;

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'requestedRole': requestedRole,
      };
}
