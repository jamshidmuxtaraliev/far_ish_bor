import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../../../core/constants/constants.dart';
import '../../../../core/services/get_it.dart';
import '../../../auth/data/datasource/local/user_local_data_source.dart';
import '../models/chat_message_model.dart';

/// Socket.IO transport for the support chat (user ↔ operator).
///
/// Connects to [DOMAIN] (REST base without `/api/v1`) with the mobile JWT in the
/// handshake `auth`. Exposes broadcast streams the bloc subscribes to.
class ChatRealtimeDatasource {
  io.Socket? _socket;
  bool _connected = false;

  final _messageController = StreamController<ChatMessageModel>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  Stream<ChatMessageModel> get onMessage => _messageController.stream;
  Stream<bool> get onConnectionChanged => _connectionController.stream;
  Stream<Map<String, dynamic>> get onTyping => _typingController.stream;
  Stream<String> get onError => _errorController.stream;

  bool get isConnected => _connected;

  void connect() {
    final token = getIt<UserLocalDatasource>().getToken();
    if (token.isEmpty) {
      debugPrint('[Chat] connect aborted — empty token');
      _errorController.add('auth_required');
      return;
    }
    if (_connected && _socket != null) {
      // Already live — let the listener re-trigger join/history.
      _connectionController.add(true);
      return;
    }

    _socket?.dispose();
    _socket = io.io(
      DOMAIN,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    _socket!.onConnect((_) {
      _connected = true;
      debugPrint('[Chat] connected id=${_socket?.id}');
      _connectionController.add(true);
    });

    _socket!.onConnectError((err) {
      debugPrint('[Chat] connect_error: $err');
      _errorController.add('connect_error');
    });

    _socket!.onDisconnect((reason) {
      _connected = false;
      debugPrint('[Chat] disconnected: $reason');
      _connectionController.add(false);
    });

    _socket!.on('chat:message', (data) {
      if (data is Map) {
        try {
          _messageController.add(
            ChatMessageModel.fromJson(Map<String, dynamic>.from(data)),
          );
        } catch (e) {
          debugPrint('[Chat] chat:message parse error: $e');
        }
      }
    });

    _socket!.on('chat:typing', (data) {
      if (data is Map) _typingController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('chat:error', (data) {
      final msg = (data is Map ? data['message'] : null) as String?;
      _errorController.add(msg ?? 'chat_error');
    });

    _socket!.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _connected = false;
  }

  void joinSession(String sessionKey) {
    _socket?.emit('chat:join', {'session_key': sessionKey});
  }

  void leaveSession(String sessionKey) {
    _socket?.emit('chat:leave', {'session_key': sessionKey});
  }

  void sendMessage(String sessionKey, String text) {
    _socket?.emit('chat:message', {'session_key': sessionKey, 'text': text});
  }

  void sendTyping(String sessionKey, bool isTyping) {
    _socket?.emit('chat:typing', {
      'session_key': sessionKey,
      'is_typing': isTyping,
    });
  }

  /// Loads recent messages via the `chat:history` ack. Returns oldest→newest.
  Future<List<ChatMessageModel>> fetchHistory(
    String sessionKey, {
    int limit = 50,
    int? beforeId,
  }) async {
    final socket = _socket;
    if (socket == null) return [];

    final completer = Completer<List<ChatMessageModel>>();
    final payload = <String, dynamic>{
      'session_key': sessionKey,
      'limit': limit,
    };
    if (beforeId != null) payload['before_id'] = beforeId;

    socket.emitWithAck(
      'chat:history',
      payload,
      ack: (resp) {
        if (completer.isCompleted) return;
        final items = (resp is Map ? resp['items'] : null) as List? ?? const [];
        final messages =
            items
                .whereType<Map>()
                .map(
                  (e) =>
                      ChatMessageModel.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList();
        completer.complete(messages);
      },
    );

    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () => [],
    );
  }

  void dispose() {
    _socket?.dispose();
    _messageController.close();
    _connectionController.close();
    _typingController.close();
    _errorController.close();
  }
}
