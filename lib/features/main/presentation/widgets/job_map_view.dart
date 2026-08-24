import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../../../auth/data/models/branch_model.dart';
import '../../data/models/vacancy_model.dart';
import 'job_map_markers.dart';
import '../../../../core/theme/jb_palette.dart';

/// Ish izlovchi "Ishlar" oynasining xarita ko'rinishi.
///
/// Bitta vakansiya bir nechta pin berishi mumkin: kompaniyaning asosiy manzili
/// va har bir filial. Pin `vacancy_id + branch_id` juftligi bo'yicha unikal.
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
  List<_JobPin> _pins = const [];
  _JobPin? _selected;

  /// Marker'lar palitra rangida chizilgani uchun mavzu almashsa qaytadan
  /// chiziladi — shuning uchun oxirgi ishlatilgan palitra saqlanadi.
  JbPalette? _palette;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dpr = MediaQuery.of(context).devicePixelRatio;
    _pins = _buildPins(widget.vacancies);
    final palette = context.jb;
    if (_palette?.brightness != palette.brightness) {
      _palette = palette;
      _jobIcon = null;
      _prepareIcon();
    }
  }

  @override
  void didUpdateWidget(covariant JobMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.vacancies, widget.vacancies)) {
      setState(() => _pins = _buildPins(widget.vacancies));
    }
  }

  /// Har bir vakansiya uchun: asosiy manzil (koordinatasi bo'lsa) + har bir
  /// koordinatali filial.
  static List<_JobPin> _buildPins(List<VacancyModel> vacancies) {
    final pins = <_JobPin>[];
    for (final v in vacancies) {
      if (v.hasCoords) pins.add(_JobPin(v, null));
      for (final b in v.locatedBranches) {
        pins.add(_JobPin(v, b));
      }
    }
    return pins;
  }

  Future<void> _prepareIcon() async {
    final palette = _palette!;
    final icon = await JobMapMarkers.jobPin(_dpr, palette);
    // Ikona tayyorlanguncha mavzu yana o'zgargan bo'lishi mumkin.
    if (mounted && identical(_palette, palette)) {
      setState(() => _jobIcon = icon);
    }
  }

  Point _initialTarget() {
    if (_pins.isEmpty) return _tashkent;
    double lat = 0, lng = 0;
    for (final pin in _pins) {
      lat += pin.latitude;
      lng += pin.longitude;
    }
    return Point(latitude: lat / _pins.length, longitude: lng / _pins.length);
  }

  List<PlacemarkMapObject> _placemarks() {
    final icon = _jobIcon;
    if (icon == null) return const [];
    return _pins.map((pin) {
      return PlacemarkMapObject(
        mapId: MapObjectId(pin.mapKey),
        point: Point(latitude: pin.latitude, longitude: pin.longitude),
        opacity: 1,
        consumeTapEvents: true, // tap onMapTap'ga tarqalmasin (dialog o'chib qolmasligi uchun)
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            image: icon,
            anchor: const Offset(0.5, 1.0), // pin uchi — nuqtada
            scale: 1 / _dpr,
          ),
        ),
        onTap: (_, __) => _onJobTap(pin),
      );
    }).toList();
  }

  void _onJobTap(_JobPin pin) {
    setState(() => _selected = pin);
    _controller?.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: Point(latitude: pin.latitude, longitude: pin.longitude), zoom: 16),
      ),
      animation: const MapAnimation(type: MapAnimationType.smooth, duration: 0.35),
    );
  }

  Future<Cluster> _onClusterAdded(ClusterizedPlacemarkCollection self, Cluster cluster) async {
    final icon = await JobMapMarkers.cluster(cluster.size, _dpr, _palette ?? context.jb);
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
    final isDark = context.jb.isDark;
    // mapId mavzuni ham o'z ichiga oladi: rejim almashganda kolleksiya yangi
    // obyekt sifatida qayta quriladi va klaster ikonalari qaytadan chiziladi.
    final collection = ClusterizedPlacemarkCollection(
      mapId: MapObjectId('jobs_cluster_${isDark ? 'dark' : 'light'}'),
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
          // Xarita ilova mavzusiga ergashadi: tungi rejimda Yandex'ning o'z
          // "night mode" uslubi yoqiladi.
          nightModeEnabled: isDark,
          mapObjects: [collection],
          onMapCreated: (c) {
            _controller = c;
            c.moveCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(target: _initialTarget(), zoom: _pins.isEmpty ? 11 : 12),
              ),
            );
          },
          onMapTap: (_) {
            if (_selected != null) setState(() => _selected = null);
          },
        ),

        // Yuklanish holati (marker ikonasi tayyorlanmagan bo'lsa)
        if (_jobIcon == null)
          Positioned.fill(
            child: IgnorePointer(child: Center(child: CircularProgressIndicator(color: context.jb.blue))),
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
              vacancy: _selected!.vacancy,
              branch: _selected!.branch,
              onClose: () => setState(() => _selected = null),
              onTap: () => widget.onOpenJob(_selected!.vacancy),
            ),
          ),
      ],
    );
  }
}

/// Xaritadagi bitta nuqta: vakansiya + (bo'lsa) filial. [branch] `null` bo'lsa
/// bu kompaniyaning asosiy manzili.
class _JobPin {
  final VacancyModel vacancy;
  final BranchModel? branch;

  const _JobPin(this.vacancy, this.branch);

  double get latitude => branch?.latitude ?? vacancy.latitude!;
  double get longitude => branch?.longitude ?? vacancy.longitude!;

  /// `vacancy_id + branch_id` juftligi — pin identifikatori.
  String get mapKey => 'job_${vacancy.id}_${branch?.id ?? 'main'}';
}

class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ZoomButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.jb;
    return Material(
      color: p.card,
      borderRadius: BorderRadius.circular(12),
      elevation: 3,
      shadowColor: p.shadow,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(width: 46, height: 46, child: Icon(icon, color: p.ink, size: 24)),
      ),
    );
  }
}

/// Screenshot 3'dagi kabi — marker bosilganda chiqadigan kichik ma'lumot kartasi.
class _JobInfoCard extends StatelessWidget {
  final VacancyModel vacancy;

  /// Filial pinida bosilgan bo'lsa — o'sha filial manzili ko'rsatiladi.
  final BranchModel? branch;
  final VoidCallback onClose;
  final VoidCallback onTap;

  const _JobInfoCard({
    required this.vacancy,
    this.branch,
    required this.onClose,
    required this.onTap,
  });

  /// Filial pinida filial manzili, aks holda kompaniyaning asosiy manzili.
  String get addressLine {
    final b = branch;
    if (b == null) return vacancy.companyAddress ?? '';
    final line = b.addressLine;
    final name = b.name?.trim();
    if (name != null && name.isNotEmpty) {
      return line.isEmpty ? name : '$name · $line';
    }
    return line;
  }

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
            color: context.jb.card,
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
                  color: context.jb.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                clipBehavior: Clip.antiAlias,
                child: (logo != null && logo.isNotEmpty)
                    ? Image.network(
                        logo,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(Icons.work_rounded, color: context.jb.red, size: 26),
                      )
                    : Icon(Icons.work_rounded, color: context.jb.red, size: 26),
              ),
              const SizedBox(width: 12),
              // Matn
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vacancy.jobTypeName ?? "Kasb ko'rsatilmagan",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: context.jb.ink),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      vacancy.companyName ?? '',
                      style: TextStyle(fontSize: 13, color: context.jb.gray),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (addressLine.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 14, color: context.jb.gray),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              addressLine,
                              style: TextStyle(fontSize: 12, color: context.jb.gray),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.payments_outlined, size: 15, color: context.jb.blue),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            vacancy.salaryDisplay,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.jb.blue),
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
                icon: Icon(Icons.close, size: 20, color: context.jb.gray),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
