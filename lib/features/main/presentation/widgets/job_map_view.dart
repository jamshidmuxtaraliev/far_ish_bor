import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../../../../core/constants/colors.dart';
import '../../data/models/vacancy_model.dart';
import 'job_map_markers.dart';

/// Ish izlovchi "Ishlar" oynasining xarita ko'rinishi.
///
/// Vakansiyalar Yandex xaritasida point marker'lar sifatida ko'rsatiladi. Zoom
/// uzoqda bo'lsa ular klasterlarga (ish soni bilan) guruhlanadi; yaqinlashganda
/// har bir ish custom [JobMapMarkers.jobPin] markeri bilan chiqadi. Markerni
/// bosganda ish beruvchi, maosh va lavozim haqida qisqacha dialog ochiladi;
/// dialogni bosganda esa [onOpenJob] orqali batafsil oynaga o'tiladi.
class JobMapView extends StatefulWidget {
  final List<VacancyModel> vacancies;
  final void Function(VacancyModel vacancy) onOpenJob;

  const JobMapView({super.key, required this.vacancies, required this.onOpenJob});

  @override
  State<JobMapView> createState() => _JobMapViewState();
}

class _JobMapViewState extends State<JobMapView> {
  // Toshkent markazi — koordinatasiz holatlar uchun standart nuqta.
  static const Point _tashkent = Point(latitude: 41.311081, longitude: 69.240562);

  YandexMapController? _controller;
  BitmapDescriptor? _jobIcon;
  double _dpr = 3;
  List<VacancyModel> _located = const [];
  VacancyModel? _selected;
  bool _ready = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dpr = MediaQuery.of(context).devicePixelRatio;
    _located = widget.vacancies.where((v) => v.hasCoords).toList();
    if (!_ready) {
      _ready = true;
      _prepareIcon();
    }
  }

  @override
  void didUpdateWidget(covariant JobMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.vacancies, widget.vacancies)) {
      setState(() => _located = widget.vacancies.where((v) => v.hasCoords).toList());
    }
  }

  Future<void> _prepareIcon() async {
    final icon = await JobMapMarkers.jobPin(_dpr);
    if (mounted) setState(() => _jobIcon = icon);
  }

  Point _initialTarget() {
    if (_located.isEmpty) return _tashkent;
    double lat = 0, lng = 0;
    for (final v in _located) {
      lat += v.latitude!;
      lng += v.longitude!;
    }
    return Point(latitude: lat / _located.length, longitude: lng / _located.length);
  }

  List<PlacemarkMapObject> _placemarks() {
    final icon = _jobIcon;
    if (icon == null) return const [];
    return _located.map((v) {
      return PlacemarkMapObject(
        mapId: MapObjectId('job_${v.id}'),
        point: Point(latitude: v.latitude!, longitude: v.longitude!),
        opacity: 1,
        consumeTapEvents: true, // tap onMapTap'ga tarqalmasin (dialog o'chib qolmasligi uchun)
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            image: icon,
            anchor: const Offset(0.5, 1.0), // pin uchi — nuqtada
            scale: 1 / _dpr,
          ),
        ),
        onTap: (_, __) => _onJobTap(v),
      );
    }).toList();
  }

  void _onJobTap(VacancyModel v) {
    setState(() => _selected = v);
    _controller?.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: Point(latitude: v.latitude!, longitude: v.longitude!), zoom: 16),
      ),
      animation: const MapAnimation(type: MapAnimationType.smooth, duration: 0.35),
    );
  }

  Future<Cluster> _onClusterAdded(ClusterizedPlacemarkCollection self, Cluster cluster) async {
    final icon = await JobMapMarkers.cluster(cluster.size, _dpr);
    return cluster.copyWith(
      appearance: cluster.appearance.copyWith(
        opacity: 1,
        icon: PlacemarkIcon.single(PlacemarkIconStyle(image: icon, scale: 1 / _dpr)),
      ),
    );
  }

  Future<void> _onClusterTap(ClusterizedPlacemarkCollection self, Cluster cluster) async {
    final pos = await _controller?.getCameraPosition();
    final zoom = (pos?.zoom ?? 11) + 2;
    await _controller?.moveCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: cluster.appearance.point, zoom: zoom)),
      animation: const MapAnimation(type: MapAnimationType.smooth, duration: 0.4),
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

  @override
  Widget build(BuildContext context) {
    final collection = ClusterizedPlacemarkCollection(
      mapId: const MapObjectId('jobs_cluster'),
      placemarks: _placemarks(),
      radius: 60,
      minZoom: 15,
      consumeTapEvents: true,
      onClusterAdded: _onClusterAdded,
      onClusterTap: _onClusterTap,
    );

    return Stack(
      children: [
        YandexMap(
          nightModeEnabled: true, // dizayn — to'q xarita (screenshot)
          mapObjects: [collection],
          onMapCreated: (c) {
            _controller = c;
            c.moveCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(target: _initialTarget(), zoom: _located.isEmpty ? 11 : 12),
              ),
            );
          },
          onMapTap: (_) {
            if (_selected != null) setState(() => _selected = null);
          },
        ),

        // Yuklanish holati (marker ikonasi tayyorlanmagan bo'lsa)
        if (_jobIcon == null)
          const Positioned.fill(
            child: IgnorePointer(child: Center(child: CircularProgressIndicator(color: PRIMARY_BLUE))),
          ),

        // Zoom tugmalari
        Positioned(
          right: 16,
          bottom: 120,
          child: Column(
            children: [
              _ZoomButton(icon: Icons.add, onTap: () => _zoom(1)),
              const SizedBox(height: 10),
              _ZoomButton(icon: Icons.remove, onTap: () => _zoom(-1)),
            ],
          ),
        ),

        // Marker bosilganda qisqacha info dialogi
        if (_selected != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 92,
            child: _JobInfoCard(
              vacancy: _selected!,
              onClose: () => setState(() => _selected = null),
              onTap: () => widget.onOpenJob(_selected!),
            ),
          ),
      ],
    );
  }
}

class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ZoomButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1F2937),
      borderRadius: BorderRadius.circular(12),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(width: 46, height: 46, child: Icon(icon, color: Colors.white, size: 24)),
      ),
    );
  }
}

/// Screenshot 3'dagi kabi — marker bosilganda chiqadigan kichik ma'lumot kartasi.
class _JobInfoCard extends StatelessWidget {
  final VacancyModel vacancy;
  final VoidCallback onClose;
  final VoidCallback onTap;

  const _JobInfoCard({required this.vacancy, required this.onClose, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final logo = vacancy.companyLogo;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 18, offset: const Offset(0, 6)),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: RED_COLOR.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                clipBehavior: Clip.antiAlias,
                child: (logo != null && logo.isNotEmpty)
                    ? Image.network(
                        logo,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.work_rounded, color: RED_COLOR, size: 26),
                      )
                    : const Icon(Icons.work_rounded, color: RED_COLOR, size: 26),
              ),
              const SizedBox(width: 12),
              // Matn
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vacancy.jobTypeName ?? "Kasb ko'rsatilmagan",
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: DARK_NAVY),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      vacancy.companyName ?? '',
                      style: const TextStyle(fontSize: 13, color: GRAY_TEXT),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.payments_outlined, size: 15, color: PRIMARY_BLUE),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            vacancy.salaryDisplay,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: PRIMARY_BLUE),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Yopish
              IconButton(
                onPressed: onClose,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close, size: 20, color: GRAY_TEXT),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
