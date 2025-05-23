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
        'prompt': message,
        'model': 'gpt-4', // Default model
      });
      
      // Handle the response format
      if (response.data is String) {
        return response.data;
      } else if (response.data is Map<String, dynamic>) {
        return response.data['response'] as String? ?? 
               response.data['message'] as String? ?? 
               'No response from the server';
      }
      return 'Unexpected response format';
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['errors'] != null) {
        final errors = e.response!.data['errors'] as Map<String, dynamic>;
        final errorMessage = errors.values
            .expand((list) => list as List)
            .join(', ');
        throw errorMessage;
      }
      throw e.response?.data['message'] ?? 'Failed to send message';
    }
  }
} 