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

/// Initial / reconnect load of the latest page — merged by id (no duplicates).
class LoadHistoryEvent extends ChatEvent {
  const LoadHistoryEvent();
}

/// Upward infinite scroll: fetch messages older than the current oldest id.
class LoadMoreHistoryEvent extends ChatEvent {
  const LoadMoreHistoryEvent();
}

class SendChatMessageEvent extends ChatEvent {
  final String text;
  const SendChatMessageEvent(this.text);

  @override
  List<Object?> get props => [text];
}

/// Upload a picked file, then send it as an attachment message.
/// [caption] — ixtiyoriy izoh, attachment bilan bitta xabarda ketadi (§4).
class SendAttachmentEvent extends ChatEvent {
  final String path;
  final String? caption;
  const SendAttachmentEvent(this.path, {this.caption});

  @override
  List<Object?> get props => [path, caption];
}

/// Re-send a failed optimistic message (tap on the ❗ bubble).
class RetryMessageEvent extends ChatEvent {
  final String localId;
  const RetryMessageEvent(this.localId);

  @override
  List<Object?> get props => [localId];
}

/// Chat screen came on top: reset the unread badge and pause counting.
class ChatScreenOpenedEvent extends ChatEvent {
  const ChatScreenOpenedEvent();
}

/// Chat screen left: resume unread counting (socket stays connected — §7.10).
class ChatScreenClosedEvent extends ChatEvent {
  const ChatScreenClosedEvent();
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
  List<Object?> get props => [message.id, message.localId, message.sessionKey];
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

class _OperatorPresenceChanged extends ChatEvent {
  final bool joined;
  const _OperatorPresenceChanged(this.joined);

  @override
  List<Object?> get props => [joined];
}

/// chat:assigned — the responsible operator changed (auto-routing).
class _OperatorAssigned extends ChatEvent {
  final String name;
  const _OperatorAssigned(this.name);

  @override
  List<Object?> get props => [name];
}

class _ChatErrored extends ChatEvent {
  final String message;
  const _ChatErrored(this.message);

  @override
  List<Object?> get props => [message];
}
