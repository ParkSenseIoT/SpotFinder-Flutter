import '../../domain/entities/authenticated_user.dart';
import '../dtos/sign_in_response_dto.dart';

class UserMapper {
  const UserMapper._();

  static AuthenticatedUser fromSignInResponse(SignInResponseDto dto) {
    return AuthenticatedUser(
      id: dto.user.id,
      email: dto.user.email,
      firstName: dto.user.firstName,
      lastName: dto.user.lastName,
      roles: dto.user.roles,
      token: dto.token,
    );
  }
}
