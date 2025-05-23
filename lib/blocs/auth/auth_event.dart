import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/models/auth/auth_request.dart';

part 'auth_event.freezed.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.login(LoginRequest request) = LoginEvent;
  const factory AuthEvent.register(RegisterRequest request) = RegisterEvent;
  const factory AuthEvent.resetPassword(ResetPasswordRequest request) = ResetPasswordEvent;
  const factory AuthEvent.changePassword(ChangePasswordRequest request) = ChangePasswordEvent;
  const factory AuthEvent.logout() = LogoutEvent;
  const factory AuthEvent.getCurrentUser() = GetCurrentUserEvent;
} 