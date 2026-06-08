import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../../core/constants/colors.dart';
import '../../../data/models/anketa_models.dart';
import '../../logic/auth_bloc.dart';

const _workStatusOptions = [
  ('searching', 'Faol ish izlayapman'),
  ('employed_looking', 'Ishim bor, almashmoqchi'),
  ('not_looking', 'Hozircha izlamayapman'),
];

const _workScheduleOptions = [
  ('full_time', "To'liq kunlik"),
  ('part_time', 'Yarim kunlik'),
  ('remote', 'Masofaviy'),
  ('shift', 'Smenali'),
  ('flexible', 'Erkin jadval'),
];

class Step3Job extends StatefulWidget {
  final JobTypeModel? selectedJobType;
  final TextEditingController experienceController;
  final TextEditingController expectedSalaryController;
  final String? workStatus;
  final String? workSchedule;
  final ValueChanged<JobTypeModel?> onJobTypeChanged;
  final ValueChanged<String?> onWorkStatusChanged;
  final ValueChanged<String?> onWorkScheduleChanged;

  const Step3Job({
    super.key,
    required this.selectedJobType,
    required this.experienceController,
    required this.expectedSalaryController,
    required this.workStatus,
    required this.workSchedule,
    required this.onJobTypeChanged,
    required this.onWorkStatusChanged,
    required this.onWorkScheduleChanged,
  });

  @override
  State<Step3Job> createState() => _Step3JobState();
}

class _Step3JobState extends State<Step3Job> {
  void _showJobTypePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<AuthBloc>(),
        child: _JobTypeSheet(
          onSelected: widget.onJobTypeChanged,
          selectedId: widget.selectedJobType?.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            children: [
              const _FieldLabel('Kasb / Mutaxassislik'),
              const SizedBox(height: 8),
              _SelectField(
                value: widget.selectedJobType?.name,
                hint: 'Kasbni tanlang',
                icon: Icons.work_outline,
                onTap: () => _showJobTypePicker(context),
              ),
              const SizedBox(height: 16),
              const _FieldLabel('Ish tajribasi (yil)'),
              const SizedBox(height: 8),
              _NumericField(
                controller: widget.experienceController,
                hint: '0',
                icon: Icons.history_outlined,
              ),
              const SizedBox(height: 16),
              const _FieldLabel('Kutilayotgan maosh (so\'m)'),
              const SizedBox(height: 8),
              _NumericField(
                controller: widget.expectedSalaryController,
                hint: '3 000 000',
                icon: Icons.payments_outlined,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            children: [
              const _FieldLabel('Ish holati'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _workStatusOptions.map((opt) {
                  final isSelected = widget.workStatus == opt.$1;
                  return _OptionChip(
                    label: opt.$2,
                    isSelected: isSelected,
                    onTap: () => widget.onWorkStatusChanged(isSelected ? null : opt.$1),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            children: [
              const _FieldLabel('Ish jadvali'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _workScheduleOptions.map((opt) {
                  final isSelected = widget.workSchedule == opt.$1;
                  return _OptionChip(
                    label: opt.$2,
                    isSelected: isSelected,
                    onTap: () => widget.onWorkScheduleChanged(isSelected ? null : opt.$1),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JobTypeSheet extends StatefulWidget {
  final int? selectedId;
  final ValueChanged<JobTypeModel?> onSelected;

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
            Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2))),
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

class _OptionChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? PRIMARY_BLUE : LIGHT_GRAY_BG,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? PRIMARY_BLUE : const Color(0xFFE5E7EB)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : DARK_NAVY,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
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
        color: Colors.white,
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
    return Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DARK_NAVY));
  }
}

class _SelectField extends StatelessWidget {
  final String? value;
  final String hint;
  final IconData icon;
  final VoidCallback? onTap;

  const _SelectField({required this.hint, required this.icon, this.value, this.onTap});

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

class _NumericField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;

  const _NumericField({required this.controller, required this.hint, required this.icon});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(fontSize: 15, color: DARK_NAVY),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: GRAY_TEXT, fontSize: 15),
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
