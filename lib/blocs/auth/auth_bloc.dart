import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final SharedPreferences _prefs;
  static const String _tokenKey = 'auth_token';

  AuthBloc({
    required AuthService authService,
    required SharedPreferences prefs,
  })  : _authService = authService,
        _prefs = prefs,
        super(const AuthState()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<ResetPasswordEvent>(_onResetPassword);
    on<ChangePasswordEvent>(_onChangePassword);
    on<LogoutEvent>(_onLogout);
    on<GetCurrentUserEvent>(_onGetCurrentUser);

    // Check if user is already logged in
    final token = _prefs.getString(_tokenKey);
    if (token != null) {
      add(const AuthEvent.getCurrentUser());
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));
      final response = await _authService.login(event.request);
      if (response.success && response.token != null) {
        await _prefs.setString(_tokenKey, response.token!);
        emit(state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: response.user,
          token: response.token,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          error: response.message,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));
      final response = await _authService.register(event.request);
      if (response.success && response.token != null) {
        await _prefs.setString(_tokenKey, response.token!);
        emit(state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: response.user,
          token: response.token,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          error: response.message,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));
      final response = await _authService.resetPassword(event.request);
      emit(state.copyWith(
        isLoading: false,
        error: response.success ? null : response.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onChangePassword(
    ChangePasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));
      if (state.token == null) {
        emit(state.copyWith(
          isLoading: false,
          error: 'Not authenticated',
        ));
        return;
      }
      final response = await _authService.changePassword(state.token!, event.request);
      emit(state.copyWith(
        isLoading: false,
        error: response.success ? null : response.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    await _prefs.remove(_tokenKey);
    emit(const AuthState());
  }

  Future<void> _onGetCurrentUser(
    GetCurrentUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final token = _prefs.getString(_tokenKey);
      if (token == null) {
        emit(state.copyWith(
          isAuthenticated: false,
          user: null,
          token: null,
        ));
        return;
      }

      emit(state.copyWith(isLoading: true, error: null));
      final user = await _authService.getCurrentUser(token);
      emit(state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
        token: token,
      ));
    } catch (e) {
      await _prefs.remove(_tokenKey);
      emit(const AuthState());
    }
  }
} 