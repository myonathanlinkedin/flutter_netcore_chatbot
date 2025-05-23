import 'package:freezed_annotation/freezed_annotation.dart';
import 'user.dart';

part 'auth_response.freezed.dart';
part 'auth_response.g.dart';

@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    @JsonKey(name: 'accessToken') required String token,
    required String refreshToken,
    bool? success,
    String? message,
    User? user,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}

@freezed
class ErrorResponse with _$ErrorResponse {
  const factory ErrorResponse({
    required bool success,
    required String message,
  }) = _ErrorResponse;

  factory ErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseFromJson(json);
} 