import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

class ChatbotService {
  final Dio _dio;
  bool _isRequestInProgress = false;
  final String _baseUrl = kIsWeb 
    ? 'https://localhost:7190/api'
    : Platform.isAndroid 
      ? 'https://10.0.2.2:7190/api'
      : 'https://localhost:7190/api';

  ChatbotService() : _dio = Dio(BaseOptions(
    baseUrl: kIsWeb 
      ? 'https://localhost:7190/api'
      : Platform.isAndroid 
        ? 'https://10.0.2.2:7190/api'
        : 'https://localhost:7190/api',
    method: 'POST',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(minutes: 5),
    sendTimeout: const Duration(seconds: 10),
    validateStatus: (status) => status! < 500,
    contentType: 'application/json',
    responseType: ResponseType.plain,
  )) {
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
  }

  Future<String> sendMessage(String message, String token) async {
    if (_isRequestInProgress) {
      debugPrint('Request already in progress, ignoring new request');
      throw 'Please wait for the current request to complete';
    }

    try {
      _isRequestInProgress = true;
      debugPrint('Starting new request with message: ${message.substring(0, message.length.clamp(0, 50))}...');
      
      final response = await _dio.post(
        '/Prompt/SendUserPrompt/SendUserPromptAsync',
        data: {
          'prompt': message,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'text/plain',
          },
        ),
      );
      
      debugPrint('Response received with status: ${response.statusCode}');
      return response.data.toString();
      
    } on DioException catch (e) {
      debugPrint('Request failed: ${e.type} - ${e.message}');
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          throw 'Connection timed out. Please try again.';
        case DioExceptionType.receiveTimeout:
          throw 'Response took too long. Please try again.';
        case DioExceptionType.sendTimeout:
          throw 'Failed to send message. Please try again.';
        default:
          throw e.message ?? 'Failed to send message';
      }
    } finally {
      _isRequestInProgress = false;
      debugPrint('Request completed, lock released');
    }
  }
} 