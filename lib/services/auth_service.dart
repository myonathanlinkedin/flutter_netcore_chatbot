import 'package:dio/dio.dart';
import '../data/models/auth/auth_request.dart';
import '../data/models/auth/auth_response.dart';
import '../data/models/auth/user.dart';

class AuthService {
  final Dio _dio;
  final String _baseUrl = 'https://localhost:7190/api';

  AuthService() : _dio = Dio() {
    _dio.options.baseUrl = _baseUrl;
    // Allow self-signed certificates for local development
    _dio.options.validateStatus = (status) => status! < 500;
  }

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post('/Identity/Login/loginAsync', data: request.toJson());
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.data != null) {
        throw ErrorResponse.fromJson(e.response!.data);
      }
      throw ErrorResponse(success: false, message: e.message ?? 'Login failed');
    }
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _dio.post('/Identity/Register/registerAsync', data: request.toJson());
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.data != null) {
        throw ErrorResponse.fromJson(e.response!.data);
      }
      throw ErrorResponse(success: false, message: e.message ?? 'Registration failed');
    }
  }

  Future<AuthResponse> resetPassword(ResetPasswordRequest request) async {
    try {
      final response = await _dio.post('/Identity/ResetPassword/resetPasswordAsync', data: request.toJson());
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.data != null) {
        throw ErrorResponse.fromJson(e.response!.data);
      }
      throw ErrorResponse(success: false, message: e.message ?? 'Password reset failed');
    }
  }

  Future<AuthResponse> changePassword(String token, ChangePasswordRequest request) async {
    try {
      _dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.post('/Identity/ChangePassword/changePasswordAsync', data: request.toJson());
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.data != null) {
        throw ErrorResponse.fromJson(e.response!.data);
      }
      throw ErrorResponse(success: false, message: e.message ?? 'Password change failed');
    }
  }

  Future<User> getCurrentUser(String token) async {
    try {
      _dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.get('/Identity/User/getCurrentUserAsync');
      return User.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.data != null) {
        throw ErrorResponse.fromJson(e.response!.data);
      }
      throw ErrorResponse(success: false, message: e.message ?? 'Failed to get user info');
    }
  }
} 