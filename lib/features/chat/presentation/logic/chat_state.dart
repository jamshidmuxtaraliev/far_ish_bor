part of 'chat_bloc.dart';

class ChatState extends Equatable {
  final String sessionKey;
  final List<ChatMessageModel> messages; // chronological: oldest → newest
  final FormzSubmissionStatus historyStatus;
  final FormzSubmissionStatus loadMoreStatus;
  final FormzSubmissionStatus uploadStatus;
  final bool hasMore; // older pages available (before_id pagination)
  final bool connected;
  final bool operatorTyping;
  final bool operatorInChat; // chat:user_joined / chat:user_left (staff)
  final String operatorName; // chat:assigned / staff message author_name
  final int unreadCount; // staff messages received while the screen is closed
  final bool screenOpen; // SupportChatScreen is on top (pause unread counting)
  final String? sessionStatus; // yangi | jarayonda | yopilgan
  final bool authFailed; // invalid_token & co. → logout (one-shot)
  final String? error;

  const ChatState({
    this.sessionKey = '',
    this.messages = const [],
    this.historyStatus = FormzSubmissionStatus.initial,
    this.loadMoreStatus = FormzSubmissionStatus.initial,
    this.uploadStatus = FormzSubmissionStatus.initial,
    this.hasMore = true,
    this.connected = false,
    this.operatorTyping = false,
    this.operatorInChat = false,
    this.operatorName = '',
    this.unreadCount = 0,
    this.screenOpen = false,
    this.sessionStatus,
    this.authFailed = false,
    this.error,
  });

  bool get sessionClosed => sessionStatus == 'yopilgan';

  ChatState copyWith({
    String? sessionKey,
    List<ChatMessageModel>? messages,
    FormzSubmissionStatus? historyStatus,
    FormzSubmissionStatus? loadMoreStatus,
    FormzSubmissionStatus? uploadStatus,
    bool? hasMore,
    bool? connected,
    bool? operatorTyping,
    bool? operatorInChat,
    String? operatorName,
    int? unreadCount,
    bool? screenOpen,
    String? sessionStatus,
    bool? authFailed,
    String? error,
  }) {
    return ChatState(
      sessionKey: sessionKey ?? this.sessionKey,
      messages: messages ?? this.messages,
      historyStatus: historyStatus ?? this.historyStatus,
      loadMoreStatus: loadMoreStatus ?? this.loadMoreStatus,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      hasMore: hasMore ?? this.hasMore,
      connected: connected ?? this.connected,
      operatorTyping: operatorTyping ?? this.operatorTyping,
      operatorInChat: operatorInChat ?? this.operatorInChat,
      operatorName: operatorName ?? this.operatorName,
      unreadCount: unreadCount ?? this.unreadCount,
      screenOpen: screenOpen ?? this.screenOpen,
      sessionStatus: sessionStatus ?? this.sessionStatus,
      authFailed: authFailed ?? this.authFailed,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    sessionKey,
    messages,
    historyStatus,
    loadMoreStatus,
    uploadStatus,
    hasMore,
    connected,
    operatorTyping,
    operatorInChat,
    operatorName,
    unreadCount,
    screenOpen,
    sessionStatus,
    authFailed,
    error,
  ];
}
