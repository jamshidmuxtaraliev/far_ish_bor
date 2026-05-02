import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// Internet aloqasini doimiy kuzatuvchi servis.
/// `getIt` orqali DI asosida chaqiriladi.
class InternetCheckerService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Internet bor/yo‘qligini kuzatuvchi notifier
  final ValueNotifier<bool> hasInternet = ValueNotifier(true);

  /// Servisni ishga tushurish — `main.dart` da 1 marta chaqiriladi
  void start() {
    _checkInitialStatus();
    _subscription ??= _connectivity.onConnectivityChanged.listen((results) {
      final primary = results.isNotEmpty ? results.first : ConnectivityResult.none;
      hasInternet.value = primary != ConnectivityResult.none;
    });
  }

  /// Dastlabki holatni tekshirish
  Future<void> _checkInitialStatus() async {
    final result = await _connectivity.checkConnectivity();
    hasInternet.value = result != ConnectivityResult.none;
  }

  /// Tozalash (agar kerak bo‘lsa)
  void dispose() {
    _subscription?.cancel();
    hasInternet.dispose();
  }
}

