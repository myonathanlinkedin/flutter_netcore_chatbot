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
    on<LoadHistory>(_onLoadHistory);
    on<ClearChat>(_onClearChat);

    // Load chat history when bloc is created
    add(const ChatEvent.loadHistory());
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));

      final userMessage = ChatMessage(
        id: DateTime.now().toString(),
        text: event.message,
        isUser: true,
        timestamp: DateTime.now(),
      );

      emit(state.copyWith(
        messages: [...state.messages, userMessage],
        isLoading: true,
      ));

      final response = await _chatbotService.sendMessage(event.message, _token);

      final botMessage = ChatMessage(
        id: DateTime.now().toString(),
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

  Future<void> _onLoadHistory(LoadHistory event, Emitter<ChatState> emit) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));

      final history = await _chatbotService.getConversationHistory(_token);
      final chatMessages = history.map((message) {
        return ChatMessage(
          id: message['id'] as String? ?? DateTime.now().toString(),
          text: message['text'] as String? ?? '',
          isUser: message['isUser'] as bool? ?? false,
          timestamp: DateTime.parse(message['timestamp'] as String? ?? DateTime.now().toString()),
          model: message['model'] as String?,
        );
      }).toList();

      emit(state.copyWith(
        messages: chatMessages,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  void _onClearChat(ClearChat event, Emitter<ChatState> emit) {
    emit(state.copyWith(messages: []));
  }
} 