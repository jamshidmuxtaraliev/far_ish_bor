import 'package:flutter/material.dart';

import '../constants/colors.dart';

/// ============================================================================
/// Jobup24 design kit
/// ----------------------------------------------------------------------------
/// Reusable building blocks that encode the "Jobup24 App" visual language:
/// soft-shadow white cards, pill buttons, tinted icon tiles, status chips and
/// segmented toggles. Screens compose these instead of re-deriving the styling.
/// ============================================================================

/// Soft elevation used on nearly every card (0 6px 20px rgba(20,30,60,0.05)).
const List<BoxShadow> kJbSoftShadow = [
  BoxShadow(color: JB_SHADOW, blurRadius: 20, offset: Offset(0, 6)),
];

/// Standard rounded-white card decoration.
BoxDecoration jbCardDecoration({
  double radius = 20,
  Color color = JB_CARD,
  Color? border,
  double borderWidth = 1.5,
  bool shadow = true,
}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    border: border != null ? Border.all(color: border, width: borderWidth) : null,
    boxShadow: shadow ? kJbSoftShadow : null,
  );
}

/// A white rounded card with the standard soft shadow and padding.
class JBCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Color color;
  final Color? border;
  final bool shadow;
  final VoidCallback? onTap;

  const JBCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin,
    this.radius = 20,
    this.color = JB_CARD,
    this.border,
    this.shadow = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: jbCardDecoration(radius: radius, color: color, border: border, shadow: shadow),
      child: child,
    );
    final content = onTap == null
        ? card
        : Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(radius),
              child: card,
            ),
          );
    return margin == null ? content : Padding(padding: margin!, child: content);
  }
}

/// Rounded-square tinted icon container (the small 36–40px tiles in the design).
class JBIconTile extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color fg;
  final double size;
  final double radius;
  final double iconSize;

  const JBIconTile({
    super.key,
    required this.icon,
    this.bg = JB_INDIGO_TINT,
    this.fg = JB_BLUE,
    this.size = 38,
    this.radius = 12,
    this.iconSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(radius)),
      alignment: Alignment.center,
      child: Icon(icon, color: fg, size: iconSize),
    );
  }
}

/// Pill status/label chip.
class JBChip extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  final double fontSize;
  final FontWeight fontWeight;
  final EdgeInsetsGeometry padding;

  const JBChip({
    super.key,
    required this.text,
    this.bg = JB_CHIP_BG,
    this.fg = JB_INK,
    this.fontSize = 13,
    this.fontWeight = FontWeight.w700,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(100)),
      child: Text(
        text,
        style: TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: fg, height: 1.1),
      ),
    );
  }
}

/// Green "✦ NN% mos" compatibility badge.
class JBMatchBadge extends StatelessWidget {
  final num percent;
  const JBMatchBadge({super.key, required this.percent});

  @override
  Widget build(BuildContext context) {
    return JBChip(text: '✦ ${percent.round()}% mos', bg: JB_GREEN_BG, fg: JB_GREEN_FG);
  }
}

enum JBBtnVariant { primary, outline, ghost, disabled }

/// Pill-shaped action button (100px radius) matching the design's CTAs.
class JBPillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final JBBtnVariant variant;
  final IconData? trailingIcon;
  final IconData? leadingIcon;
  final bool expand;
  final double vPadding;
  final double fontSize;
  final bool elevated;

  const JBPillButton({
    super.key,
    required this.label,
    this.onTap,
    this.variant = JBBtnVariant.primary,
    this.trailingIcon,
    this.leadingIcon,
    this.expand = false,
    this.vPadding = 14,
    this.fontSize = 14.5,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    Border? border;
    switch (variant) {
      case JBBtnVariant.primary:
        bg = JB_BLUE;
        fg = Colors.white;
        break;
      case JBBtnVariant.outline:
        bg = Colors.white;
        fg = JB_INK;
        border = Border.all(color: JB_BORDER, width: 1.5);
        break;
      case JBBtnVariant.ghost:
        bg = Colors.transparent;
        fg = JB_GRAY;
        break;
      case JBBtnVariant.disabled:
        bg = const Color(0xFFE2E5EC);
        fg = JB_GRAY_LIGHT;
        break;
    }

    final row = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null) ...[Icon(leadingIcon, size: 16, color: fg), const SizedBox(width: 8)],
        Text(label, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700, color: fg)),
        if (trailingIcon != null) ...[const SizedBox(width: 8), Icon(trailingIcon, size: 16, color: fg)],
      ],
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: variant == JBBtnVariant.disabled ? null : onTap,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: vPadding, horizontal: 22),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(100),
            border: border,
            boxShadow: elevated && variant == JBBtnVariant.primary
                ? [BoxShadow(color: JB_BLUE.withValues(alpha: 0.30), blurRadius: 24, offset: const Offset(0, 10))]
                : null,
          ),
          alignment: Alignment.center,
          child: row,
        ),
      ),
    );
  }
}

/// Section title with an optional trailing "see all" action.
class JBSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;

  const JBSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.fromLTRB(20, 24, 20, 8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: JB_INK)),
          ),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Text(actionLabel!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: JB_BLUE)),
            ),
        ],
      ),
    );
  }
}

/// Pill segmented control (Ro'yxat/Xarita, Ish tavsifi/Korxona, ...).
class JBSegmented extends StatelessWidget {
  final List<String> tabs;
  final int index;
  final ValueChanged<int> onChanged;
  final EdgeInsetsGeometry padding;

  const JBSegmented({
    super.key,
    required this.tabs,
    required this.index,
    required this.onChanged,
    this.padding = const EdgeInsets.all(4),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(color: JB_CHIP_BG, borderRadius: BorderRadius.circular(100)),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final active = i == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: active ? JB_BLUE : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                ),
                alignment: Alignment.center,
                child: Text(
                  tabs[i],
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: active ? Colors.white : JB_GRAY,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Horizontal Jobup24 wordmark (black "JOB" + blue "up24").
class JBWordmark extends StatelessWidget {
  final double height;
  const JBWordmark({super.key, this.height = 22});

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/images/logo_text.png', height: height, fit: BoxFit.contain);
  }
}

/// Circular back button used on sub-screen headers.
class JBCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color bg;
  final Color fg;
  final double size;

  const JBCircleButton({
    super.key,
    this.icon = Icons.arrow_back_ios_new_rounded,
    this.onTap,
    this.bg = JB_CHIP_BG,
    this.fg = JB_INK,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: fg),
      ),
    );
  }
}
