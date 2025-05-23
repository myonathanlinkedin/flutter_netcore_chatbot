import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/models/auth/user.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    @Default(false) bool isLoading,
    @Default(false) bool isAuthenticated,
    User? user,
    String? token,
    String? error,
  }) = _AuthState;
} 