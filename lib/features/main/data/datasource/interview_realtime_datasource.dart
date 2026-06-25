import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../../../core/constants/constants.dart';
import '../../../../core/services/get_it.dart';
import '../../../auth/data/datasource/local/user_local_data_source.dart';
import '../models/interview_model.dart';

/// Suhbatlar jonli GPS oqimi (PROMPT_SUHBATLAR_MOBILE.md §5).
///
/// Seeker `interview:location` emit qiladi (faqat on_way holatda); employer/operator
/// `interview:location` + `interview:travel_status` ni qabul qiladi. [DOMAIN] ga
/// (REST base'dan `/api/v1` siz) mobil JWT bilan ulanadi.
class InterviewRealtimeDatasource {
  io.Socket? _socket;
  bool _connected = false;

  final _locationController =
      StreamController<({int interviewId, LiveLocation location})>.broadcast();
  final _travelController =
      StreamController<({int interviewId, String travelStatus})>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  Stream<({int interviewId, LiveLocation location})> get onLocation =>
      _locationController.stream;
  Stream<({int interviewId, String travelStatus})> get onTravelStatus =>
      _travelController.stream;
  Stream<bool> get onConnectionChanged => _connectionController.stream;

  bool get isConnected => _connected;

  void connect() {
    final token = getIt<UserLocalDatasource>().getToken();
    if (token.isEmpty) {
      debugPrint('[Interview] connect aborted — empty token');
      return;
    }
    if (_connected && _socket != null) {
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
      debugPrint('[Interview] connected id=${_socket?.id}');
      _connectionController.add(true);
    });

    _socket!.onConnectError((err) {
      debugPrint('[Interview] connect_error: $err');
    });

    _socket!.onDisconnect((reason) {
      _connected = false;
      debugPrint('[Interview] disconnected: $reason');
      _connectionController.add(false);
    });

    _socket!.on('interview:location', (data) {
      if (data is Map) {
        try {
          final map = Map<String, dynamic>.from(data);
          final id = (map['interview_id'] as num?)?.toInt();
          if (id == null) return;
          _locationController.add(
            (interviewId: id, location: LiveLocation.fromJson(map)),
          );
        } catch (e) {
          debugPrint('[Interview] location parse error: $e');
        }
      }
    });

    _socket!.on('interview:travel_status', (data) {
      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        final id = (map['interview_id'] as num?)?.toInt();
        final status = map['travel_status'] as String?;
        if (id != null && status != null) {
          _travelController.add((interviewId: id, travelStatus: status));
        }
      }
    });

    _socket!.connect();
  }

  /// Seeker → server: joriy GPS nuqtasini yuborish (faqat on_way holatda qabul qilinadi).
  void sendLocation({
    required int interviewId,
    required double lat,
    required double lng,
    double? accuracy,
    double? heading,
  }) {
    _socket?.emit('interview:location', {
      'interview_id': interviewId,
      'lat': lat,
      'lng': lng,
      if (accuracy != null) 'accuracy': accuracy,
      if (heading != null) 'heading': heading,
      'ts': DateTime.now().millisecondsSinceEpoch,
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _connected = false;
  }

  void dispose() {
    _socket?.dispose();
    _locationController.close();
    _travelController.close();
    _connectionController.close();
  }
}
