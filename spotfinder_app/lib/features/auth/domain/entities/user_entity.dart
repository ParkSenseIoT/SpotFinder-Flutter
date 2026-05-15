/// Plain data carrier for the authenticated user.
/// Used by the UI; does not know about JSON/HTTP.
class UserEntity {
  final int id;
  final String email;
  final String fullName;
  final List<String> roles;

  UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    required this.roles,
  });

  bool get isAdmin => roles.contains('ADMIN');
  bool get isCarOwner => roles.contains('CAR_OWNER');
}
