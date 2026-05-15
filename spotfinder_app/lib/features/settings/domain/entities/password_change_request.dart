/// Body for `POST /api/v1/users/{userId}/change-password`.
class PasswordChangeRequest {
  final String currentPassword;
  final String newPassword;

  const PasswordChangeRequest({
    required this.currentPassword,
    required this.newPassword,
  });
}
