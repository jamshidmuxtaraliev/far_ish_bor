import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../../../../core/constants/colors.dart';

/// Ishlar xaritasi uchun custom marker'larni runtime'da chizadi (PNG bytes →
/// [BitmapDescriptor]). Hech qanday binary asset kerak emas.
class JobMapMarkers {
  const JobMapMarkers._();

  /// Bitta vakansiya markeri — qizil "point" pin ichida oq chamadon (ish) ikonasi.
  /// Zoom yaqinlashganda har bir ish shu marker bilan ko'rinadi.
  static Future<BitmapDescriptor> jobPin(double dpr) async {
    const double w = 44;
    const double h = 56;
    final size = Size(w * dpr, h * dpr);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(dpr);

    final center = Offset(w / 2, w / 2);
    const double r = w / 2 - 2;

    // Soya
    canvas.drawCircle(
      Offset(w / 2, h - 6),
      5,
      Paint()..color = Colors.black.withValues(alpha: 0.18),
    );

    // Pin tanasi (tomchi shakli): bosh doira + pastga qarab uchi
    final path = Path()
      ..moveTo(w / 2 - r * 0.62, center.dy + r * 0.62)
      ..quadraticBezierTo(w / 2, h + 1, w / 2, h)
      ..quadraticBezierTo(w / 2, h + 1, w / 2 + r * 0.62, center.dy + r * 0.62)
      ..close();
    final fill = Paint()..color = RED_COLOR;
    canvas.drawPath(path, fill);
    canvas.drawCircle(center, r, fill);

    // Oq halqa
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = Colors.white,
    );

    // Chamadon (ish) ikonasi — oq
    _drawIcon(canvas, Icons.work_rounded, center, r * 1.05, Colors.white);

    return _toDescriptor(recorder, size);
  }

  /// Klaster markeri — ichида ish soni bo'lgan doira. Kichik klasterlar ko'k,
  /// katta klasterlar qizil (screenshotdagidek), tashqarisida yumshoq halqa.
  static Future<BitmapDescriptor> cluster(int count, double dpr) async {
    final bool big = count >= 10;
    final Color color = big ? RED_COLOR : PRIMARY_BLUE;
    // Diametr son kattaligiga qarab biroz o'sadi.
    final double d = big ? (count >= 50 ? 58 : 52) : 46;
    final double glow = d + 14;

    final size = Size(glow * dpr, glow * dpr);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(dpr);

    final center = Offset(glow / 2, glow / 2);

    // Tashqi yumshoq halqa
    canvas.drawCircle(center, glow / 2, Paint()..color = color.withValues(alpha: 0.28));
    // Ichki to'liq doira
    canvas.drawCircle(center, d / 2, Paint()..color = color);
    // Oq chegara
    canvas.drawCircle(
      center,
      d / 2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.9),
    );

    // Son
    final label = count > 99 ? '99+' : '$count';
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white,
          fontSize: count > 99 ? 17 : 19,
          fontWeight: FontWeight.bold,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));

    return _toDescriptor(recorder, size);
  }

  static void _drawIcon(Canvas canvas, IconData icon, Offset center, double fontSize, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: fontSize,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  static Future<BitmapDescriptor> _toDescriptor(ui.PictureRecorder recorder, Size sizePx) async {
    final image = await recorder.endRecording().toImage(sizePx.width.ceil(), sizePx.height.ceil());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }
}
