import '../dtos/sign_in_request_dto.dart';
import '../dtos/sign_in_response_dto.dart';
import '../dtos/sign_up_request_dto.dart';
import '../dtos/user_dto.dart';

abstract class AuthRemoteDataSource {
  Future<SignInResponseDto> signIn(SignInRequestDto request);
  Future<void> signUp(SignUpRequestDto request);
  Future<UserDto> getUserByEmail(String email);
}
