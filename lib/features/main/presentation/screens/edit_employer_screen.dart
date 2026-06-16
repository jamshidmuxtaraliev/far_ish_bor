import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/constants.dart';
import '../../../auth/data/models/anketa_models.dart';
import '../../../auth/data/models/employer_model.dart';
import '../../../auth/presentation/logic/auth_bloc.dart';

class EditEmployerScreen extends StatefulWidget {
  const EditEmployerScreen({super.key});

  @override
  State<EditEmployerScreen> createState() => _EditEmployerScreenState();
}

class _EditEmployerScreenState extends State<EditEmployerScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _phone2Controller = TextEditingController();
  final _tinController = TextEditingController();
  final _addressController = TextEditingController();

  RegionModel? _selectedRegion;
  DistrictModel? _selectedDistrict;
  bool _isAllRegions = false;
  List<CoverageRegionModel> _coverageRegions = [];

  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<AuthBloc>();
    bloc.add(LoadEmployerEvent());
    bloc.add(LoadRegionsEvent());
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
    _phone2Controller.text = employer.phone2 ?? '';
    _tinController.text = employer.tin ?? '';
    _addressController.text = employer.address ?? '';
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

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final data = <String, dynamic>{
      'name': _nameController.text.trim(),
      'contact_person': _contactPersonController.text.trim(),
      if (_phone2Controller.text.trim().isNotEmpty)
        'phone2': _phone2Controller.text.trim(),
      if (_tinController.text.trim().isNotEmpty)
        'tin': _tinController.text.trim(),
      if (_addressController.text.trim().isNotEmpty)
        'address': _addressController.text.trim(),
      if (_selectedRegion != null) 'region_id': _selectedRegion!.id,
      if (_selectedDistrict != null) 'district_id': _selectedDistrict!.id,
      'is_all_regions': _isAllRegions,
      if (!_isAllRegions)
        'coverage_regions': _coverageRegions.map((c) => c.toJson()).toList(),
    };

    context.read<AuthBloc>().add(UpdateEmployerEvent(data));
  }

  void _showCoverageRegionPicker() {
    final regions = context.read<AuthBloc>().state.regions;
    if (regions.isEmpty) return;

    RegionModel? pickerRegion;
    DistrictModel? pickerDistrict;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
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
                const Text(
                  'Qamrov hududi qo\'shish',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: DARK_NAVY,
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
                      backgroundColor: PRIMARY_BLUE,
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

  InputDecoration _inputDecoration(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: GRAY_TEXT, fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: PRIMARY_BLUE, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      );

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: LIGHT_GRAY_BG,
        body: BlocConsumer<AuthBloc, AuthState>(
          listenWhen: (prev, curr) =>
              prev.updateEmployerStatus != curr.updateEmployerStatus ||
              prev.uploadLogoStatus != curr.uploadLogoStatus,
          listener: (context, state) {
            if (state.updateEmployerStatus.isSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Kompaniya ma\'lumotlari saqlandi'),
                  backgroundColor: GREEN_COLOR,
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
            } else if (state.uploadLogoStatus.isSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logo yangilandi'),
                  backgroundColor: GREEN_COLOR,
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
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: PRIMARY_BLUE),
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
                              employer?.logo,
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
                                  decoration:
                                      _inputDecoration('Qo\'shimcha telefon'),
                                  keyboardType: TextInputType.phone,
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _tinController,
                                  decoration: _inputDecoration('STIR (INN)'),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _addressController,
                                  decoration: _inputDecoration('Manzil'),
                                  maxLines: 2,
                                ),
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
                            _buildCoverageSection(),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: PRIMARY_BLUE,
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
      backgroundColor: const Color(0xFF0F172A),
      foregroundColor: Colors.white,
      title: const Text(
        'Kompaniya ma\'lumotlari',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
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
        color: Colors.white,
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
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: GRAY_TEXT,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLogoSection(String? logoPath, bool isUploading) {
    final logoUrl = logoPath != null ? '$DOMAIN/$logoPath' : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          const Text(
            'Kompaniya logosi',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: GRAY_TEXT,
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
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    image: logoUrl != null
                        ? DecorationImage(
                            image: NetworkImage(logoUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: logoUrl == null
                      ? const Icon(
                          Icons.business_outlined,
                          size: 40,
                          color: GRAY_TEXT,
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
                      decoration: const BoxDecoration(
                        color: PRIMARY_BLUE,
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
          const Center(
            child: Text(
              'Logo yuklash uchun bosing',
              style: TextStyle(fontSize: 12, color: GRAY_TEXT),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadLogo() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 800,
    );
    if (picked == null) return;
    if (!mounted) return;
    context.read<AuthBloc>().add(UploadLogoEvent(picked.path));
  }

  Widget _buildCoverageSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          const Text(
            'Qamrov hududlari',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: GRAY_TEXT,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Nomzod qidiriladigan hududlar',
            style: TextStyle(fontSize: 12, color: GRAY_TEXT),
          ),
          const SizedBox(height: 12),
          // "Butun O'zbekiston" toggle
          GestureDetector(
            onTap: () => setState(() => _isAllRegions = !_isAllRegions),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _isAllRegions
                    ? PRIMARY_BLUE.withValues(alpha: 0.08)
                    : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isAllRegions
                      ? PRIMARY_BLUE.withValues(alpha: 0.4)
                      : const Color(0xFFE5E7EB),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isAllRegions
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: _isAllRegions ? PRIMARY_BLUE : GRAY_TEXT,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Butun O\'zbekiston bo\'yicha',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: DARK_NAVY,
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
                        color: const Color(0xFFF0F4FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: PRIMARY_BLUE.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              color: PRIMARY_BLUE, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entry.value.displayName,
                              style: const TextStyle(
                                  fontSize: 13, color: DARK_NAVY),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() =>
                                _coverageRegions.removeAt(entry.key)),
                            child: const Icon(Icons.close,
                                color: GRAY_TEXT, size: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
              const SizedBox(height: 4),
            ],
            TextButton.icon(
              onPressed: _showCoverageRegionPicker,
              icon: const Icon(Icons.add, color: PRIMARY_BLUE, size: 18),
              label: const Text(
                'Hudud qo\'shish',
                style: TextStyle(color: PRIMARY_BLUE, fontSize: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
