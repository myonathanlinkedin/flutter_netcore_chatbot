import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/chat_message.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(const ChatState()) {
    on<SendMessage>(_onSendMessage);
    on<ClearChat>(_onClearChat);
    on<Retry>(_onRetry);
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
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

      // TODO: Implement actual API call to your .NET Core backend
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      final botMessage = ChatMessage(
        id: DateTime.now().toString(),
        text: 'This is a mock response. Implement actual API integration.',
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

  void _onClearChat(ClearChat event, Emitter<ChatState> emit) {
    emit(const ChatState());
  }

  void _onRetry(Retry event, Emitter<ChatState> emit) {
    if (state.messages.isNotEmpty) {
      final lastUserMessage = state.messages.lastWhere((msg) => msg.isUser);
      add(ChatEvent.sendMessage(lastUserMessage.text));
    }
  }
} 