import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/theme/jb_palette.dart';
import '../../../auth/data/models/anketa_models.dart';
import '../../../auth/data/models/branch_model.dart';
import '../../../auth/data/models/employer_model.dart';
import '../../../auth/presentation/logic/auth_bloc.dart';
import 'map_location_picker_screen.dart';

/// Filial (qo'shimcha manzil) qo'shish/tahrirlash formasi.
///
/// Yangi filialda viloyat/tuman kompaniyanikidan oldindan to'ldiriladi —
/// foydalanuvchi odatda faqat manzil matnini yozadi. Tahrirlashda `PATCH`
/// yuboriladi: faqat o'zgargan maydonlar ketadi, qolgani serverda tegilmaydi.
class BranchFormScreen extends StatefulWidget {
  /// `null` bo'lsa — yangi filial qo'shiladi.
  final BranchModel? branch;
  final EmployerModel? employer;

  const BranchFormScreen({super.key, this.branch, this.employer});

  @override
  State<BranchFormScreen> createState() => _BranchFormScreenState();
}

class _BranchFormScreenState extends State<BranchFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  RegionModel? _selectedRegion;
  DistrictModel? _selectedDistrict;
  double? _latitude;
  double? _longitude;
  bool _isActive = true;

  bool _prefilled = false;

  bool get _isEdit => widget.branch != null;

  @override
  void initState() {
    super.initState();
    final b = widget.branch;
    _nameController.text = b?.name ?? '';
    _addressController.text = b?.address ?? '';
    _latitude = b?.latitude;
    _longitude = b?.longitude;
    _isActive = b?.isActive ?? true;
    context.read<AuthBloc>().add(LoadRegionsEvent());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  /// Hudud dropdownlari ro'yxat yuklanib bo'lgach bir marta to'ldiriladi:
  /// tahrirda — filialning o'z hududi, yangi filialda — kompaniyaniki.
  void _prefillRegions(List<RegionModel> regions) {
    if (_prefilled || regions.isEmpty) return;
    _prefilled = true;

    final regionId = widget.branch?.regionId ?? widget.employer?.regionId;
    final districtId = widget.branch?.districtId ?? widget.employer?.districtId;
    if (regionId == null) return;

    RegionModel? region;
    for (final r in regions) {
      if (r.id == regionId) region = r;
    }
    if (region == null) return;
    _selectedRegion = region;
    if (districtId != null) {
      for (final d in region.districts) {
        if (d.id == districtId) _selectedDistrict = d;
      }
    }
  }

  Future<void> _pickOnMap() async {
    final picked = await pickLocationOnMap(
      context,
      initialLat: _latitude,
      initialLng: _longitude,
      title: 'Filial manzili',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _latitude = picked.latitude;
      _longitude = picked.longitude;
    });
    _applyPickedAddress(picked.address);
  }

  /// Xaritadan topilgan manzil: bo'sh maydon o'zi to'ladi, to'lganini
  /// almashtirishni TAKLIF qilamiz (qo'lda yozilganini bosib ketmaymiz).
  void _applyPickedAddress(String? resolved) {
    if (resolved == null || resolved.isEmpty) return;
    final current = _addressController.text.trim();
    if (current.isEmpty) {
      setState(() => _addressController.text = resolved);
      return;
    }
    if (current == resolved) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        duration: const Duration(seconds: 6),
        content: Text('Xaritada: $resolved'),
        action: SnackBarAction(
          label: 'Qo\'yish',
          onPressed: () => setState(() => _addressController.text = resolved),
        ),
      ));
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final bloc = context.read<AuthBloc>();

    if (!_isEdit) {
      bloc.add(CreateBranchEvent({
        if (name.isNotEmpty) 'name': name,
        if (_selectedRegion != null) 'region_id': _selectedRegion!.id,
        if (_selectedDistrict != null) 'district_id': _selectedDistrict!.id,
        if (address.isNotEmpty) 'address': address,
        if (_latitude != null && _longitude != null) ...{
          'latitude': _latitude,
          'longitude': _longitude,
        },
      }));
      return;
    }

    // PATCH — faqat o'zgarganini yuboramiz.
    final b = widget.branch!;
    final data = <String, dynamic>{};
    if (name != (b.name ?? '')) data['name'] = name.isEmpty ? null : name;
    if (address != (b.address ?? '')) {
      data['address'] = address.isEmpty ? null : address;
    }
    if (_selectedRegion?.id != b.regionId) {
      data['region_id'] = _selectedRegion?.id;
    }
    if (_selectedDistrict?.id != b.districtId) {
      data['district_id'] = _selectedDistrict?.id;
    }
    if (_latitude != b.latitude || _longitude != b.longitude) {
      data['latitude'] = _latitude;
      data['longitude'] = _longitude;
    }
    if (_isActive != b.isActive) data['is_active'] = _isActive;

    if (data.isEmpty) {
      Navigator.pop(context);
      return;
    }
    bloc.add(UpdateBranchEvent(b.id, data));
  }

  InputDecoration _inputDecoration(String label, {String? hint}) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: jb.gray, fontSize: 14),
        hintStyle: TextStyle(color: jb.gray, fontSize: 13.5),
        filled: true,
        fillColor: jb.cardAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: jb.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: jb.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: jb.blue, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      );

  @override
  Widget build(BuildContext context) {
    final p = context.jb;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: p.overlay,
      child: Scaffold(
        backgroundColor: p.bg,
        appBar: AppBar(
          backgroundColor: p.card,
          surfaceTintColor: p.card,
          foregroundColor: p.ink,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          title: Text(
            _isEdit ? 'Filialni tahrirlash' : 'Filial qo\'shish',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocConsumer<AuthBloc, AuthState>(
          listenWhen: (prev, curr) =>
              prev.saveBranchStatus != curr.saveBranchStatus,
          listener: (context, state) {
            if (state.saveBranchStatus.isSuccess) {
              Navigator.pop(context, true);
            } else if (state.saveBranchStatus.isFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error?.errorMessage ?? 'Xatolik yuz berdi'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            final regions = state.regions;
            _prefillRegions(regions);
            final isSaving = state.saveBranchStatus.isInProgress;

            return SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Filialda faqat manzil bo\'ladi — telefon, tarif va '
                          'vakansiyalar kompaniya darajasida qoladi.',
                          style: TextStyle(fontSize: 12.5, color: p.gray, height: 1.5),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<RegionModel>(
                          initialValue: _selectedRegion,
                          decoration: _inputDecoration('Viloyat *'),
                          isExpanded: true,
                          hint: const Text('Viloyatni tanlang'),
                          items: regions
                              .map((r) => DropdownMenuItem(value: r, child: Text(r.name)))
                              .toList(),
                          // Viloyat almashsa tuman boshqa viloyatniki bo'lib
                          // qolmasligi uchun tozalanadi.
                          onChanged: (v) => setState(() {
                            _selectedRegion = v;
                            _selectedDistrict = null;
                          }),
                          validator: (v) => v == null
                              ? 'Filial uchun viloyat tanlanishi shart'
                              : null,
                        ),
                        if (_selectedRegion != null &&
                            _selectedRegion!.districts.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          DropdownButtonFormField<DistrictModel>(
                            initialValue: _selectedDistrict,
                            decoration: _inputDecoration('Tuman'),
                            isExpanded: true,
                            hint: const Text('Tumanni tanlang'),
                            items: _selectedRegion!.districts
                                .map((d) => DropdownMenuItem(value: d, child: Text(d.name)))
                                .toList(),
                            onChanged: (v) => setState(() => _selectedDistrict = v),
                          ),
                        ],
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _addressController,
                          decoration: _inputDecoration(
                            'Manzil',
                            hint: 'Ko\'cha, uy raqami / mo\'ljal',
                          ),
                          maxLines: 2,
                          maxLength: 300,
                        ),
                        TextFormField(
                          controller: _nameController,
                          decoration: _inputDecoration(
                            'Filial nomi',
                            hint: 'Masalan: Chilonzor filiali',
                          ),
                          maxLength: 150,
                        ),
                        const SizedBox(height: 4),
                        _buildMapPickerTile(),
                        if (_isEdit) ...[
                          const SizedBox(height: 12),
                          _buildActiveSwitch(),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: p.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: isSaving ? null : _submit,
                            child: isSaving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Saqlash',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMapPickerTile() {
    final p = context.jb;
    final hasCoords = _latitude != null && _longitude != null;
    return InkWell(
      onTap: _pickOnMap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: hasCoords ? p.blueTint : p.chipBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: hasCoords ? p.blue : p.border),
        ),
        child: Row(
          children: [
            Icon(hasCoords ? Icons.place : Icons.add_location_alt_outlined,
                color: p.blue, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasCoords
                        ? 'Xaritadagi nuqta belgilangan'
                        : 'Xaritada belgilash',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: p.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    hasCoords
                        ? '${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}'
                        : 'Ixtiyoriy — koordinata yuborilmaydi',
                    style: TextStyle(fontSize: 12.5, color: p.gray),
                  ),
                ],
              ),
            ),
            if (hasCoords)
              IconButton(
                tooltip: 'Koordinatani olib tashlash',
                icon: Icon(Icons.close, size: 18, color: p.gray),
                onPressed: () => setState(() {
                  _latitude = null;
                  _longitude = null;
                }),
              )
            else
              Icon(Icons.chevron_right, color: p.gray),
          ],
        ),
      ),
    );
  }

  /// Filialni o'chirmasdan vaqtincha yashirish (`is_active`).
  Widget _buildActiveSwitch() {
    final p = context.jb;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: p.cardAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Faol',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: p.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isActive
                      ? 'Ish izlovchilarga ko\'rinadi'
                      : 'Vaqtincha yashirilgan',
                  style: TextStyle(fontSize: 12.5, color: p.gray),
                ),
              ],
            ),
          ),
          Switch(
            value: _isActive,
            activeThumbColor: p.blue,
            onChanged: (v) => setState(() => _isActive = v),
          ),
        ],
      ),
    );
  }
}
