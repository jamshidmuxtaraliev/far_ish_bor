part of 'chat_bloc.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// Connect the socket and bind to [sessionKey] (support:{role}:{mobileUserId}).
class ConnectChatEvent extends ChatEvent {
  final String sessionKey;
  const ConnectChatEvent(this.sessionKey);

  @override
  List<Object?> get props => [sessionKey];
}

class DisconnectChatEvent extends ChatEvent {
  const DisconnectChatEvent();
}

class LoadHistoryEvent extends ChatEvent {
  final int? beforeId;
  const LoadHistoryEvent({this.beforeId});

  @override
  List<Object?> get props => [beforeId];
}

class SendChatMessageEvent extends ChatEvent {
  final String text;
  const SendChatMessageEvent(this.text);

  @override
  List<Object?> get props => [text];
}

class UserTypingEvent extends ChatEvent {
  final bool isTyping;
  const UserTypingEvent(this.isTyping);

  @override
  List<Object?> get props => [isTyping];
}

// ── Internal events fed from socket streams ────────────────────────────────────

class _MessageReceived extends ChatEvent {
  final ChatMessageModel message;
  const _MessageReceived(this.message);

  @override
  List<Object?> get props => [message.id, message.sessionKey];
}

class _ConnectionChanged extends ChatEvent {
  final bool connected;
  const _ConnectionChanged(this.connected);

  @override
  List<Object?> get props => [connected];
}

class _OperatorTyping extends ChatEvent {
  final bool isTyping;
  const _OperatorTyping(this.isTyping);

  @override
  List<Object?> get props => [isTyping];
}

class _ChatErrored extends ChatEvent {
  final String message;
  const _ChatErrored(this.message);

  @override
  List<Object?> get props => [message];
}
