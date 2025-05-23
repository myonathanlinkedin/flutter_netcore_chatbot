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
      final response = await _dio.post('/prompt/chat', data: {
        'message': message,
        'model': 'gpt-4', // Default model, can be made configurable
      });
      return response.data['response'] as String;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to send message';
    }
  }

  Future<List<Map<String, dynamic>>> getConversationHistory(String token) async {
    try {
      _dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.get('/prompt/history');
      final List<dynamic> messages = response.data['messages'];
      return messages.map((m) => m as Map<String, dynamic>).toList();
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to get conversation history';
    }
  }

  Future<List<String>> getAvailableModels(String token) async {
    try {
      _dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.get('/prompt/models');
      final List<dynamic> models = response.data['models'];
      return models.map((m) => m.toString()).toList();
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to get available models';
    }
  }
} 