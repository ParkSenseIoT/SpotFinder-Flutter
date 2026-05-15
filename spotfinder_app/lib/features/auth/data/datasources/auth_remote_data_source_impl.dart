import '../../../../core/network/api_client.dart';
import '../dtos/sign_in_request_dto.dart';
import '../dtos/sign_in_response_dto.dart';
import '../dtos/sign_up_request_dto.dart';
import '../dtos/user_dto.dart';
import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<SignInResponseDto> signIn(SignInRequestDto request) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      '/users/signin',
      data: request.toJson(),
    );
    return SignInResponseDto.fromJson(response.data!);
  }

  @override
  Future<void> signUp(SignUpRequestDto request) async {
    await _client.dio.post<dynamic>(
      '/users/signup',
      data: request.toJson(),
    );
  }

  @override
  Future<UserDto> getUserByEmail(String email) async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      '/users/by-email',
      queryParameters: {'email': email},
    );
    return UserDto.fromJson(response.data!);
  }
}
