import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/theme/jb_ui.dart';
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
      backgroundColor: JB_BG,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: JB_INK,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Kuzatish',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: JB_INK)),
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
    final (bg, fg) = switch (travel) {
      'on_way' => (JB_AMBER_BG, JB_AMBER_FG),
      'arrived' => (JB_GREEN_BG, JB_GREEN_FG),
      _ => (JB_CHIP_BG, JB_GRAY),
    };
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_i.anketa?.fullname ?? 'Nomzod',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: JB_INK)),
                if ((_i.anketa?.phoneNumber ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone_rounded,
                          size: 14, color: JB_GRAY_LIGHT),
                      const SizedBox(width: 6),
                      Text(_i.anketa!.phoneNumber!,
                          style: const TextStyle(fontSize: 13, color: JB_GRAY)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          JBChip(
            text: switch (travel) {
              'on_way' => "Yo'lda",
              'arrived' => 'Yetib keldi',
              'stopped' => "To'xtatildi",
              _ => 'Boshlanmagan',
            },
            bg: bg,
            fg: fg,
            fontSize: 12,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          ),
        ],
      ),
    );
  }

  Widget _warning(String text) {
    return Container(
      width: double.infinity,
      color: JB_AMBER_BG,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, size: 18, color: JB_AMBER_FG),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 12.5,
                    color: JB_AMBER_FG,
                    fontWeight: FontWeight.w600)),
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
          color: JB_AMBER_FG,
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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: kJbSoftShadow,
      ),
      padding: EdgeInsets.fromLTRB(
          20, 18, 20, MediaQuery.of(context).padding.bottom + 16),
      child: Column(
        children: [
          if (loc == null)
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: JB_AMBER_FG),
                ),
                SizedBox(width: 10),
                Text('Nomzod lokatsiyani ulashishini kutilmoqda…',
                    style: TextStyle(fontSize: 13, color: JB_GRAY)),
              ],
            )
          else ...[
            if (_hasUs)
              Row(
                children: [
                  Expanded(
                      child: _statCard(Icons.timer_outlined, 'Yetib borish',
                          _eta(loc), JB_BLUE, JB_INDIGO_TINT)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _statCard(Icons.straighten_rounded, 'Masofa',
                          _distance(loc), JB_AMBER_FG, JB_AMBER_BG)),
                ],
              )
            else
              const Text('Faqat nomzod nuqtasi ko\'rsatilmoqda',
                  style: TextStyle(fontSize: 13, color: JB_GRAY)),
            const SizedBox(height: 12),
            Text('Oxirgi yangilanish: ${_time(loc.at)}',
                style: const TextStyle(fontSize: 11.5, color: JB_GRAY_LIGHT)),
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

  Widget _statCard(
      IconData icon, String label, String value, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: JB_CHIP_BG,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          JBIconTile(icon: icon, bg: bg, fg: color, size: 36, radius: 12),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 11, color: JB_GRAY)),
                const SizedBox(height: 3),
                Text(value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: JB_INK)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
