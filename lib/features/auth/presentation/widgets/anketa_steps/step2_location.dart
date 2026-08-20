import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../data/models/anketa_models.dart';
import '../../logic/auth_bloc.dart';
import '../../../../../core/theme/jb_palette.dart';

class Step2Location extends StatelessWidget {
  final RegionModel? selectedRegion;
  final DistrictModel? selectedDistrict;
  final ValueChanged<RegionModel?> onRegionChanged;
  final ValueChanged<DistrictModel?> onDistrictChanged;

  const Step2Location({
    super.key,
    required this.selectedRegion,
    required this.selectedDistrict,
    required this.onRegionChanged,
    required this.onDistrictChanged,
  });

  void _showRegionPicker(BuildContext context, List<RegionModel> regions) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SearchableBottomSheet<RegionModel>(
        title: 'Viloyat tanlang',
        items: regions,
        itemLabel: (r) => r.name,
        onSelected: (r) {
          onRegionChanged(r);
          onDistrictChanged(null);
        },
      ),
    );
  }

  void _showDistrictPicker(BuildContext context, List<DistrictModel> districts) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SearchableBottomSheet<DistrictModel>(
        title: 'Tuman tanlang',
        items: districts,
        itemLabel: (d) => d.name,
        onSelected: onDistrictChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (p, c) => p.regions != c.regions || p.regionsStatus != c.regionsStatus,
      builder: (context, state) {
        final isLoading = state.regionsStatus.isInProgress;
        final districts = selectedRegion?.districts ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _SectionCard(
                children: [
                  const _FieldLabel('Viloyat'),
                  const SizedBox(height: 8),
                  isLoading
                      ? const _LoadingField()
                      : _SelectField(
                          value: selectedRegion?.name,
                          hint: 'Viloyatni tanlang',
                          icon: Icons.location_city_outlined,
                          onTap: () => _showRegionPicker(context, state.regions),
                        ),
                  const SizedBox(height: 16),
                  const _FieldLabel('Tuman / Shahar'),
                  const SizedBox(height: 8),
                  _SelectField(
                    value: selectedDistrict?.name,
                    hint: selectedRegion == null ? 'Avval viloyat tanlang' : 'Tumanni tanlang',
                    icon: Icons.location_on_outlined,
                    enabled: selectedRegion != null && districts.isNotEmpty,
                    onTap: selectedRegion != null ? () => _showDistrictPicker(context, districts) : null,
                  ),
                ],
              ),
              if (selectedRegion != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: context.jb.blue.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.jb.blue.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: context.jb.blue, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${selectedRegion!.name}${selectedDistrict != null ? ', ${selectedDistrict!.name}' : ''}',
                          style: TextStyle(color: context.jb.blue, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SearchableBottomSheet<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T> onSelected;

  const _SearchableBottomSheet({
    required this.title,
    required this.items,
    required this.itemLabel,
    required this.onSelected,
  });

  @override
  State<_SearchableBottomSheet<T>> createState() => _SearchableBottomSheetState<T>();
}

class _SearchableBottomSheetState<T> extends State<_SearchableBottomSheet<T>> {
  final _searchController = TextEditingController();
  List<T> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
    _searchController.addListener(_onSearch);
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? widget.items
          : widget.items.where((i) => widget.itemLabel(i).toLowerCase().contains(q)).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: context.jb.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: context.jb.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Text(widget.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.jb.ink)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: TextStyle(fontSize: 15, color: context.jb.ink),
                    decoration: InputDecoration(
                      hintText: 'Qidirish...',
                      hintStyle: TextStyle(color: context.jb.gray),
                      prefixIcon: Icon(Icons.search, color: context.jb.gray, size: 20),
                      filled: true,
                      fillColor: context.jb.bg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.jb.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.jb.border)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.jb.blue, width: 1.5)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                controller: controller,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _filtered.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: context.jb.cardAlt),
                itemBuilder: (_, i) {
                  final item = _filtered[i];
                  return InkWell(
                    onTap: () {
                      widget.onSelected(item);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(widget.itemLabel(item), style: TextStyle(fontSize: 15, color: context.jb.ink)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;

  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.jb.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.jb.ink));
  }
}

class _SelectField extends StatelessWidget {
  final String? value;
  final String hint;
  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;

  const _SelectField({
    required this.hint,
    required this.icon,
    this.value,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: enabled ? context.jb.bg : context.jb.cardAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: value != null ? context.jb.blue.withValues(alpha: 0.4) : context.jb.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: value != null ? context.jb.blue : context.jb.gray, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value ?? hint,
                style: TextStyle(color: value != null ? context.jb.ink : context.jb.gray, fontSize: 15),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, color: enabled ? context.jb.gray : context.jb.borderStrong, size: 20),
          ],
        ),
      ),
    );
  }
}

class _LoadingField extends StatelessWidget {
  const _LoadingField();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: context.jb.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.jb.border),
      ),
      child: Row(
        children: [
          SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: context.jb.blue)),
          SizedBox(width: 10),
          Text('Yuklanmoqda...', style: TextStyle(color: context.jb.gray, fontSize: 15)),
        ],
      ),
    );
  }
}
