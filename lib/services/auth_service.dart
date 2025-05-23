import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import '../data/models/auth/auth_request.dart';
import '../data/models/auth/auth_response.dart';
import '../data/models/auth/user.dart';

class AuthService {
  final Dio _dio;
  final String _baseUrl = kIsWeb 
    ? 'https://localhost:7190/api'
    : Platform.isAndroid 
      ? 'https://10.0.2.2:7190/api'
      : 'https://localhost:7190/api';

  AuthService() : _dio = Dio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.sendTimeout = const Duration(seconds: 10);
    _dio.options.validateStatus = (status) => status! < 500;
    
    // Configure SSL certificate verification for development
    if (!kIsWeb) {
      final httpClient = HttpClient();
      httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) {
        debugPrint('Accepting certificate for $host:$port');
        return true;
      };
      
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        return httpClient;
      };
    }
    
    // Add logging interceptor
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      requestHeader: true,
      responseHeader: true,
      request: true,
      logPrint: (object) {
        debugPrint('DIO LOG: $object');
      },
    ));

    // Add retry interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('Making request to: ${options.uri}');
          debugPrint('Headers: ${options.headers}');
          debugPrint('Data: ${options.data}');
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          debugPrint('Interceptor caught error: ${e.type} - ${e.message}');
          debugPrint('Request: ${e.requestOptions.uri}');
          debugPrint('Headers: ${e.requestOptions.headers}');
          debugPrint('Data: ${e.requestOptions.data}');
          
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.sendTimeout ||
              e.type == DioExceptionType.connectionError) {
            debugPrint('Connection error: ${e.message}. Retrying...');
            // Retry the request
            try {
              final retryOptions = Options(
                headers: e.requestOptions.headers,
                contentType: e.requestOptions.contentType,
                followRedirects: true,
                validateStatus: (status) => status! < 500,
                receiveTimeout: const Duration(seconds: 10),
                sendTimeout: const Duration(seconds: 10),
              );
              
              final response = await _dio.request(
                e.requestOptions.path,
                data: e.requestOptions.data,
                options: retryOptions,
              );
              return handler.resolve(response);
            } catch (retryError) {
              debugPrint('Retry failed: $retryError');
              return handler.next(e);
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  User? _extractUserFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        debugPrint('Invalid JWT token format');
        return null;
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> claims = json.decode(resp);

      debugPrint('JWT Claims: $claims');

      // Extract email from unique_name claim
      final email = claims['unique_name'] as String?;
      if (email == null) {
        debugPrint('No email found in token claims');
        return null;
      }

      return User(
        id: claims['nameid'] as String,
        email: email,
        username: email,
        token: token,
        roles: (claims['role'] as List<dynamic>?)?.cast<String>() ?? [],
      );
    } catch (e) {
      debugPrint('Error extracting user from token: $e');
      return null;
    }
  }

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      debugPrint('Attempting login to: ${_dio.options.baseUrl}/Identity/Login/loginAsync');
      debugPrint('Request data: ${request.toJson()}');
      
      final response = await _dio.post(
        '/Identity/Login/loginAsync',
        data: request.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          followRedirects: true,
          validateStatus: (status) => status! < 500,
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );
      
      debugPrint('Login response status: ${response.statusCode}');
      debugPrint('Login response headers: ${response.headers}');
      debugPrint('Login response data: ${response.data}');
      
      final authResponse = AuthResponse.fromJson(response.data);
      final user = _extractUserFromToken(authResponse.token);
      
      return authResponse.copyWith(user: user);
      
    } on DioException catch (e) {
      debugPrint('Login error: ${e.message}');
      debugPrint('Error type: ${e.type}');
      debugPrint('Error response: ${e.response?.data}');
      debugPrint('Error status code: ${e.response?.statusCode}');
      debugPrint('Error headers: ${e.response?.headers}');
      debugPrint('Stack trace: ${e.stackTrace}');
      
      String? errorMsg;
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data['errors'] is List && data['errors'].isNotEmpty) {
          errorMsg = data['errors'][0];
        }
      }
      throw errorMsg ?? 'Login failed. Please try again.';
    } catch (e, stackTrace) {
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      throw 'Login failed. Please try again.';
    }
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        '/Identity/Register/registerAsync',
        data: request.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          followRedirects: true,
          validateStatus: (status) => status! < 500,
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );
      
      final authResponse = AuthResponse.fromJson(response.data);
      final user = _extractUserFromToken(authResponse.token);
      
      return authResponse.copyWith(user: user);
      
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

  Future<User?> getCurrentUser(String token) async {
    return _extractUserFromToken(token);
  }

  Future<AuthResponse> refreshToken(String token, String refreshToken) async {
    final user = _extractUserFromToken(token);
    if (user == null) throw Exception('Invalid token');
    final response = await _dio.post(
      '/Identity/RefreshTokenAsync',
      data: {
        'userId': user.id,
        'refreshToken': refreshToken,
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );
    final authResponse = AuthResponse.fromJson(response.data);
    return authResponse.copyWith(user: _extractUserFromToken(authResponse.token));
  }
} 