import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/utils/geo_utils.dart';
import '../../data/models/interview_model.dart';
import '../logic/interview_bloc.dart';

/// Employer — Track / jonli kuzatish (PROMPT_SUHBATLAR_MOBILE.md §3.4).
class EmployerTrackScreen extends StatefulWidget {
  final InterviewModel interview;
  const EmployerTrackScreen({super.key, required this.interview});

  @override
  State<EmployerTrackScreen> createState() => _EmployerTrackScreenState();
}

class _EmployerTrackScreenState extends State<EmployerTrackScreen> {
  GoogleMapController? _mapController;
  int? _lastCameraTick;

  InterviewModel get _i => widget.interview;
  bool get _hasUs => _i.employer?.hasCoords ?? false;
  LatLng? get _usPos =>
      _hasUs ? LatLng(_i.employer!.latitude!, _i.employer!.longitude!) : null;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<InterviewBloc>();
    bloc.add(const ConnectSocketEvent());
    // Oxirgi koordinatani tiklash, so'ng socket bilan jonli.
    bloc.add(const LoadLiveInterviewsEvent());
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _followCandidate(LiveLocation loc) {
    // Har yangi nuqtada kamerani nomzodga suramiz (haddan tashqari emas).
    final tick = loc.at.millisecondsSinceEpoch;
    if (_lastCameraTick == tick) return;
    _lastCameraTick = tick;
    _mapController
        ?.animateCamera(CameraUpdate.newLatLng(LatLng(loc.lat, loc.lng)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LIGHT_GRAY_BG,
      appBar: AppBar(
        backgroundColor: DARK_NAVY,
        foregroundColor: Colors.white,
        title: const Text('Kuzatish',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
      ),
      body: BlocBuilder<InterviewBloc, InterviewState>(
        buildWhen: (p, c) =>
            p.liveById != c.liveById || p.travelById != c.travelById,
        builder: (context, state) {
          final loc = state.liveById[_i.id];
          final travel = state.travelOf(_i);
          if (loc != null) {
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _followCandidate(loc));
          }
          return Column(
            children: [
              _topBar(travel),
              if (!_hasUs)
                _warning(
                    'Kompaniya manzili koordinatasi yo\'q — masofa/ETA hisoblanmaydi.'),
              Expanded(child: _map(loc)),
              _bottomInfo(loc),
            ],
          );
        },
      ),
    );
  }

  Widget _topBar(String travel) {
    final color = travel == 'on_way'
        ? AMBER_COLOR
        : (travel == 'arrived' ? GREEN_COLOR : GRAY_TEXT);
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_i.anketa?.fullname ?? 'Nomzod',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: DARK_NAVY)),
                if ((_i.anketa?.phoneNumber ?? '').isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 14, color: GRAY_TEXT),
                      const SizedBox(width: 5),
                      Text(_i.anketa!.phoneNumber!,
                          style:
                              const TextStyle(fontSize: 13, color: GRAY_TEXT)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              switch (travel) {
                'on_way' => "Yo'lda",
                'arrived' => 'Yetib keldi',
                'stopped' => "To'xtatildi",
                _ => 'Boshlanmagan',
              },
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _warning(String text) {
    return Container(
      width: double.infinity,
      color: AMBER_COLOR.withValues(alpha: 0.10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, size: 18, color: AMBER_COLOR),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 12.5,
                    color: AMBER_COLOR,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _map(LiveLocation? loc) {
    final candidatePos = loc != null ? LatLng(loc.lat, loc.lng) : null;
    final markers = <Marker>{
      if (candidatePos != null)
        Marker(
          markerId: const MarkerId('candidate'),
          position: candidatePos,
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange),
          rotation: loc?.heading ?? 0,
          infoWindow: InfoWindow(title: _i.anketa?.fullname ?? 'Nomzod'),
        ),
      if (_usPos != null)
        Marker(
          markerId: const MarkerId('us'),
          position: _usPos!,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: _i.employer?.name ?? 'Biz'),
        ),
    };
    final polylines = <Polyline>{
      if (candidatePos != null && _usPos != null)
        Polyline(
          polylineId: const PolylineId('route'),
          points: [candidatePos, _usPos!],
          color: AMBER_COLOR,
          width: 4,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
    };

    final initial = candidatePos ?? _usPos ?? const LatLng(41.3111, 69.2797);
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: initial, zoom: 14),
      markers: markers,
      polylines: polylines,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      onMapCreated: (c) => _mapController = c,
    );
  }

  Widget _bottomInfo(LiveLocation? loc) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
          16, 14, 16, MediaQuery.of(context).padding.bottom + 14),
      child: Column(
        children: [
          if (loc == null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AMBER_COLOR),
                ),
                const SizedBox(width: 10),
                Text('Nomzod lokatsiyani ulashishini kutilmoqda…',
                    style: TextStyle(
                        fontSize: 13, color: GRAY_TEXT.withValues(alpha: 0.9))),
              ],
            )
          else ...[
            if (_hasUs)
              Row(
                children: [
                  Expanded(
                      child: _statCard(Icons.timer_outlined, 'Yetib borish',
                          _eta(loc), PRIMARY_BLUE)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _statCard(Icons.straighten, 'Masofa',
                          _distance(loc), AMBER_COLOR)),
                ],
              )
            else
              const Text('Faqat nomzod nuqtasi ko\'rsatilmoqda',
                  style: TextStyle(fontSize: 13, color: GRAY_TEXT)),
            const SizedBox(height: 10),
            Text('Oxirgi yangilanish: ${_time(loc.at)}',
                style: const TextStyle(fontSize: 11.5, color: GRAY_TEXT)),
          ],
        ],
      ),
    );
  }

  double _km(LiveLocation loc) => haversineKm(
      loc.lat, loc.lng, _usPos!.latitude, _usPos!.longitude);

  String _eta(LiveLocation loc) => _hasUs ? etaDisplay(_km(loc)) : '—';
  String _distance(LiveLocation loc) =>
      _hasUs ? distanceDisplay(_km(loc)) : '—';

  String _time(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(t.hour)}:${two(t.minute)}:${two(t.second)}';
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
}
