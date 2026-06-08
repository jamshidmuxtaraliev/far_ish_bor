import 'package:flutter/material.dart';

import '../../../../../core/constants/colors.dart';

class Step1Personal extends StatelessWidget {
  final TextEditingController fullnameController;
  final String? gender;
  final DateTime? birthday;
  final ValueChanged<String?> onGenderChanged;
  final ValueChanged<DateTime?> onBirthdayChanged;

  const Step1Personal({
    super.key,
    required this.fullnameController,
    required this.gender,
    required this.birthday,
    required this.onGenderChanged,
    required this.onBirthdayChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            children: [
              _FieldLabel('To\'liq ism'),
              const SizedBox(height: 8),
              _InputField(
                controller: fullnameController,
                hint: 'Familiya Ism Otasining ismi',
                icon: Icons.person_outline,
                textCapitalization: TextCapitalization.words,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            children: [
              _FieldLabel('Jinsi'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _GenderChip(
                      label: 'Erkak',
                      icon: Icons.male_rounded,
                      isSelected: gender == 'male',
                      color: PRIMARY_BLUE,
                      onTap: () => onGenderChanged('male'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _GenderChip(
                      label: 'Ayol',
                      icon: Icons.female_rounded,
                      isSelected: gender == 'female',
                      color: const Color(0xFFEC4899),
                      onTap: () => onGenderChanged('female'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            children: [
              _FieldLabel('Tug\'ilgan sana'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: birthday ?? DateTime(1995, 1, 1),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now().subtract(const Duration(days: 365 * 16)),
                    builder: (ctx, child) => Theme(
                      data: Theme.of(ctx).copyWith(
                        colorScheme: const ColorScheme.light(primary: PRIMARY_BLUE),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) onBirthdayChanged(picked);
                },
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: LIGHT_GRAY_BG,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, color: GRAY_TEXT, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        birthday != null
                            ? '${birthday!.day.toString().padLeft(2, '0')}.${birthday!.month.toString().padLeft(2, '0')}.${birthday!.year}'
                            : 'Sanani tanlang',
                        style: TextStyle(
                          color: birthday != null ? DARK_NAVY : GRAY_TEXT,
                          fontSize: 15,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right, color: GRAY_TEXT, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _GenderChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : LIGHT_GRAY_BG,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE5E7EB),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? color : GRAY_TEXT, size: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : GRAY_TEXT,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 15,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DARK_NAVY),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextCapitalization textCapitalization;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textCapitalization: textCapitalization,
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
