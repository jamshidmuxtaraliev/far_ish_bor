part of 'chat_bloc.dart';

class ChatState extends Equatable {
  final String sessionKey;
  final List<ChatMessageModel> messages; // chronological: oldest → newest
  final FormzSubmissionStatus historyStatus;
  final bool connected;
  final bool operatorTyping;
  final String? error;

  const ChatState({
    this.sessionKey = '',
    this.messages = const [],
    this.historyStatus = FormzSubmissionStatus.initial,
    this.connected = false,
    this.operatorTyping = false,
    this.error,
  });

  ChatState copyWith({
    String? sessionKey,
    List<ChatMessageModel>? messages,
    FormzSubmissionStatus? historyStatus,
    bool? connected,
    bool? operatorTyping,
    String? error,
  }) {
    return ChatState(
      sessionKey: sessionKey ?? this.sessionKey,
      messages: messages ?? this.messages,
      historyStatus: historyStatus ?? this.historyStatus,
      connected: connected ?? this.connected,
      operatorTyping: operatorTyping ?? this.operatorTyping,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    sessionKey,
    messages,
    historyStatus,
    connected,
    operatorTyping,
    error,
  ];
}
