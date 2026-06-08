import 'package:flutter/material.dart';

import '../../../../../core/constants/colors.dart';

class Step5Additional extends StatelessWidget {
  final TextEditingController motivationController;
  final TextEditingController prevJobReasonController;
  final TextEditingController additionalContactController;

  const Step5Additional({
    super.key,
    required this.motivationController,
    required this.prevJobReasonController,
    required this.additionalContactController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: PRIMARY_BLUE.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: PRIMARY_BLUE.withValues(alpha: 0.2)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, color: PRIMARY_BLUE, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Bu bo'limdagi ma'lumotlar ixtiyoriy. To'ldirish anketangizni kuchaytiradi va ish topish imkoniyatingizni oshiradi.",
                    style: TextStyle(color: PRIMARY_BLUE, fontSize: 12, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            children: [
              const _FieldLabel('Motivatsiya'),
              const SizedBox(height: 4),
              const Text(
                'Nima uchun bu kasbni tanlagansiz? Maqsadlaringiz nima?',
                style: TextStyle(color: GRAY_TEXT, fontSize: 12),
              ),
              const SizedBox(height: 10),
              _MultilineField(
                controller: motivationController,
                hint: 'Kasbga bo\'lgan qiziqishingiz, maqsadlaringiz haqida yozing...',
                maxLines: 4,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            children: [
              const _FieldLabel('Oldingi ish joyini tark etish sababi'),
              const SizedBox(height: 4),
              const Text(
                "Oldingi ish joyingizdan ketish sababini ko'rsating",
                style: TextStyle(color: GRAY_TEXT, fontSize: 12),
              ),
              const SizedBox(height: 10),
              _MultilineField(
                controller: prevJobReasonController,
                hint: 'Sabab...',
                maxLines: 3,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            children: [
              const _FieldLabel("Qo'shimcha aloqa"),
              const SizedBox(height: 4),
              const Text(
                "Telegram, email yoki boshqa aloqa ma'lumotlari",
                style: TextStyle(color: GRAY_TEXT, fontSize: 12),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: additionalContactController,
                style: const TextStyle(fontSize: 15, color: DARK_NAVY),
                decoration: InputDecoration(
                  hintText: '@telegram yoki email@example.com',
                  hintStyle: const TextStyle(color: GRAY_TEXT, fontSize: 14),
                  prefixIcon: const Icon(Icons.alternate_email_outlined, color: GRAY_TEXT, size: 18),
                  filled: true,
                  fillColor: LIGHT_GRAY_BG,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: PRIMARY_BLUE, width: 1.5)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: GREEN_COLOR.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: GREEN_COLOR.withValues(alpha: 0.25)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_outline, color: GREEN_COLOR, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Hammasi tayyor! \"Saqlash\" tugmasini bosib anketangizni yuborishingiz mumkin.",
                    style: TextStyle(color: GREEN_COLOR, fontSize: 12, fontWeight: FontWeight.w500, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MultilineField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const _MultilineField({required this.controller, required this.hint, required this.maxLines});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      minLines: maxLines,
      textCapitalization: TextCapitalization.sentences,
      style: const TextStyle(fontSize: 14, color: DARK_NAVY, height: 1.5),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: GRAY_TEXT, fontSize: 13),
        filled: true,
        fillColor: LIGHT_GRAY_BG,
        contentPadding: const EdgeInsets.all(14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: PRIMARY_BLUE, width: 1.5)),
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
