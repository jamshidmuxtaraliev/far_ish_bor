import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../../core/utils/utils.dart';
import '../../../auth/data/models/anketa_models.dart';
import '../../../auth/data/models/branch_model.dart';
import '../../../auth/data/models/employer_model.dart';
import '../../../auth/presentation/logic/auth_bloc.dart';
import '../../../../core/theme/jb_palette.dart';
import 'branch_form_screen.dart';
import 'map_location_picker_screen.dart';

class EditEmployerScreen extends StatefulWidget {
  const EditEmployerScreen({super.key});

  @override
  State<EditEmployerScreen> createState() => _EditEmployerScreenState();
}

/// Server cheklovi — bitta kompaniyada eng ko'pi 100 ta filial.
const int _kMaxBranches = 100;

/// Telefon maskasi — faqat 9 xonali lokal qism. '+998' maskaga KIRMAYDI, u
/// maydonning o'zgarmas prefiksi (`prefixText`) bo'lib doim ko'rinib turadi,
/// shuning uchun foydalanuvchi uni o'chirib yuborolmaydi.
const String _kPhoneMask = '(##) ### ## ##';

/// STIR (INN) — O'zbekistonda har doim 9 ta raqam (public sayt ham shu cheklov
/// bilan ishlaydi: `public-site/src/views/employer/Company.vue`).
const int _kTinLength = 9;

class _EditEmployerScreenState extends State<EditEmployerScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _phone2Controller = TextEditingController();
  final _tinController = TextEditingController();
  final _addressController = TextEditingController();

  /// Qo'shimcha telefon maskasi — kiritilgan raqam '(90) 123 45 67' ko'rinishiga
  /// keltiriladi, '+998' esa maydon prefiksi sifatida doim turadi.
  late final MaskTextInputFormatter _phone2Mask;

  /// Xaritadan tanlangan koordinata — API'ga `latitude` / `longitude` bo'lib
  /// yuboriladi.
  double? _latitude;
  double? _longitude;

  /// Serverdan kelgan dastlabki koordinata — foydalanuvchi uni o'chirganini
  /// aniqlab, API'ga bo'shatish uchun `null` yuborish kerakligini biladi.
  bool _hadCoords = false;

  RegionModel? _selectedRegion;
  DistrictModel? _selectedDistrict;
  bool _isAllRegions = false;
  List<CoverageRegionModel> _coverageRegions = [];

  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    _phone2Mask = MaskTextInputFormatter(
      mask: _kPhoneMask,
      filter: {'#': RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy,
    );
    final bloc = context.read<AuthBloc>();
    bloc.add(LoadEmployerEvent());
    bloc.add(LoadRegionsEvent());
    bloc.add(LoadBranchesEvent());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactPersonController.dispose();
    _phone2Controller.dispose();
    _tinController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _prefillFromEmployer(EmployerModel employer, List<RegionModel> regions) {
    if (_prefilled) return;
    _prefilled = true;

    _nameController.text = employer.name;
    _contactPersonController.text = employer.contactPerson ?? '';
    _setPhone2(employer.phone2);
    // Eski yozuvlarda STIR probel/tire bilan saqlangan bo'lishi mumkin —
    // faqat raqamlarini qoldiramiz. Uzunligini KESMAYMIZ: 9 tadan uzun
    // eski qiymat hisoblagich va validatorda ko'rinib tursin.
    _tinController.text = (employer.tin ?? '').replaceAll(RegExp(r'\D'), '');
    _addressController.text = employer.address ?? '';
    _latitude = employer.latitude;
    _longitude = employer.longitude;
    _hadCoords = _latitude != null && _longitude != null;
    _isAllRegions = employer.isAllRegions;
    _coverageRegions = List.from(employer.coverageRegions);

    if (employer.regionId != null && regions.isNotEmpty) {
      _selectedRegion = regions.firstWhere(
        (r) => r.id == employer.regionId,
        orElse: () => regions.first,
      );
      if (employer.districtId != null && _selectedRegion != null) {
        _selectedDistrict = _selectedRegion!.districts.firstWhere(
          (d) => d.id == employer.districtId,
          orElse: () => _selectedRegion!.districts.first,
        );
      }
    }
  }

  /// Serverdan kelgan raqamdan 9 xonali lokal qismni ajratadi:
  /// `+998 (90) 778-87-69` · `998907788769` · `907788769` → `907788769`.
  String _localPhoneDigits(String? raw) {
    final d = (raw ?? '').replaceAll(RegExp(r'\D'), '');
    if (d.length > 9) return d.substring(d.length - 9);
    return d;
  }

  /// Maskani ham, kontrollerni ham bir vaqtda to'ldiradi — matnni kontrollerga
  /// to'g'ridan-to'g'ri yozish maska ichki holatini eskirtirib qo'yadi.
  void _setPhone2(String? raw) {
    final local = _localPhoneDigits(raw);
    if (local.isEmpty) {
      _phone2Mask.clear();
      _phone2Controller.text = '';
      return;
    }
    // ⚠ `mask:` qayta berilishi SHART — `updateMask` uni har safar qaytadan
    // o'rnatadi va berilmasa maska `null` bo'lib qoladi.
    final v = _phone2Mask.updateMask(
      mask: _kPhoneMask,
      newValue: TextEditingValue(text: local),
    );
    _phone2Controller.text = v.text;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final phone2Digits = _localPhoneDigits(_phone2Controller.text);

    // ⚠ Maydonlar HAR DOIM yuboriladi (bo'sh bo'lsa ham): server bo'sh satrni
    // `null` deb yozadi. Ilgari bo'sh maydon umuman yuborilmasdi — foydalanuvchi
    // manzilni o'chirib saqlasa, serverdagi eskisi qaytib kelaverardi.
    final data = <String, dynamic>{
      'name': _nameController.text.trim(),
      'contact_person': _contactPersonController.text.trim(),
      // Serverga har doim bir xil ko'rinishda ketadi: `+998901234567`
      // (public sayt ham shunday yuboradi). Bo'sh bo'lsa — bo'sh satr.
      'phone2': phone2Digits.isEmpty ? '' : '+998$phone2Digits',
      'tin': _tinController.text.trim(),
      'address': _addressController.text.trim(),
      if (_latitude != null && _longitude != null) ...{
        'latitude': _latitude,
        'longitude': _longitude,
      } else if (_hadCoords) ...{
        // Xaritadagi nuqta olib tashlandi — serverdagi eskisi ham tozalansin.
        'latitude': null,
        'longitude': null,
      },
      if (_selectedRegion != null) 'region_id': _selectedRegion!.id,
      if (_selectedDistrict != null) 'district_id': _selectedDistrict!.id,
      'is_all_regions': _isAllRegions,
      if (!_isAllRegions)
        'coverage_regions': _coverageRegions.map((c) => c.toJson()).toList(),
    };

    context.read<AuthBloc>().add(UpdateEmployerEvent(data));
  }

  Future<void> _pickOnMap() async {
    final picked = await pickLocationOnMap(
      context,
      initialLat: _latitude,
      initialLng: _longitude,
      title: 'Kompaniya manzili',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _latitude = picked.latitude;
      _longitude = picked.longitude;
    });
    // Qo'lda yozilgan manzilni bosib ketmaymiz: bo'sh bo'lsa o'zi to'ladi,
    // to'lgan bo'lsa almashtirishni TAKLIF qilamiz (foydalanuvchi hal qiladi).
    _applyPickedAddress(picked.address);
  }

  /// Xaritadan topilgan manzilni manzil maydoniga qo'yadi yoki taklif qiladi.
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

  /// Manzil koordinatasini xaritadan tanlash tugmasi.
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
                        : 'Manzilni xaritadan belgilash',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: p.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    hasCoords
                        ? '${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}'
                        : 'Koordinata yuborilmaydi',
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

  void _showCoverageRegionPicker() {
    final regions = context.read<AuthBloc>().state.regions;
    if (regions.isEmpty) return;

    RegionModel? pickerRegion;
    DistrictModel? pickerDistrict;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: jb.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Qamrov hududi qo\'shish',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: jb.ink,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<RegionModel>(
                  initialValue: pickerRegion,
                  decoration: _inputDecoration('Viloyat'),
                  isExpanded: true,
                  items: regions
                      .map((r) => DropdownMenuItem(value: r, child: Text(r.name)))
                      .toList(),
                  onChanged: (v) => setModalState(() {
                    pickerRegion = v;
                    pickerDistrict = null;
                  }),
                ),
                const SizedBox(height: 12),
                if (pickerRegion != null && pickerRegion!.districts.isNotEmpty)
                  DropdownButtonFormField<DistrictModel>(
                    initialValue: pickerDistrict,
                    decoration: _inputDecoration('Tuman (ixtiyoriy)'),
                    isExpanded: true,
                    items: pickerRegion!.districts
                        .map((d) => DropdownMenuItem(value: d, child: Text(d.name)))
                        .toList(),
                    onChanged: (v) => setModalState(() => pickerDistrict = v),
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: jb.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: pickerRegion == null
                        ? null
                        : () {
                            final cr = CoverageRegionModel(
                              regionId: pickerRegion!.id,
                              districtId: pickerDistrict?.id,
                              region: pickerRegion,
                              district: pickerDistrict,
                            );
                            final alreadyExists = _coverageRegions.any(
                              (c) =>
                                  c.regionId == cr.regionId &&
                                  c.districtId == cr.districtId,
                            );
                            if (!alreadyExists) {
                              setState(() => _coverageRegions.add(cr));
                            }
                            Navigator.pop(ctx);
                          },
                    child: const Text('Qo\'shish'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label, {
    String? prefixText,
    String? hintText,
    bool floatLabel = false,
  }) =>
      InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: jb.gray, fontSize: 14),
        // Prefiks faqat yorliq "suzib" turganda ko'rinadi — '+998' doim
        // ko'rinishi uchun yorliqni majburan suzdiramiz.
        floatingLabelBehavior:
            floatLabel ? FloatingLabelBehavior.always : null,
        prefixText: prefixText,
        prefixStyle: TextStyle(
          color: jb.ink,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        hintText: hintText,
        hintStyle: TextStyle(color: jb.gray, fontSize: 15),
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.jb.overlay,
      child: Scaffold(
        backgroundColor: context.jb.bg,
        body: BlocConsumer<AuthBloc, AuthState>(
          listenWhen: (prev, curr) =>
              prev.updateEmployerStatus != curr.updateEmployerStatus ||
              prev.uploadLogoStatus != curr.uploadLogoStatus ||
              prev.deleteBranchStatus != curr.deleteBranchStatus,
          listener: (context, state) {
            if (state.updateEmployerStatus.isSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Kompaniya ma\'lumotlari saqlandi'),
                  backgroundColor: context.jb.green,
                ),
              );
              Navigator.pop(context);
            } else if (state.updateEmployerStatus.isFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error?.errorMessage ?? 'Xatolik yuz berdi'),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state.deleteBranchStatus.isSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Filial o\'chirildi'),
                  backgroundColor: context.jb.green,
                ),
              );
            } else if (state.deleteBranchStatus.isFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error?.errorMessage ?? 'Filial o\'chirilmadi'),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state.uploadLogoStatus.isSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Logo yangilandi'),
                  backgroundColor: context.jb.green,
                ),
              );
            } else if (state.uploadLogoStatus.isFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error?.errorMessage ?? 'Logo yuklanmadi'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            final employer = state.employer;
            final regions = state.regions;

            if (employer != null && regions.isNotEmpty) {
              _prefillFromEmployer(employer, regions);
            }

            final isLoading = state.employerStatus.isInProgress;
            final isSaving = state.updateEmployerStatus.isInProgress;
            final isLogoUploading = state.uploadLogoStatus.isInProgress;

            return CustomScrollView(
              slivers: [
                _buildAppBar(context, isSaving),
                if (isLoading)
                  SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: context.jb.blue),
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLogoSection(
                              employer?.logoUrl,
                              isLogoUploading,
                            ),
                            const SizedBox(height: 16),
                            _buildSection(
                              'Asosiy ma\'lumotlar',
                              [
                                TextFormField(
                                  controller: _nameController,
                                  decoration:
                                      _inputDecoration('Kompaniya nomi *'),
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? 'Majburiy maydon'
                                          : null,
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _contactPersonController,
                                  decoration:
                                      _inputDecoration('Kontakt shaxs'),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _phone2Controller,
                                  decoration: _inputDecoration(
                                    'Qo\'shimcha telefon',
                                    prefixText: '+998 ',
                                    hintText: '(90) 123 45 67',
                                    floatLabel: true,
                                  ),
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [_phone2Mask],
                                  // Ixtiyoriy maydon: bo'sh bo'lsa xato
                                  // yo'q, lekin boshlangan raqam to'liq
                                  // bo'lishi shart.
                                  validator: (v) {
                                    final d = _localPhoneDigits(v);
                                    if (d.isEmpty) return null;
                                    return d.length == 9
                                        ? null
                                        : 'Raqamni to\'liq kiriting';
                                  },
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _tinController,
                                  decoration: _inputDecoration(
                                    'STIR (INN)',
                                    hintText: '123456789',
                                  ),
                                  keyboardType: TextInputType.number,
                                  maxLength: _kTinLength,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(
                                      _kTinLength,
                                    ),
                                  ],
                                  validator: (v) {
                                    final d = (v ?? '').trim();
                                    if (d.isEmpty) return null;
                                    return d.length == _kTinLength
                                        ? null
                                        : 'STIR $_kTinLength ta raqamdan iborat';
                                  },
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _addressController,
                                  decoration: _inputDecoration('Manzil'),
                                  maxLines: 2,
                                  // employers.address — VARCHAR(255)
                                  maxLength: 255,
                                ),
                                const SizedBox(height: 12),
                                _buildMapPickerTile(),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildSection(
                              'Joylashuv',
                              [
                                DropdownButtonFormField<RegionModel>(
                                  initialValue: _selectedRegion,
                                  decoration: _inputDecoration('Viloyat'),
                                  isExpanded: true,
                                  hint: const Text('Viloyatni tanlang'),
                                  items: regions
                                      .map(
                                        (r) => DropdownMenuItem(
                                          value: r,
                                          child: Text(r.name),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) => setState(() {
                                    _selectedRegion = v;
                                    _selectedDistrict = null;
                                  }),
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
                                        .map(
                                          (d) => DropdownMenuItem(
                                            value: d,
                                            child: Text(d.name),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) =>
                                        setState(() => _selectedDistrict = v),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildBranchesSection(state.branches),
                            const SizedBox(height: 16),
                            _buildCoverageSection(),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: context.jb.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: isSaving ? null : _save,
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
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isSaving) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: context.jb.card,
      surfaceTintColor: context.jb.card,
      foregroundColor: context.jb.ink,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      title: const Text(
        'Kompaniya ma\'lumotlari',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        onPressed: isSaving ? null : () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: jb.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: jb.gray,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLogoSection(String? logoUrl, bool isUploading) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: jb.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kompaniya logosi',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: jb.gray,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: jb.cardAlt,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: jb.border),
                    image: logoUrl != null
                        ? DecorationImage(
                            image: NetworkImage(logoUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: logoUrl == null
                      ? Icon(
                          Icons.business_outlined,
                          size: 40,
                          color: jb.gray,
                        )
                      : null,
                ),
                if (isUploading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: _pickAndUploadLogo,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: jb.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Logo yuklash uchun bosing',
              style: TextStyle(fontSize: 12, color: jb.gray),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadLogo() async {
    final picked = await pickImageWithSourceSheet(context);
    if (picked == null) return;
    if (!mounted) return;
    context.read<AuthBloc>().add(UploadLogoEvent(picked.path));
  }

  /// Kompaniyaning qo'shimcha manzillari. Filialda faqat manzil bo'ladi —
  /// telefon, tarif, balans va vakansiyalar kompaniya darajasida qoladi.
  Widget _buildBranchesSection(List<BranchModel> branches) {
    final p = context.jb;
    final canAdd = branches.length < _kMaxBranches;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Filiallar (qo\'shimcha manzillar)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: p.gray,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (branches.isNotEmpty)
                Text(
                  '${branches.length}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: p.blue,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Kompaniya bir nechta joyda ishlasa — har bir manzilni qo\'shing.',
            style: TextStyle(fontSize: 12, color: p.gray),
          ),
          const SizedBox(height: 12),
          if (branches.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              decoration: BoxDecoration(
                color: p.cardAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: p.border),
              ),
              child: Text(
                'Filial yo\'q — kompaniya faqat asosiy manzilda ishlaydi.',
                style: TextStyle(fontSize: 13, color: p.gray),
              ),
            )
          else
            ...branches.asMap().entries.map(
                  (e) => _buildBranchTile(e.value, e.key),
                ),
          const SizedBox(height: 4),
          TextButton.icon(
            onPressed: canAdd ? () => _openBranchForm() : null,
            icon: Icon(Icons.add, color: canAdd ? p.blue : p.gray, size: 18),
            label: Text(
              canAdd
                  ? 'Filial qo\'shish'
                  : 'Filiallar soni $_kMaxBranches tadan oshmasligi kerak',
              style: TextStyle(color: canAdd ? p.blue : p.gray, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchTile(BranchModel branch, int index) {
    final p = context.jb;
    final line = branch.addressLine;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
      decoration: BoxDecoration(
        color: branch.isActive ? p.blueTint : p.cardAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: branch.isActive ? p.blue.withValues(alpha: 0.2) : p.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(Icons.location_on_outlined,
                color: branch.isActive ? p.blue : p.gray, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        branch.title(index),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: p.ink,
                        ),
                      ),
                    ),
                    if (!branch.isActive) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: p.chipBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Yashirilgan',
                          style: TextStyle(fontSize: 11, color: p.gray),
                        ),
                      ),
                    ],
                  ],
                ),
                if (line.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(line, style: TextStyle(fontSize: 13, color: p.ink)),
                ],
                const SizedBox(height: 3),
                Text(
                  branch.coordsLine,
                  style: TextStyle(fontSize: 12, color: p.gray),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Tahrirlash',
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.edit_outlined, size: 18, color: p.gray),
            onPressed: () => _openBranchForm(branch: branch),
          ),
          IconButton(
            tooltip: 'O\'chirish',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
            onPressed: () => _confirmDeleteBranch(branch, index),
          ),
        ],
      ),
    );
  }

  Future<void> _openBranchForm({BranchModel? branch}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BranchFormScreen(
          branch: branch,
          employer: context.read<AuthBloc>().state.employer,
        ),
      ),
    );
    if (saved != true || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(branch == null ? 'Filial qo\'shildi' : 'Filial yangilandi'),
        backgroundColor: context.jb.green,
      ),
    );
  }

  Future<void> _confirmDeleteBranch(BranchModel branch, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: jb.card,
        title: Text(
          'Filial o\'chirilsinmi?',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w800, color: jb.ink),
        ),
        content: Text(
          '${branch.title(index)} butunlay o\'chiriladi va qayta tiklanmaydi. '
          'Vaqtincha yashirish uchun tahrirlashdagi "Faol" tugmasidan foydalaning.',
          style: TextStyle(fontSize: 13.5, color: jb.gray, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Bekor qilish', style: TextStyle(color: jb.gray)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('O\'chirish', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    context.read<AuthBloc>().add(DeleteBranchEvent(branch.id));
  }

  Widget _buildCoverageSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: jb.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Qamrov hududlari',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: jb.gray,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Nomzod qidiriladigan hududlar',
            style: TextStyle(fontSize: 12, color: jb.gray),
          ),
          const SizedBox(height: 12),
          // "Butun O'zbekiston" toggle
          GestureDetector(
            onTap: () => setState(() => _isAllRegions = !_isAllRegions),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _isAllRegions
                    ? jb.blue.withValues(alpha: 0.08)
                    : jb.cardAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isAllRegions
                      ? jb.blue.withValues(alpha: 0.4)
                      : jb.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isAllRegions
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: _isAllRegions ? jb.blue : jb.gray,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Butun O\'zbekiston bo\'yicha',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: jb.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!_isAllRegions) ...[
            const SizedBox(height: 12),
            if (_coverageRegions.isNotEmpty) ...[
              ..._coverageRegions.asMap().entries.map(
                    (entry) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: jb.blueTint,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: jb.blue.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              color: jb.blue, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entry.value.displayName,
                              style: TextStyle(
                                  fontSize: 13, color: jb.ink),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() =>
                                _coverageRegions.removeAt(entry.key)),
                            child: Icon(Icons.close,
                                color: jb.gray, size: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
              const SizedBox(height: 4),
            ],
            TextButton.icon(
              onPressed: _showCoverageRegionPicker,
              icon: Icon(Icons.add, color: jb.blue, size: 18),
              label: Text(
                'Hudud qo\'shish',
                style: TextStyle(color: jb.blue, fontSize: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
