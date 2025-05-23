import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/chat/chat_message.dart';
import '../../services/chatbot_service.dart';
import 'chat_event.dart';
import 'chat_state.dart';

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

      // Get bot response
      final response = await _chatbotService.sendMessage(event.message, _token);

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
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }
} 