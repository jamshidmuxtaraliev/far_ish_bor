import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/theme/jb_ui.dart';
import '../../../../core/utils/geo_utils.dart';
import '../../data/models/interview_model.dart';
import '../logic/interview_bloc.dart';
import '../../../../core/theme/jb_palette.dart';

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
      backgroundColor: context.jb.bg,
      appBar: AppBar(
        backgroundColor: context.jb.card,
        foregroundColor: context.jb.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Kuzatish',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: context.jb.ink)),
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
      'on_way' => (jb.amberBg, jb.amber),
      'arrived' => (jb.greenBg, jb.green),
      _ => (jb.chipBg, jb.gray),
    };
    return Container(
      width: double.infinity,
      color: jb.card,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_i.anketa?.fullname ?? 'Nomzod',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: jb.ink)),
                if ((_i.anketa?.phoneNumber ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.phone_rounded,
                          size: 14, color: jb.grayLight),
                      const SizedBox(width: 6),
                      Text(_i.anketa!.phoneNumber!,
                          style: TextStyle(fontSize: 13, color: jb.gray)),
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
      color: jb.amberBg,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 18, color: jb.amber),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 12.5,
                    color: jb.amber,
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
          color: jb.amber,
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
      decoration: BoxDecoration(
        color: jb.card,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: jb.amber),
                ),
                SizedBox(width: 10),
                Text('Nomzod lokatsiyani ulashishini kutilmoqda…',
                    style: TextStyle(fontSize: 13, color: jb.gray)),
              ],
            )
          else ...[
            if (_hasUs)
              Row(
                children: [
                  Expanded(
                      child: _statCard(Icons.timer_outlined, 'Yetib borish',
                          _eta(loc), jb.blue, jb.blueTint)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _statCard(Icons.straighten_rounded, 'Masofa',
                          _distance(loc), jb.amber, jb.amberBg)),
                ],
              )
            else
              Text('Faqat nomzod nuqtasi ko\'rsatilmoqda',
                  style: TextStyle(fontSize: 13, color: jb.gray)),
            const SizedBox(height: 12),
            Text('Oxirgi yangilanish: ${_time(loc.at)}',
                style: TextStyle(fontSize: 11.5, color: jb.grayLight)),
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
        color: jb.chipBg,
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
                    style: TextStyle(fontSize: 11, color: jb.gray)),
                const SizedBox(height: 3),
                Text(value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: jb.ink)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
