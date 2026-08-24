import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../../../../core/theme/jb_palette.dart';

/// Xaritadan tanlangan nuqta: koordinata + (imkoni bo'lsa) o'qiladigan manzil.
class PickedLocation {
  final double latitude;
  final double longitude;
  final String? address;

  const PickedLocation({
    required this.latitude,
    required this.longitude,
    this.address,
  });
}

/// Xarita pikerini ochadi va tanlangan nuqtani qaytaradi (bekor qilinsa `null`).
Future<PickedLocation?> pickLocationOnMap(
  BuildContext context, {
  double? initialLat,
  double? initialLng,
  String title = 'Manzilni xaritadan tanlang',
}) {
  return Navigator.of(context).push<PickedLocation>(
    MaterialPageRoute(
      builder: (_) => MapLocationPickerScreen(
        initialLat: initialLat,
        initialLng: initialLng,
        title: title,
      ),
    ),
  );
}

/// Markazdagi qo'zg'almas pin ostida xarita suriladi; harakat to'xtaganda
/// nuqta Yandex teskari geokoderi orqali manzilga aylantiriladi.
class MapLocationPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  final String title;

  const MapLocationPickerScreen({
    super.key,
    this.initialLat,
    this.initialLng,
    this.title = 'Manzilni xaritadan tanlang',
  });

  @override
  State<MapLocationPickerScreen> createState() =>
      _MapLocationPickerScreenState();
}

class _MapLocationPickerScreenState extends State<MapLocationPickerScreen> {
  /// Toshkent markazi — boshlang'ich koordinata bo'lmaganda ishlatiladi.
  static const Point _tashkent =
      Point(latitude: 41.311081, longitude: 69.240562);

  YandexMapController? _controller;
  Timer? _geocodeDebounce;

  late Point _target;
  String? _address;
  bool _moving = false;
  bool _geocoding = false;
  bool _locating = false;

  bool get _hasInitial => widget.initialLat != null && widget.initialLng != null;

  @override
  void initState() {
    super.initState();
    _target = _hasInitial
        ? Point(latitude: widget.initialLat!, longitude: widget.initialLng!)
        : _tashkent;
    if (_hasInitial) _resolveAddress(_target);
  }

  @override
  void dispose() {
    _geocodeDebounce?.cancel();
    super.dispose();
  }

  void _onCameraChanged(CameraPosition pos, CameraUpdateReason _, bool finished) {
    _target = pos.target;
    if (!finished) {
      if (!_moving) setState(() => _moving = true);
      _geocodeDebounce?.cancel();
      return;
    }
    setState(() => _moving = false);
    // Kamera to'xtagach biroz kutamiz — ketma-ket surishlarda ortiqcha
    // so'rov yubormaslik uchun.
    _geocodeDebounce?.cancel();
    _geocodeDebounce =
        Timer(const Duration(milliseconds: 350), () => _resolveAddress(_target));
  }

  /// Teskari geokodlash. Xato/kalit muammosida jim qoladi — koordinata baribir
  /// tanlangan bo'ladi.
  Future<void> _resolveAddress(Point point) async {
    if (!mounted) return;
    setState(() => _geocoding = true);
    String? found;
    try {
      final (session, result) = await YandexSearch.searchByPoint(
        point: point,
        zoom: 17,
        searchOptions: const SearchOptions(searchType: SearchType.geo),
      );
      final res = await result;
      await session.close();
      final items = res.items;
      if (res.error == null && items != null && items.isNotEmpty) {
        final item = items.first;
        found = item.toponymMetadata?.address.formattedAddress ?? item.name;
      }
    } catch (_) {
      found = null;
    }
    if (!mounted) return;
    setState(() {
      _geocoding = false;
      _address = found;
    });
  }

  Future<void> _goToMyLocation() async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _toast('Qurilmada joylashuv xizmati o\'chirilgan');
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        _toast('Joylashuvga ruxsat berilmadi');
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      await _controller?.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: Point(latitude: pos.latitude, longitude: pos.longitude),
            zoom: 17,
          ),
        ),
        animation: const MapAnimation(type: MapAnimationType.smooth, duration: 0.4),
      );
    } catch (_) {
      _toast('Joylashuvni aniqlab bo\'lmadi');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: context.jb.amber),
    );
  }

  Future<void> _zoom(double delta) async {
    final pos = await _controller?.getCameraPosition();
    if (pos == null) return;
    await _controller?.moveCamera(
      CameraUpdate.newCameraPosition(pos.copyWith(zoom: pos.zoom + delta)),
      animation: const MapAnimation(type: MapAnimationType.smooth, duration: 0.2),
    );
  }

  void _confirm() {
    Navigator.of(context).pop(PickedLocation(
      latitude: _target.latitude,
      longitude: _target.longitude,
      address: _address,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.jb;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: p.overlay,
      child: Scaffold(
        backgroundColor: p.bg,
        body: Stack(
          children: [
            YandexMap(
              nightModeEnabled: p.isDark,
              onMapCreated: (c) {
                _controller = c;
                c.moveCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(target: _target, zoom: _hasInitial ? 17 : 12),
                  ),
                );
              },
              onCameraPositionChanged: _onCameraChanged,
              onMapTap: (point) => _controller?.moveCamera(
                CameraUpdate.newCameraPosition(CameraPosition(target: point)),
                animation:
                    const MapAnimation(type: MapAnimationType.smooth, duration: 0.25),
              ),
            ),

            // Markazdagi pin — xarita suriladi, pin joyida qoladi.
            IgnorePointer(
              child: Center(
                child: Padding(
                  // Pin uchi ekran markaziga to'g'ri kelishi uchun yuqoriga surildi.
                  padding: const EdgeInsets.only(bottom: 44),
                  child: _CenterPin(lifted: _moving),
                ),
              ),
            ),

            // Yuqori panel: orqaga + sarlavha
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  _RoundButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 44,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: p.card,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(color: p.shadow, blurRadius: 10, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: p.ink,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // O'ng tarafdagi boshqaruv tugmalari
            Positioned(
              right: 12,
              bottom: 200,
              child: Column(
                children: [
                  _RoundButton(icon: Icons.add, onTap: () => _zoom(1)),
                  const SizedBox(height: 10),
                  _RoundButton(icon: Icons.remove, onTap: () => _zoom(-1)),
                  const SizedBox(height: 10),
                  _RoundButton(
                    icon: Icons.my_location,
                    busy: _locating,
                    onTap: _goToMyLocation,
                  ),
                ],
              ),
            ),

            // Pastki karta: manzil + koordinata + tasdiqlash
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _BottomSheetCard(
                address: _address,
                geocoding: _geocoding,
                moving: _moving,
                point: _target,
                onConfirm: _confirm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterPin extends StatelessWidget {
  final bool lifted;
  const _CenterPin({required this.lifted});

  @override
  Widget build(BuildContext context) {
    final p = context.jb;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, lifted ? -10 : 0, 0),
          child: Icon(Icons.location_on, size: 46, color: p.blue),
        ),
        // Nuqtaning aniq joyini ko'rsatuvchi soya.
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: lifted ? 14 : 8,
          height: lifted ? 5 : 3,
          decoration: BoxDecoration(
            color: p.ink.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ],
    );
  }
}

class _BottomSheetCard extends StatelessWidget {
  final String? address;
  final bool geocoding;
  final bool moving;
  final Point point;
  final VoidCallback onConfirm;

  const _BottomSheetCard({
    required this.address,
    required this.geocoding,
    required this.moving,
    required this.point,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.jb;
    final coords =
        '${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}';
    final String subtitle;
    if (moving) {
      subtitle = 'Xaritani suring…';
    } else if (geocoding) {
      subtitle = 'Manzil aniqlanmoqda…';
    } else {
      subtitle = address ?? 'Manzil topilmadi — koordinata saqlanadi';
    }

    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: p.shadow, blurRadius: 16, offset: const Offset(0, -2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.place_outlined, color: p.blue, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: p.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      coords,
                      style: TextStyle(fontSize: 12.5, color: p.gray),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: p.blue,
                foregroundColor: p.onBrand,
                disabledBackgroundColor: p.chipBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: moving ? null : onConfirm,
              child: const Text(
                'Shu manzilni tanlash',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool busy;

  const _RoundButton({required this.icon, required this.onTap, this.busy = false});

  @override
  Widget build(BuildContext context) {
    final p = context.jb;
    return Material(
      color: p.card,
      borderRadius: BorderRadius.circular(14),
      elevation: 3,
      shadowColor: p.shadow,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: busy ? null : onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: busy
              ? Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: p.blue),
                  ),
                )
              : Icon(icon, color: p.ink, size: 22),
        ),
      ),
    );
  }
}
