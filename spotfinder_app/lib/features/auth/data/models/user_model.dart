import '../../domain/entities/user_entity.dart';

/// JSON mapper for the user payload returned by the SpotFinder backend.
/// Matches the shape of `UserResource` from the API.
class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.roles,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final first = (json['firstName'] ?? '').toString();
    final last = (json['lastName'] ?? '').toString();
    final fullName = ('$first $last').trim();

    return UserModel(
      id: (json['id'] as num).toInt(),
      email: json['email'] as String,
      fullName: fullName.isEmpty ? (json['email'] as String) : fullName,
      roles: (json['roles'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'fullName': fullName,
        'roles': roles,
      };
}
