/// Data needed to update the basic profile fields.
class ProfileUpdateRequest {
  final String firstName;
  final String lastName;

  const ProfileUpdateRequest({
    required this.firstName,
    required this.lastName,
  });
}
