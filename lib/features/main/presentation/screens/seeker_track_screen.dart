import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/utils/geo_utils.dart';
import '../../data/models/interview_model.dart';
import '../logic/interview_bloc.dart';

const Color _indigo = Color(0xFF4F46E5);

/// Seeker — Track / "Yo'lga chiqish" (PROMPT_SUHBATLAR_MOBILE.md §3.2).
/// Foreground GPS: ekran ochiq turganda lokatsiya uzatiladi.
class SeekerTrackScreen extends StatefulWidget {
  final InterviewModel interview;
  const SeekerTrackScreen({super.key, required this.interview});

  @override
  State<SeekerTrackScreen> createState() => _SeekerTrackScreenState();
}

class _SeekerTrackScreenState extends State<SeekerTrackScreen> {
  StreamSubscription<Position>? _posSub;
  GoogleMapController? _mapController;

  LatLng? _myPos;
  double? _heading;
  bool _sharing = false;
  String? _geoError;
  DateTime _lastEmit = DateTime.fromMillisecondsSinceEpoch(0);

  InterviewModel get _i => widget.interview;
  bool get _hasDest => _i.employer?.hasCoords ?? false;
  LatLng? get _destPos => _hasDest
      ? LatLng(_i.employer!.latitude!, _i.employer!.longitude!)
      : null;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<InterviewBloc>();
    bloc.add(const ConnectSocketEvent());
    // Avval on_way bo'lsa — uzatishni avtomatik davom ettiramiz.
    if (bloc.state.travelOf(_i) == 'on_way') {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startSharing(patch: false));
    }
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<bool> _ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      setState(() => _geoError = 'Qurilmada lokatsiya xizmati o\'chiq. Yoqing.');
      return false;
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      setState(() => _geoError =
          'Lokatsiyaga ruxsat berilmadi. Sozlamalardan ruxsat bering.');
      return false;
    }
    setState(() => _geoError = null);
    return true;
  }

  Future<void> _startSharing({bool patch = true}) async {
    if (!await _ensurePermission()) return;
    if (!mounted) return;
    if (patch) {
      context
          .read<InterviewBloc>()
          .add(UpdateTravelStatusEvent(_i.id, 'on_way'));
    }
    setState(() => _sharing = true);

    _posSub?.cancel();
    _posSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      ),
    ).listen(_onPosition);
  }

  void _onPosition(Position pos) {
    final me = LatLng(pos.latitude, pos.longitude);
    setState(() {
      _myPos = me;
      _heading = pos.heading >= 0 ? pos.heading : null;
    });
    _mapController?.animateCamera(CameraUpdate.newLatLng(me));

    // Throttle: oxirgi emit'dan ≥3s o'tgan bo'lsa yubor (PROMPT §5.2/§7).
    final now = DateTime.now();
    if (now.difference(_lastEmit).inMilliseconds >= 3000) {
      _lastEmit = now;
      context.read<InterviewBloc>().add(SendLocationEvent(
            interviewId: _i.id,
            lat: pos.latitude,
            lng: pos.longitude,
            accuracy: pos.accuracy,
            heading: pos.heading >= 0 ? pos.heading : null,
          ));
    }
  }

  void _stopSharing(String travelStatus) {
    _posSub?.cancel();
    _posSub = null;
    setState(() => _sharing = false);
    context.read<InterviewBloc>().add(UpdateTravelStatusEvent(_i.id, travelStatus));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LIGHT_GRAY_BG,
      appBar: AppBar(
        backgroundColor: _indigo,
        foregroundColor: Colors.white,
        title: const Text('Yo\'lga chiqish',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
      ),
      body: BlocBuilder<InterviewBloc, InterviewState>(
        buildWhen: (p, c) => p.travelById != c.travelById,
        builder: (context, state) {
          final travel = state.travelOf(_i);
          final arrived = travel == 'arrived';
          return Column(
            children: [
              _destBar(),
              if (_geoError != null) _warning(_geoError!, RED_COLOR),
              if (!_hasDest)
                _warning(
                    'Manzil koordinatasi yo\'q — faqat lokatsiyangiz uzatiladi, ETA hisoblanmaydi.',
                    AMBER_COLOR),
              Expanded(child: _map()),
              if (_sharing && _hasDest && _myPos != null) _etaRow(),
              _controls(arrived),
            ],
          );
        },
      ),
    );
  }

  Widget _destBar() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_i.employer?.name ?? 'Kompaniya',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: DARK_NAVY)),
          if ((_i.employer?.address ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 15, color: GRAY_TEXT),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(_i.employer!.address!,
                      style: const TextStyle(fontSize: 13, color: GRAY_TEXT)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _warning(String text, Color color) {
    return Container(
      width: double.infinity,
      color: color.withValues(alpha: 0.10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 12.5, color: color, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _map() {
    final markers = <Marker>{
      if (_myPos != null)
        Marker(
          markerId: const MarkerId('me'),
          position: _myPos!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange),
          rotation: _heading ?? 0,
          infoWindow: const InfoWindow(title: 'Men'),
        ),
      if (_destPos != null)
        Marker(
          markerId: const MarkerId('dest'),
          position: _destPos!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: _i.employer?.name ?? 'Manzil'),
        ),
    };
    final polylines = <Polyline>{
      if (_myPos != null && _destPos != null)
        Polyline(
          polylineId: const PolylineId('route'),
          points: [_myPos!, _destPos!],
          color: _indigo,
          width: 4,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
    };

    final initial = _myPos ?? _destPos ?? const LatLng(41.3111, 69.2797);
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: initial, zoom: 14),
      markers: markers,
      polylines: polylines,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      onMapCreated: (c) => _mapController = c,
    );
  }

  Widget _etaRow() {
    final km =
        haversineKm(_myPos!.latitude, _myPos!.longitude, _destPos!.latitude, _destPos!.longitude);
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
              child: _statCard(
                  Icons.timer_outlined, 'Yetib borish', etaDisplay(km), _indigo)),
          const SizedBox(width: 12),
          Expanded(
              child: _statCard(Icons.straighten, 'Masofa',
                  distanceDisplay(km), AMBER_COLOR)),
        ],
      ),
    );
  }

  Widget _statCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 11, color: GRAY_TEXT)),
              const SizedBox(height: 2),
              Text(value,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _controls(bool arrived) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
          16, 14, 16, MediaQuery.of(context).padding.bottom + 14),
      child: arrived
          ? _arrivedBanner()
          : (!_sharing
              ? SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => _startSharing(),
                    icon: const Icon(Icons.my_location),
                    label: const Text('Yo\'lga chiqdim — lokatsiyani ulashish',
                        style: TextStyle(
                            fontSize: 14.5, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _indigo,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () => _stopSharing('arrived'),
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Yetib keldim',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: GREEN_COLOR,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () => _stopSharing('stopped'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: RED_COLOR,
                          side: BorderSide(
                              color: RED_COLOR.withValues(alpha: 0.5)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('To\'xtatish',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                )),
    );
  }

  Widget _arrivedBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: GREEN_COLOR.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Text('Yetib keldingiz! Omad 🤝',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, color: GREEN_COLOR)),
    );
  }
}
