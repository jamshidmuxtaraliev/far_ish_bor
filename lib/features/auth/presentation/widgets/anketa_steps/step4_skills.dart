import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../../core/constants/colors.dart';
import '../../logic/auth_bloc.dart';

class Step4Skills extends StatelessWidget {
  final List<String> selectedLanguages;
  final bool hasLicense;
  final bool hasCar;
  final bool physicalWorkOk;
  final bool computerLiteracy;
  final ValueChanged<List<String>> onLanguagesChanged;
  final ValueChanged<bool> onLicenseChanged;
  final ValueChanged<bool> onCarChanged;
  final ValueChanged<bool> onPhysicalChanged;
  final ValueChanged<bool> onComputerChanged;

  const Step4Skills({
    super.key,
    required this.selectedLanguages,
    required this.hasLicense,
    required this.hasCar,
    required this.physicalWorkOk,
    required this.computerLiteracy,
    required this.onLanguagesChanged,
    required this.onLicenseChanged,
    required this.onCarChanged,
    required this.onPhysicalChanged,
    required this.onComputerChanged,
  });

  void _toggleLanguage(String code) {
    final updated = List<String>.from(selectedLanguages);
    if (updated.contains(code)) {
      updated.remove(code);
    } else {
      updated.add(code);
    }
    onLanguagesChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (p, c) => p.languages != c.languages || p.languagesStatus != c.languagesStatus,
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionCard(
                children: [
                  const _FieldLabel('Til bilimi'),
                  const SizedBox(height: 4),
                  const Text('Biladigan tillaringizni tanlang', style: TextStyle(color: GRAY_TEXT, fontSize: 12)),
                  const SizedBox(height: 12),
                  if (state.languagesStatus.isInProgress)
                    const Center(child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: CircularProgressIndicator(color: PRIMARY_BLUE, strokeWidth: 2),
                    ))
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: state.languages.map((lang) {
                        final isSelected = selectedLanguages.contains(lang.code);
                        return GestureDetector(
                          onTap: () => _toggleLanguage(lang.code),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                            decoration: BoxDecoration(
                              color: isSelected ? PRIMARY_BLUE : LIGHT_GRAY_BG,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isSelected ? PRIMARY_BLUE : const Color(0xFFE5E7EB)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isSelected) ...[
                                  const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  lang.name,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : DARK_NAVY,
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              _SectionCard(
                children: [
                  const _FieldLabel("Qo'shimcha ko'nikmalar"),
                  const SizedBox(height: 4),
                  _ToggleRow(
                    icon: Icons.drive_eta_outlined,
                    iconColor: const Color(0xFF7C3AED),
                    label: "Haydovchilik guvohnomasi",
                    subtitle: "Haydovchilik guvohnomangiz bormi?",
                    value: hasLicense,
                    onChanged: onLicenseChanged,
                  ),
                  const Divider(height: 20, color: Color(0xFFF3F4F6)),
                  _ToggleRow(
                    icon: Icons.directions_car_outlined,
                    iconColor: const Color(0xFFEA580C),
                    label: "Shaxsiy avtomobil",
                    subtitle: "O'z mashinangiz bormi?",
                    value: hasCar,
                    onChanged: onCarChanged,
                  ),
                  const Divider(height: 20, color: Color(0xFFF3F4F6)),
                  _ToggleRow(
                    icon: Icons.fitness_center_outlined,
                    iconColor: const Color(0xFF16A34A),
                    label: "Jismoniy ish",
                    subtitle: "Jismoniy mehnatga tayyormisiz?",
                    value: physicalWorkOk,
                    onChanged: onPhysicalChanged,
                  ),
                  const Divider(height: 20, color: Color(0xFFF3F4F6)),
                  _ToggleRow(
                    icon: Icons.computer_outlined,
                    iconColor: PRIMARY_BLUE,
                    label: "Kompyuter savodi",
                    subtitle: "Kompyuter bilan ishlashni bilasizmi?",
                    value: computerLiteracy,
                    onChanged: onComputerChanged,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: DARK_NAVY)),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: GRAY_TEXT)),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.white,
          activeTrackColor: PRIMARY_BLUE,
        ),
      ],
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
