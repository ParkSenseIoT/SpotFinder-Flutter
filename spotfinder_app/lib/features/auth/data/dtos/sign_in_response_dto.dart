import 'user_dto.dart';

class SignInResponseDto {
  const SignInResponseDto({
    required this.token,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  final String token;
  final String tokenType;
  final int expiresIn;
  final UserDto user;

  factory SignInResponseDto.fromJson(Map<String, dynamic> json) {
    return SignInResponseDto(
      token: json['token'] as String,
      tokenType: json['tokenType'] as String? ?? 'Bearer',
      expiresIn: (json['expiresIn'] as num).toInt(),
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
