import 'package:flutter/material.dart';

import '../../../../../core/theme/jb_palette.dart';

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
              color: context.jb.blue.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.jb.blue.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, color: context.jb.blue, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Bu bo'limdagi ma'lumotlar ixtiyoriy. To'ldirish anketangizni kuchaytiradi va ish topish imkoniyatingizni oshiradi.",
                    style: TextStyle(color: context.jb.blue, fontSize: 12, height: 1.5),
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
              Text(
                'Nima uchun bu kasbni tanlagansiz? Maqsadlaringiz nima?',
                style: TextStyle(color: context.jb.gray, fontSize: 12),
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
              Text(
                "Oldingi ish joyingizdan ketish sababini ko'rsating",
                style: TextStyle(color: context.jb.gray, fontSize: 12),
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
              Text(
                "Telegram, email yoki boshqa aloqa ma'lumotlari",
                style: TextStyle(color: context.jb.gray, fontSize: 12),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: additionalContactController,
                style: TextStyle(fontSize: 15, color: context.jb.ink),
                decoration: InputDecoration(
                  hintText: '@telegram yoki email@example.com',
                  hintStyle: TextStyle(color: context.jb.gray, fontSize: 14),
                  prefixIcon: Icon(Icons.alternate_email_outlined, color: context.jb.gray, size: 18),
                  filled: true,
                  fillColor: context.jb.bg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.jb.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.jb.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.jb.blue, width: 1.5)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.jb.green.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.jb.green.withValues(alpha: 0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_outline, color: context.jb.green, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Hammasi tayyor! \"Saqlash\" tugmasini bosib anketangizni yuborishingiz mumkin.",
                    style: TextStyle(color: context.jb.green, fontSize: 12, fontWeight: FontWeight.w500, height: 1.5),
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
      style: TextStyle(fontSize: 14, color: context.jb.ink, height: 1.5),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: context.jb.gray, fontSize: 13),
        filled: true,
        fillColor: context.jb.bg,
        contentPadding: const EdgeInsets.all(14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.jb.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.jb.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.jb.blue, width: 1.5)),
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
