import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/chat/chat_message.dart';
import '../../services/chatbot_service.dart';
import 'chat_event.dart';
import 'chat_state.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatbotService _chatbotService;
  final String _token;

  ChatBloc({
    required ChatbotService chatbotService,
    required String token,
  })  : _chatbotService = chatbotService,
        _token = token,
        super(const ChatState()) {
    on<SendMessage>(_onSendMessage);
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (state.isLoading) {
      debugPrint('ChatBloc: Ignoring send message request while loading');
      return;
    }
    
    try {
      // Add user message immediately
      final userMessage = ChatMessage(
        text: event.message,
        isUser: true,
        timestamp: DateTime.now(),
      );
      emit(state.copyWith(
        messages: [...state.messages, userMessage],
        isLoading: true,
        error: null,
      ));

      // Get bot response with a timeout
      String response;
      try {
        response = await _chatbotService.sendMessage(event.message, _token);
      } catch (e) {
        if (e.toString().contains('Connection timed out') || 
            e.toString().contains('Response took too long') ||
            e.toString().contains('Failed to send message')) {
          emit(state.copyWith(
            isLoading: false,
            error: 'Please try again',
          ));
          return;
        } else {
          rethrow;
        }
      }

      // Add bot message
      final botMessage = ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      );
      emit(state.copyWith(
        messages: [...state.messages, botMessage],
        isLoading: false,
      ));
    } catch (e) {
      debugPrint('ChatBloc error: $e');
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }
} 