import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../theme/app_theme.dart';

class CustomSwitch extends StatefulWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomSwitch({super.key, required this.value, required this.onChanged, required this.title});

  @override
  State<CustomSwitch> createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> with SingleTickerProviderStateMixin {
  late bool isOn;

  @override
  void initState() {
    super.initState();
    isOn = widget.value;
  }

  void _toggleSwitch() {
    setState(() {
      isOn = !isOn;
    });
    widget.onChanged(isOn);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: Text(widget.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 12))),

        GestureDetector(
          onTap: _toggleSwitch,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: 60,
            height: 32,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: BLACK_RIGHT_ICON,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: const Color(0xFF8C6A2E), width: 2),
            ),
            child: AnimatedAlign(
              duration: Duration(milliseconds: 200),
              alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(shape: BoxShape.circle, color: isOn ? Color(0xFFFCC562) : Color(0xFF444444)),
              ),
            ),
          ),
        ),
        // CustomSwitch(
        //   value: isRequireArtifact,
        //   onChanged: (value) {
        //     isRequireArtifact = !isRequireArtifact;
        //   },
        // ),
      ],
    );
  }
}

class CustomCheckbox extends StatelessWidget {
  final bool isChecked;
  final String label;
  final VoidCallback onChanged;

  const CustomCheckbox({super.key, required this.isChecked, required this.label, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onChanged,
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isChecked ? BUTTON_COLOR : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: isChecked ? BUTTON_COLOR : Colors.grey.shade400, width: 2),
            ),
            child: isChecked ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: lightTheme().textTheme.bodyLarge?.copyWith(fontSize: 12))),
        ],
      ),
    );
  }
}
