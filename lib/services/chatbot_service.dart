import 'package:dio/dio.dart';

class ChatbotService {
  final Dio _dio;
  final String _baseUrl = 'https://localhost:7190/api';

  ChatbotService() : _dio = Dio() {
    _dio.options.baseUrl = _baseUrl;
    // Allow self-signed certificates for local development
    _dio.options.validateStatus = (status) => status! < 500;
  }

  Future<String> sendMessage(String message, String token) async {
    try {
      _dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.post('/Prompt/SendUserPrompt/SendUserPromptAsync', data: {
        'message': message,
        'model': 'gpt-4', // Default model
      });
      return response.data['response'] as String;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to send message';
    }
  }
} 