import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_event.freezed.dart';

@freezed
class ChatEvent with _$ChatEvent {
  const factory ChatEvent.sendMessage(String message) = SendMessage;
  const factory ChatEvent.loadHistory() = LoadHistory;
  const factory ChatEvent.clearChat() = ClearChat;
} 