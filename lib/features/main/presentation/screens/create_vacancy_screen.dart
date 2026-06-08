import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/constants/colors.dart';
import '../../../auth/data/models/anketa_models.dart';
import '../../../auth/presentation/logic/auth_bloc.dart';
import '../../data/models/create_vacancy_request.dart';
import '../../data/models/employer_vacancy_model.dart';
import '../logic/vacancy_bloc.dart';

class CreateVacancyScreen extends StatefulWidget {
  final EmployerVacancyModel? existing;

  const CreateVacancyScreen({super.key, this.existing});

  @override
  State<CreateVacancyScreen> createState() => _CreateVacancyScreenState();
}

class _CreateVacancyScreenState extends State<CreateVacancyScreen> {
  JobTypeModel? _selectedJobType;
  final _anketaCountController = TextEditingController();
  final _salaryController = TextEditingController();
  final _minAgeController = TextEditingController();
  final _maxAgeController = TextEditingController();
  final _commentController = TextEditingController();
  DateTime? _deadline;
  String _status = 'active';

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(LoadJobTypesEvent());
    _prefill();
  }

  void _prefill() {
    final e = widget.existing;
    if (e == null) return;
    _anketaCountController.text = e.anketaCount?.toString() ?? '';
    _salaryController.text = e.salary?.toString() ?? '';
    _minAgeController.text = e.minAge?.toString() ?? '';
    _maxAgeController.text = e.maxAge?.toString() ?? '';
    _commentController.text = e.comment ?? '';
    _status = e.status ?? 'active';
    if (e.deadline != null) {
      try {
        _deadline = DateTime.parse(e.deadline!);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _anketaCountController.dispose();
    _salaryController.dispose();
    _minAgeController.dispose();
    _maxAgeController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selectedJobType == null && !_isEdit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Iltimos, kasb turini tanlang"),
          backgroundColor: RED_COLOR,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final request = CreateVacancyRequest(
      id: widget.existing?.id,
      jobTypeId: _selectedJobType?.id ?? widget.existing?.jobTypeId,
      anketaCount: int.tryParse(_anketaCountController.text.trim()),
      salary: int.tryParse(_salaryController.text.trim()),
      deadline: _deadline != null
          ? '${_deadline!.year}-${_deadline!.month.toString().padLeft(2, '0')}-${_deadline!.day.toString().padLeft(2, '0')}'
          : null,
      minAge: int.tryParse(_minAgeController.text.trim()),
      maxAge: int.tryParse(_maxAgeController.text.trim()),
      status: _status,
      comment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
    );

    if (_isEdit) {
      context.read<VacancyBloc>().add(UpdateVacancyEvent(request));
    } else {
      context.read<VacancyBloc>().add(CreateVacancyEvent(request));
    }
  }

  void _showJobTypePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<AuthBloc>(),
        child: _JobTypeSheet(
          selectedId: _selectedJobType?.id ?? widget.existing?.jobTypeId,
          onSelected: (jt) => setState(() => _selectedJobType = jt),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VacancyBloc, VacancyState>(
      listenWhen: (p, c) => p.manageVacancyStatus != c.manageVacancyStatus,
      listener: (context, state) {
        if (state.manageVacancyStatus.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEdit ? 'Vakansiya yangilandi' : 'Vakansiya yaratildi'),
              backgroundColor: GREEN_COLOR,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context, true);
        }
        if (state.manageVacancyStatus.isFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error?.errorMessage ?? 'Xatolik yuz berdi'),
              backgroundColor: RED_COLOR,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: LIGHT_GRAY_BG,
          body: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildJobTypeCard(),
                      const SizedBox(height: 16),
                      _buildDetailsCard(),
                      const SizedBox(height: 16),
                      _buildAgeCard(),
                      const SizedBox(height: 16),
                      _buildStatusCard(),
                      const SizedBox(height: 16),
                      _buildCommentCard(),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D1B2A), Color(0xFF1A2F4A)],
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ishchi e\'lonlar', style: TextStyle(color: Colors.white54, fontSize: 12)),
                Text(
                  _isEdit ? "Vakansiyani tahrirlash" : "Yangi vakansiya",
                  style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: PRIMARY_BLUE.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.work_outline, color: Colors.white, size: 13),
                const SizedBox(width: 4),
                Text(
                  _isEdit ? 'Tahrirlash' : 'Yangi',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobTypeCard() {
    return _SectionCard(
      title: 'Kasb / Mutaxassislik',
      icon: Icons.work_outline,
      required: true,
      children: [
        BlocBuilder<AuthBloc, AuthState>(
          buildWhen: (p, c) => p.jobTypes != c.jobTypes || p.jobTypesStatus != c.jobTypesStatus,
          builder: (context, state) {
            final displayName = _selectedJobType?.name ?? widget.existing?.jobTypeName;
            return _SelectField(
              value: displayName,
              hint: 'Kasb turini tanlang',
              icon: Icons.category_outlined,
              onTap: _showJobTypePicker,
            );
          },
        ),
      ],
    );
  }

  Widget _buildDetailsCard() {
    return _SectionCard(
      title: 'Vakansiya tafsilotlari',
      icon: Icons.description_outlined,
      children: [
        const _FieldLabel("Kerakli nomzodlar soni"),
        const SizedBox(height: 8),
        _NumField(
          controller: _anketaCountController,
          hint: '1',
          icon: Icons.people_outline,
        ),
        const SizedBox(height: 16),
        const _FieldLabel("Maosh (so'm)"),
        const SizedBox(height: 8),
        _NumField(
          controller: _salaryController,
          hint: '6 000 000',
          icon: Icons.payments_outlined,
        ),
        const SizedBox(height: 16),
        const _FieldLabel("Ariza qabul qilish muddati"),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _deadline ?? DateTime.now().add(const Duration(days: 14)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (ctx, child) => Theme(
                data: Theme.of(ctx).copyWith(
                  colorScheme: const ColorScheme.light(primary: PRIMARY_BLUE),
                ),
                child: child!,
              ),
            );
            if (picked != null) setState(() => _deadline = picked);
          },
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: LIGHT_GRAY_BG,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _deadline != null ? PRIMARY_BLUE.withValues(alpha: 0.4) : const Color(0xFFE5E7EB),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, color: _deadline != null ? PRIMARY_BLUE : GRAY_TEXT, size: 18),
                const SizedBox(width: 10),
                Text(
                  _deadline != null
                      ? '${_deadline!.day.toString().padLeft(2, '0')}.${_deadline!.month.toString().padLeft(2, '0')}.${_deadline!.year}'
                      : 'Muddatni tanlang',
                  style: TextStyle(color: _deadline != null ? DARK_NAVY : GRAY_TEXT, fontSize: 15),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right, color: GRAY_TEXT, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAgeCard() {
    return _SectionCard(
      title: 'Yosh talablari',
      icon: Icons.person_search_outlined,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FieldLabel('Minimal yosh'),
                  const SizedBox(height: 8),
                  _NumField(controller: _minAgeController, hint: '18', icon: Icons.arrow_downward_rounded),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FieldLabel('Maksimal yosh'),
                  const SizedBox(height: 8),
                  _NumField(controller: _maxAgeController, hint: '50', icon: Icons.arrow_upward_rounded),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    const options = [
      ('active', 'Faol', Icons.check_circle_outline, GREEN_COLOR),
      ('inactive', 'Nofaol', Icons.pause_circle_outline, GRAY_TEXT),
    ];
    return _SectionCard(
      title: 'Vakansiya holati',
      icon: Icons.toggle_on_outlined,
      children: [
        Row(
          children: options.map((opt) {
            final isSelected = _status == opt.$1;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: opt.$1 == 'active' ? 8 : 0),
                child: GestureDetector(
                  onTap: () => setState(() => _status = opt.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSelected ? opt.$4.withValues(alpha: 0.08) : LIGHT_GRAY_BG,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? opt.$4 : const Color(0xFFE5E7EB),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(opt.$3, color: isSelected ? opt.$4 : GRAY_TEXT, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          opt.$2,
                          style: TextStyle(
                            color: isSelected ? opt.$4 : GRAY_TEXT,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCommentCard() {
    return _SectionCard(
      title: 'Qo\'shimcha izoh',
      icon: Icons.comment_outlined,
      children: [
        TextField(
          controller: _commentController,
          maxLines: 4,
          minLines: 3,
          textCapitalization: TextCapitalization.sentences,
          style: const TextStyle(fontSize: 14, color: DARK_NAVY, height: 1.5),
          decoration: InputDecoration(
            hintText: 'Vakansiya haqida qo\'shimcha ma\'lumot...',
            hintStyle: const TextStyle(color: GRAY_TEXT, fontSize: 13),
            filled: true,
            fillColor: LIGHT_GRAY_BG,
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: PRIMARY_BLUE, width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return BlocBuilder<VacancyBloc, VacancyState>(
      buildWhen: (p, c) => p.manageVacancyStatus != c.manageVacancyStatus,
      builder: (context, state) {
        final isLoading = state.manageVacancyStatus.isInProgress;
        return Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(context).padding.bottom + 12,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, -2))],
          ),
          child: GestureDetector(
            onTap: isLoading ? null : _submit,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [PRIMARY_BLUE, SECONDARY_BLUE]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(color: PRIMARY_BLUE.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_isEdit ? Icons.save_outlined : Icons.add_circle_outline, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _isEdit ? 'Saqlash' : 'Vakansiya yaratish',
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

// ── Job type searchable bottom sheet ─────────────────────────────────────────

class _JobTypeSheet extends StatefulWidget {
  final int? selectedId;
  final ValueChanged<JobTypeModel> onSelected;

  const _JobTypeSheet({required this.selectedId, required this.onSelected});

  @override
  State<_JobTypeSheet> createState() => _JobTypeSheetState();
}

class _JobTypeSheetState extends State<_JobTypeSheet> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);
  }

  void _onSearch() {
    final text = _searchController.text.trim();
    context.read<AuthBloc>().add(LoadJobTypesEvent(text: text.isEmpty ? null : text));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const Text('Kasb tanlang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: DARK_NAVY)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: const TextStyle(fontSize: 15, color: DARK_NAVY),
                    decoration: InputDecoration(
                      hintText: 'Kasb nomini kiriting...',
                      hintStyle: const TextStyle(color: GRAY_TEXT),
                      prefixIcon: const Icon(Icons.search, color: GRAY_TEXT, size: 20),
                      filled: true,
                      fillColor: LIGHT_GRAY_BG,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: PRIMARY_BLUE, width: 1.5)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: BlocBuilder<AuthBloc, AuthState>(
                buildWhen: (p, c) => p.jobTypes != c.jobTypes || p.jobTypesStatus != c.jobTypesStatus,
                builder: (context, state) {
                  if (state.jobTypesStatus.isInProgress) {
                    return const Center(child: CircularProgressIndicator(color: PRIMARY_BLUE, strokeWidth: 2));
                  }
                  if (state.jobTypes.isEmpty) {
                    return const Center(
                      child: Text('Natija topilmadi', style: TextStyle(color: GRAY_TEXT)),
                    );
                  }
                  return ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: state.jobTypes.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
                    itemBuilder: (_, i) {
                      final item = state.jobTypes[i];
                      final isSelected = item.id == widget.selectedId;
                      return InkWell(
                        onTap: () {
                          widget.onSelected(item);
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isSelected ? PRIMARY_BLUE : DARK_NAVY,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (isSelected) const Icon(Icons.check_rounded, color: PRIMARY_BLUE, size: 18),
                            ],
                          ),
                        ),
                      );
                    },
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

// ── Reusable form widgets ─────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool required;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: PRIMARY_BLUE.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: PRIMARY_BLUE, size: 16),
              ),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: DARK_NAVY)),
              if (required) ...[
                const SizedBox(width: 4),
                const Text('*', style: TextStyle(color: RED_COLOR, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: GRAY_TEXT));
  }
}

class _NumField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;

  const _NumField({required this.controller, required this.hint, required this.icon});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(fontSize: 15, color: DARK_NAVY),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: GRAY_TEXT),
        prefixIcon: Icon(icon, color: GRAY_TEXT, size: 18),
        filled: true,
        fillColor: LIGHT_GRAY_BG,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: PRIMARY_BLUE, width: 1.5)),
      ),
    );
  }
}

class _SelectField extends StatelessWidget {
  final String? value;
  final String hint;
  final IconData icon;
  final VoidCallback onTap;

  const _SelectField({required this.hint, required this.icon, required this.onTap, this.value});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: LIGHT_GRAY_BG,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: value != null ? PRIMARY_BLUE.withValues(alpha: 0.4) : const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Icon(icon, color: value != null ? PRIMARY_BLUE : GRAY_TEXT, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value ?? hint,
                style: TextStyle(color: value != null ? DARK_NAVY : GRAY_TEXT, fontSize: 15),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: GRAY_TEXT, size: 20),
          ],
        ),
      ),
    );
  }
}
